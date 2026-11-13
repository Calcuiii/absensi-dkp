'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const {fetchParticipant, endpoint, retryAfterSeconds} = require('../src/si-melayur');

const participant = {id: '123', email: 'uji@example.com', full_name: 'Peserta Uji',
  status: 'accepted', is_active: true, start_date: '2026-11-01', end_date: '2026-11-30'};
const base = {url: 'https://example.invalid/api/participants/verify', apiKey: 'test-only',
  email: participant.email, day: '2026-11-08', sleep: async () => {}};
const response = (status, body, headers = {}) => new Response(JSON.stringify(body), {status, headers});

test('request uses server Bearer token, Accept and email; redirects are refused', async () => {
  const result = await fetchParticipant({...base, fetchImpl: async (url, options) => {
    assert.equal(url.pathname, '/api/participants/verify');
    assert.equal(options.method, 'POST');
    assert.equal(options.headers.Authorization, 'Bearer test-only');
    assert.equal(options.headers.Accept, 'application/json');
    assert.equal(options.redirect, 'error');
    assert.deepEqual(JSON.parse(options.body), {email: participant.email});
    return response(200, {participant});
  }});
  assert.deepEqual(result, participant);
});
test('HTTP allowed only for loopback in the emulator', () => {
  assert.equal(endpoint('http://127.0.0.1:8000/api/participants/verify', true).protocol, 'http:');
  for (const [url, emulator] of [
    ['http://127.0.0.1:8000', false], ['http://public.example.com', true],
    ['https://user:secret@example.com', true], ['not-a-url', true],
  ]) assert.throws(() => endpoint(url, emulator), {code: 'failed-precondition'});
});
test('missing token fails before network', async () => {
  await assert.rejects(fetchParticipant({...base, apiKey: '', fetchImpl: () => assert.fail()}), {code: 'failed-precondition'});
});
for (const [status, reason, expected] of [
  [401, 'UNAUTHENTICATED', 'failed-precondition'], [403, 'HTTPS_REQUIRED', 'failed-precondition'],
  [404, 'INTERNSHIP_APPLICATION_NOT_FOUND', 'permission-denied'], [422, 'INVALID_EMAIL', 'failed-precondition'],
  ...['AMBIGUOUS_PARTICIPANT', 'AMBIGUOUS_APPLICATION', 'PARTICIPANT_DATA_INCOMPLETE', 'INVALID_PERIOD', 'UNSUPPORTED_DECISION']
    .map((reason) => [409, reason, 'failed-precondition']),
]) {
  test(`${status} ${reason} denies access without retries or upstream message leaks`, async () => {
    let calls = 0;
    await assert.rejects(fetchParticipant({...base, fetchImpl: async () => {
      calls++;
      return response(status, {error: {code: reason, message: 'SECRET-UPSTREAM-DETAIL'}});
    }}), (error) => error.code === expected && !error.message.includes('SECRET-UPSTREAM-DETAIL'));
    assert.equal(calls, 1);
  });
}
test('500 retry bounded to one; failure never authorizes participant', async () => {
  let calls = 0;
  await assert.rejects(fetchParticipant({...base, fetchImpl: async () => {
    calls++; return response(500, {error: {code: 'SERVICE_UNAVAILABLE'}});
  }}), {code: 'unavailable'});
  assert.equal(calls, 2);
});
test('transient 503 followed by valid response recovers', async () => {
  let calls = 0;
  const result = await fetchParticipant({...base, fetchImpl: async () => ++calls === 1
    ? response(503, {}) : response(200, {participant})});
  assert.equal(result.id, '123'); assert.equal(calls, 2);
});
test('network timeout is retried at most once', async () => {
  let calls = 0;
  await assert.rejects(fetchParticipant({...base, fetchImpl: async () => { calls++; throw new Error('timeout'); }}), {code: 'unavailable'});
  assert.equal(calls, 2);
});
test('429 with long Retry-After returns safe retry metadata without an early retry', async () => {
  let calls = 0;
  await assert.rejects(fetchParticipant({...base, fetchImpl: async () => {
    calls++; return response(429, {}, {'Retry-After': '60'});
  }}), (error) => error.code === 'resource-exhausted' && error.details.retryAfterSeconds === 60);
  assert.equal(calls, 1);
});
test('short Retry-After is respected before the single retry', async () => {
  let calls = 0; const waits = [];
  await fetchParticipant({...base, sleep: async (ms) => waits.push(ms), fetchImpl: async () => ++calls === 1
    ? response(429, {}, {'Retry-After': '1'}) : response(200, {participant})});
  assert.deepEqual(waits, [1000]); assert.equal(calls, 2);
});
test('Retry-After supports HTTP dates', () => {
  assert.equal(retryAfterSeconds('Sun, 08 Nov 2026 00:01:00 GMT', Date.parse('2026-11-08T00:00:00Z')), 60);
  assert.equal(retryAfterSeconds('invalid'), null);
});
test('HTTP 200 never bypasses active status or inclusive period policy', async () => {
  for (const patch of [{is_active: undefined}, {is_active: 'true'}, {is_active: false},
    {status: 'pending'}, {end_date: '2026-11-07'}, {email: 123}]) {
    await assert.rejects(fetchParticipant({...base, fetchImpl: async () => response(200, {participant: {...participant, ...patch}})}));
  }
  for (const day of [participant.start_date, participant.end_date]) {
    await fetchParticipant({...base, day, fetchImpl: async () => response(200, {participant})});
  }
});
test('malformed 200 JSON or missing participant fails closed', async () => {
  await assert.rejects(fetchParticipant({...base, fetchImpl: async () => new Response('not-json', {status: 200})}), {code: 'unavailable'});
  await assert.rejects(fetchParticipant({...base, fetchImpl: async () => response(200, {})}));
});
