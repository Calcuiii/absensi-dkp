'use strict';

const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret, defineString} = require('firebase-functions/params');
const {PolicyError, jakartaDay, verifyParticipant, validateLocation, attendanceChange} = require('./policy');

initializeApp();
const db = getFirestore();
const apiKey = defineSecret('SI_MELAYUR_API_KEY');
const apiUrl = defineString('SI_MELAYUR_URL', {default: ''});

function identity(request) {
  const auth = request.auth;
  if (!auth || auth.token.email_verified !== true || !auth.token.email
      || auth.token.firebase?.sign_in_provider !== 'google.com') {
    throw new HttpsError('unauthenticated', 'Masuk menggunakan akun Google yang terverifikasi.');
  }
  return {uid: auth.uid, email: auth.token.email.toLowerCase()};
}

async function participantFor(email, day) {
  let url;
  try {
    url = new URL(apiUrl.value());
    if (url.protocol !== 'https:') throw new Error('https required');
  } catch {
    throw new HttpsError('failed-precondition', 'Integrasi SI-MELAYUR belum dikonfigurasi.');
  }
  let response;
  try {
    // Proposed adapter contract; map this payload when the actual API is supplied.
    response = await fetch(url, {
      method: 'POST', redirect: 'error', signal: AbortSignal.timeout(8000),
      headers: {'Content-Type': 'application/json', Authorization: `Bearer ${apiKey.value()}`},
      body: JSON.stringify({email}),
    });
  } catch {
    throw new HttpsError('unavailable', 'SI-MELAYUR tidak dapat dihubungi. Coba kembali.');
  }
  if (response.status === 404) throw new HttpsError('permission-denied', 'Email tidak terdaftar di SI-MELAYUR.');
  if (!response.ok) throw new HttpsError('unavailable', 'Pemeriksaan SI-MELAYUR belum berhasil.');
  let body;
  try { body = await response.json(); } catch {
    throw new HttpsError('unavailable', 'Respons SI-MELAYUR tidak valid.');
  }
  return verifyParticipant(body.participant, email, day);
}

function callable(handler) {
  return onCall({region: 'asia-southeast2', secrets: [apiKey], timeoutSeconds: 30}, async (request) => {
    try { return await handler(request); } catch (error) {
      if (error instanceof HttpsError) throw error;
      if (error instanceof PolicyError) throw new HttpsError(error.code, error.message);
      // Do not expose API credentials, email addresses or location in logs/errors.
      throw new HttpsError('internal', 'Permintaan belum dapat diproses. Silakan coba lagi.');
    }
  });
}

async function access(request) {
  const user = identity(request);
  const role = (await db.doc(`users/${user.uid}`).get()).data()?.role;
  if (role === 'admin') return {...user, role};
  const participant = await participantFor(user.email, jakartaDay(new Date()));
  await db.doc(`users/${user.uid}`).set({email: user.email, role: 'participant'}, {merge: true});
  return {...user, role: 'participant', name: participant.full_name || user.email};
}

exports.verifyAccess = callable(access);

exports.recordAttendance = callable(async (request) => {
  const user = identity(request);
  const now = new Date();
  const day = jakartaDay(now);
  // Revalidate the official participant status for BOTH check-in and check-out.
  await participantFor(user.email, day);
  const input = request.data || {};
  const ref = db.doc(`users/${user.uid}/attendances/${day}`);
  return db.runTransaction(async (tx) => {
    const [officeSnapshot, previousSnapshot] = await Promise.all([
      tx.get(db.doc('settings/office')), tx.get(ref),
    ]);
    const distance = validateLocation(input, officeSnapshot.data(), now);
    const {record, duplicate} = attendanceChange(previousSnapshot.data(), input.stage, {
      latitude: input.latitude, longitude: input.longitude,
      accuracy: input.accuracy, isMocked: input.isMocked, distanceMeters: distance,
    }, now);
    if (!duplicate) tx.set(ref, {...record, uid: user.uid, date: day});
    return {date: day, ...record, duplicate};
  });
});

exports.getMyAttendance = callable(async (request) => {
  const user = identity(request);
  await participantFor(user.email, jakartaDay(new Date()));
  const snapshot = await db.collection(`users/${user.uid}/attendances`)
    .orderBy('date', 'desc').limit(31).get();
  return {records: snapshot.docs.map((doc) => doc.data())};
});

exports.getAdminAttendance = callable(async (request) => {
  const user = identity(request);
  const role = (await db.doc(`users/${user.uid}`).get()).data()?.role;
  if (role !== 'admin') throw new HttpsError('permission-denied', 'Akses khusus Admin/PJ.');
  const day = jakartaDay(new Date());
  const snapshot = await db.collectionGroup('attendances').where('date', '==', day).limit(200).get();
  return {date: day, records: snapshot.docs.map((doc) => doc.data()), limited: snapshot.size === 200};
});
