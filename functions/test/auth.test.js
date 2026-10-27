'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const handlers = require('../src/index');

for (const [name, handler] of Object.entries(handlers)) {
  test(`${name}: forged email/role in payload cannot replace authentication`, async () => {
    await assert.rejects(handler.run({data: {email: 'admin@example.com', role: 'admin'}}),
      (error) => error.code === 'unauthenticated');
  });
  test(`${name}: non-Google credentials are rejected before data access`, async () => {
    await assert.rejects(handler.run({auth: {uid: 'fake', token: {
      email: 'admin@example.com', email_verified: true, firebase: {sign_in_provider: 'password'},
    }}, data: {role: 'admin'}}), (error) => error.code === 'unauthenticated');
  });
  test(`${name}: unverified Google email is rejected`, async () => {
    await assert.rejects(handler.run({auth: {uid: 'fake', token: {
      email: 'admin@example.com', email_verified: false, firebase: {sign_in_provider: 'google.com'},
    }}, data: {}}), (error) => error.code === 'unauthenticated');
  });
}
