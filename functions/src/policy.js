'use strict';

class PolicyError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

function reject(code, message) { throw new PolicyError(code, message); }

function jakartaDay(now) {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jakarta', year: 'numeric', month: '2-digit', day: '2-digit',
  }).format(now);
}

function verifyParticipant(participant, email, day) {
  const date = /^\d{4}-\d{2}-\d{2}$/;
  const validDate = (value) => typeof value === 'string' && date.test(value)
    && !Number.isNaN(Date.parse(value))
    && new Date(value).toISOString().slice(0, 10) === value;
  if (!participant || participant.email?.toLowerCase() !== email.toLowerCase()
      || participant.status !== 'accepted' || participant.is_active !== true) {
    reject('permission-denied', 'Peserta belum diterima atau tidak aktif di SI-MELAYUR.');
  }
  if (!validDate(participant.start_date) || !validDate(participant.end_date)
      || participant.start_date > participant.end_date) {
    reject('failed-precondition', 'Periode peserta dari SI-MELAYUR tidak valid.');
  }
  if (day < participant.start_date || day > participant.end_date) {
    reject('permission-denied', 'Tanggal saat ini berada di luar periode kegiatan peserta.');
  }
  return participant;
}

const numberIn = (value, min, max) => typeof value === 'number'
  && Number.isFinite(value) && value >= min && value <= max;

function distanceMeters(lat1, lon1, lat2, lon2) {
  const radians = (value) => value * Math.PI / 180;
  const a = Math.sin(radians(lat2 - lat1) / 2) ** 2
    + Math.cos(radians(lat1)) * Math.cos(radians(lat2))
    * Math.sin(radians(lon2 - lon1) / 2) ** 2;
  return 6371000 * 2 * Math.asin(Math.sqrt(Math.min(1, Math.max(0, a))));
}

function validateLocation(input, office, now) {
  if (!office || office.active !== true
      || !numberIn(office.latitude, -90, 90)
      || !numberIn(office.longitude, -180, 180)
      || !numberIn(office.radiusMeters, 1, 5000)
      || !numberIn(office.maxAccuracyMeters, 1, 1000)) {
    reject('failed-precondition', 'Lokasi kantor belum dikonfigurasi dengan benar.');
  }
  if (!numberIn(input.latitude, -90, 90) || !numberIn(input.longitude, -180, 180)
      || !numberIn(input.accuracy, 0, 10000) || typeof input.isMocked !== 'boolean'
      || !numberIn(input.capturedAt, 0, Number.MAX_SAFE_INTEGER)) {
    reject('invalid-argument', 'Bukti lokasi tidak lengkap atau tidak valid.');
  }
  const age = now.getTime() - input.capturedAt;
  if (age < -15000 || age > 60000) {
    reject('failed-precondition', 'Bukti lokasi sudah usang. Ambil lokasi kembali.');
  }
  if (input.isMocked) reject('permission-denied', 'Perangkat melaporkan indikasi mock location.');
  if (input.accuracy > office.maxAccuracyMeters) {
    reject('failed-precondition', 'Akurasi lokasi belum memadai. Coba di area terbuka.');
  }
  const distance = distanceMeters(input.latitude, input.longitude, office.latitude, office.longitude);
  if (distance > office.radiusMeters) reject('permission-denied', 'Posisi berada di luar area presensi.');
  return distance;
}

function attendanceChange(previous, stage, sample, now) {
  if (!['checkIn', 'checkOut'].includes(stage)) reject('invalid-argument', 'Jenis presensi tidak valid.');
  // Same day/stage retries return the original result, including after a lost response.
  if (previous?.[stage]) return {record: previous, duplicate: true};
  if (stage === 'checkOut' && !previous?.checkIn) {
    reject('failed-precondition', 'Lakukan presensi masuk terlebih dahulu.');
  }
  return {
    record: {...previous, [stage]: {...sample, at: now.toISOString()}},
    duplicate: false,
  };
}

module.exports = {PolicyError, jakartaDay, verifyParticipant, distanceMeters, validateLocation, attendanceChange};
