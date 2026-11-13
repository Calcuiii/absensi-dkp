'use strict';

// Only local emulator URLs are used. No token or raw response is printed.
const fs = require('node:fs');
const path = require('node:path');
const project = 'si-melayur-capstone-dev';
const authBase = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1';
const functionsBase = `http://127.0.0.1:5001/${project}/asia-southeast2`;
const email = 'salsa.bpp10@gmail.com';

async function jsonPost(url, body, token) {
  const response = await fetch(url, {method: 'POST', signal: AbortSignal.timeout(20000),
    headers: {'Content-Type': 'application/json', ...(token ? {Authorization: `Bearer ${token}`} : {})},
    body: JSON.stringify(body)});
  return {status: response.status, body: await response.json()};
}

async function main() {
  const results = [];
  let idToken;
  async function check(name, action) {
    const ok = await action();
    results.push({name, passed: Boolean(ok)});
    console.log(`${ok ? 'PASS' : 'FAIL'} ${name}`);
    if (!ok) throw new Error('Integration assertion failed');
  }
  try {
    await check('Laravel returns accepted active application 4 for the configured test account', async () => {
      const config = {};
      for (const line of fs.readFileSync(path.resolve(__dirname, '../functions/.secret.local'), 'utf8').split(/\r?\n/)) {
        const match = line.match(/^([A-Z_]+)=(.*)$/);
        if (match) config[match[1]] = match[2].trim();
      }
      const r = await jsonPost('http://127.0.0.1:8000/api/participants/verify', {email}, config.SI_MELAYUR_API_KEY);
      return r.status === 200 && r.body.participant?.id === '4'
        && r.body.participant?.is_active === true && r.body.participant?.status === 'accepted';
    });
    await check('Anonymous callable request denied', async () => {
      const r = await jsonPost(`${functionsBase}/verifyAccess`, {data: {role: 'admin', email}});
      return r.status === 401 && r.body.error?.status === 'UNAUTHENTICATED';
    });
    // This is deliberately a SIMULATED Google identity, not a real Google login.
    const mockGoogle = JSON.stringify({sub: 'attendance-local-contract-test', email, email_verified: true});
    const auth = await jsonPost(`${authBase}/accounts:signInWithIdp?key=emulator-only`, {
      requestUri: 'http://localhost', postBody: new URLSearchParams({providerId: 'google.com', id_token: mockGoogle}).toString(),
      returnSecureToken: true,
    });
    if (auth.status !== 200 || !auth.body.idToken) throw new Error('Auth emulator identity setup failed');
    idToken = auth.body.idToken;
    await check('Functions -> real local Laravel accepts the eligible test participant', async () => {
      const r = await jsonPost(`${functionsBase}/verifyAccess`, {data: {}}, idToken);
      return r.status === 200 && r.body.result?.role === 'participant' && r.body.result?.email === email;
    });
    await check('Participant attendance history is accessible through local Functions', async () => {
      const r = await jsonPost(`${functionsBase}/getMyAttendance`, {data: {}}, idToken);
      return r.status === 200 && Array.isArray(r.body.result?.records);
    });
    await check('Participant cannot acquire admin access via request payload', async () => {
      const r = await jsonPost(`${functionsBase}/getAdminAttendance`, {data: {role: 'admin'}}, idToken);
      return r.status === 403 && r.body.error?.status === 'PERMISSION_DENIED';
    });
    await check('Eligible participant still cannot record without valid office configuration', async () => {
      const r = await jsonPost(`${functionsBase}/recordAttendance`, {data: {stage: 'checkIn'}}, idToken);
      return r.status === 400 && r.body.error?.status === 'FAILED_PRECONDITION'
        && r.body.error?.message?.includes('kantor');
    });
    await check('No attendance was created by the rejected request', async () => {
      const r = await jsonPost(`${functionsBase}/getMyAttendance`, {data: {}}, idToken);
      return r.status === 200 && r.body.result?.records?.length === 0;
    });
  } finally {
    if (idToken) await jsonPost(`${authBase}/accounts:delete?key=emulator-only`, {idToken}).catch(() => {});
    const report = {timestamp: new Date().toISOString(), identity: 'SIMULATED_GOOGLE_IN_AUTH_EMULATOR',
      realGoogleLoginTested: false, laravel: 'loopback:8000', results};
    const reportDir = path.resolve(__dirname, '../.local-backups/integration');
    fs.mkdirSync(reportDir, {recursive: true});
    fs.writeFileSync(path.join(reportDir, 'latest-report.json'), JSON.stringify(report, null, 2));
  }
}

main().catch(() => { console.error('Local integration test did not complete. No credentials printed.'); process.exitCode = 1; });
