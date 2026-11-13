'use strict';

const {PolicyError, verifyParticipant} = require('./policy');

function endpoint(value, emulator) {
  let url;
  try { url = new URL(value); } catch {
    throw new PolicyError('failed-precondition', 'Alamat API SI-MELAYUR belum dikonfigurasi.');
  }
  const loopback = ['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname);
  if (url.username || url.password || url.hash ||
      (url.protocol !== 'https:' && !(emulator && loopback && url.protocol === 'http:'))) {
    throw new PolicyError('failed-precondition', 'API harus menggunakan HTTPS; HTTP lokal hanya untuk Functions emulator.');
  }
  return url;
}

function retryAfterSeconds(value, now = Date.now()) {
  if (!value) return null;
  const seconds = /^\d+$/.test(value) ? Number(value) : (Date.parse(value) - now) / 1000;
  return Number.isFinite(seconds) ? Math.max(0, Math.ceil(seconds)) : null;
}

function upstreamError(status, body) {
  const reason = body?.error?.code;
  if (status === 401 || status === 403) {
    return new PolicyError('failed-precondition', 'Akses integrasi SI-MELAYUR belum diizinkan. Hubungi pengelola.');
  }
  if (status === 404) {
    return new PolicyError('permission-denied', 'Peserta atau pengajuan magang/PKL tidak ditemukan di SI-MELAYUR.');
  }
  if (status === 422) return new PolicyError('failed-precondition', 'Email peserta belum dapat diverifikasi oleh SI-MELAYUR.');
  if (status === 409) {
    const messages = {
      AMBIGUOUS_PARTICIPANT: 'Ada beberapa data peserta dengan email yang sama. Hubungi pengelola.',
      AMBIGUOUS_APPLICATION: 'Ada beberapa pengajuan magang/PKL dengan email yang sama. Hubungi pengelola.',
      PARTICIPANT_DATA_INCOMPLETE: 'Data resmi peserta belum lengkap. Hubungi pengelola SI-MELAYUR.',
      INVALID_PERIOD: 'Periode resmi peserta belum valid. Hubungi pengelola SI-MELAYUR.',
      UNSUPPORTED_DECISION: 'Keputusan penerimaan peserta belum dapat diverifikasi.',
    };
    return new PolicyError('failed-precondition', messages[reason] || 'Data SI-MELAYUR perlu diperiksa pengelola.');
  }
  if (status === 429) return new PolicyError('resource-exhausted', 'Batas permintaan SI-MELAYUR tercapai. Tunggu sebelum mencoba kembali.');
  return new PolicyError('unavailable', 'Layanan SI-MELAYUR belum dapat memverifikasi peserta. Coba kembali.');
}

async function fetchParticipant({url, apiKey, email, day, emulator = false,
  fetchImpl = fetch, sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms)),
  timeoutMs = 5000}) {
  const target = endpoint(url, emulator);
  if (typeof apiKey !== 'string' || !apiKey.trim()) {
    throw new PolicyError('failed-precondition', 'Kredensial integrasi SI-MELAYUR belum dikonfigurasi.');
  }
  // At most two requests, each including the response body in its timeout.
  for (let attempt = 0; attempt < 2; attempt++) {
    let response;
    let body;
    try {
      response = await fetchImpl(target, {
        method: 'POST', redirect: 'error', signal: AbortSignal.timeout(timeoutMs),
        headers: {'Content-Type': 'application/json', Accept: 'application/json', Authorization: `Bearer ${apiKey}`},
        body: JSON.stringify({email}),
      });
      body = await response.json();
    } catch {
      // A malformed successful response is not an eligible participant.
      if (response?.status === 200) {
        throw new PolicyError('unavailable', 'Respons peserta SI-MELAYUR tidak valid.');
      }
      if (!response) {
        if (attempt === 0) { await sleep(250); continue; }
        throw new PolicyError('unavailable', 'SI-MELAYUR tidak dapat dihubungi atau melewati batas waktu.');
      }
      // An error response may be HTML; still handle its HTTP status safely.
    }
    if (response.status === 200) return verifyParticipant(body?.participant, email, day);
    if (attempt === 0 && [500, 502, 503, 504].includes(response.status)) {
      await sleep(250);
      continue;
    }
    if (response.status === 429) {
      const wait = retryAfterSeconds(response.headers.get('retry-after'));
      // Never retry earlier than Retry-After. Longer/unknown waits return to the client.
      if (attempt === 0 && wait !== null && wait <= 1) {
        await sleep(wait * 1000);
        continue;
      }
      const error = upstreamError(429, body);
      if (wait !== null) error.details = {retryAfterSeconds: wait};
      throw error;
    }
    throw upstreamError(response.status, body);
  }
}

module.exports = {fetchParticipant, endpoint, retryAfterSeconds};
