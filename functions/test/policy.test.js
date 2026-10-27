'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const {jakartaDay, verifyParticipant, distanceMeters, validateLocation, attendanceChange} = require('../src/policy');

const now = new Date('2026-10-27T01:00:00Z');
const participant = {email: 'peserta@example.com', status: 'accepted', is_active: true,
  start_date: '2026-10-01', end_date: '2026-10-31'};
const office = {active: true, latitude: -7.25, longitude: 112.75, radiusMeters: 100, maxAccuracyMeters: 30};
const input = {latitude: -7.25, longitude: 112.75, accuracy: 10, isMocked: false, capturedAt: now.getTime()};
const code = (expected) => (error) => error.code === expected;

test('date follows Jakarta, including the UTC day boundary', () => {
  assert.equal(jakartaDay(new Date('2026-10-26T17:01:00Z')), '2026-10-27');
});
test('accepted participant is eligible on both inclusive period boundaries', () => {
  for (const day of ['2026-10-01', '2026-10-31']) {
    assert.equal(verifyParticipant(participant, 'PESERTA@example.com', day), participant);
  }
});
for (const [label, change] of Object.entries({
  'email mismatch': {email: 'other@example.com'},
  'not accepted': {status: 'pending'}, 'inactive': {is_active: false},
})) {
  test(`reject participant: ${label}`, () => {
    assert.throws(() => verifyParticipant({...participant, ...change}, participant.email, '2026-10-27'), code('permission-denied'));
  });
}
test('period is checked before and after the activity', () => {
  for (const day of ['2026-09-30', '2026-11-01']) {
    assert.throws(() => verifyParticipant(participant, participant.email, day), code('permission-denied'));
  }
});
test('invalid upstream dates never authorize attendance', () => {
  assert.throws(() => verifyParticipant({...participant, start_date: '2026-02-30'}, participant.email, '2026-10-27'), code('failed-precondition'));
});
test('distance uses geographic coordinates and accepts the office center', () => {
  assert.equal(validateLocation(input, office, now), 0);
  assert.ok(distanceMeters(-7.25, 112.75, -7.24, 112.75) > 1000);
});
for (const [label, change, expected] of [
  ['outside radius', {latitude: -7.24}, 'permission-denied'],
  ['mock location', {isMocked: true}, 'permission-denied'],
  ['poor accuracy', {accuracy: 31}, 'failed-precondition'],
  ['old sample', {capturedAt: now.getTime() - 60001}, 'failed-precondition'],
  ['future sample', {capturedAt: now.getTime() + 15001}, 'failed-precondition'],
  ['invalid latitude', {latitude: 91}, 'invalid-argument'],
  ['NaN accuracy', {accuracy: NaN}, 'invalid-argument'],
  ['string latitude', {latitude: '-7.25'}, 'invalid-argument'],
  ['missing mock signal', {isMocked: undefined}, 'invalid-argument'],
]) {
  test(`reject location: ${label}`, () => {
    assert.throws(() => validateLocation({...input, ...change}, office, now), code(expected));
  });
}
test('missing, inactive or invalid office never bypasses geofencing', () => {
  for (const config of [undefined, {...office, active: false}, {...office, radiusMeters: -1}]) {
    assert.throws(() => validateLocation(input, config, now), code('failed-precondition'));
  }
});
test('checkout without successful checkin is rejected', () => {
  assert.throws(() => attendanceChange(undefined, 'checkOut', input, now), code('failed-precondition'));
});
test('failed location does not consume the attendance slot', () => {
  assert.throws(() => validateLocation({...input, isMocked: true}, office, now));
  const result = attendanceChange(undefined, 'checkIn', input, now);
  assert.equal(result.duplicate, false);
  assert.equal(result.record.checkIn.at, now.toISOString());
});
test('retry after a lost response keeps the original server timestamp', () => {
  const original = attendanceChange(undefined, 'checkIn', input, now).record;
  const retry = attendanceChange(original, 'checkIn', input, new Date(now.getTime() + 1000));
  assert.equal(retry.duplicate, true);
  assert.deepEqual(retry.record, original);
  const checkout = attendanceChange(original, 'checkOut', input, now);
  assert.equal(checkout.record.checkIn.at, original.checkIn.at);
  assert.equal(checkout.duplicate, false);
});
test('unknown attendance stage is rejected', () => {
  assert.throws(() => attendanceChange(undefined, 'admin', input, now), code('invalid-argument'));
});
