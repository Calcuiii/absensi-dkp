import '../models/models.dart';

/// Untuk menguji tampilan Admin/PJ,
/// ubah demoRole menjadi UserRole.admin.
const UserRole demoRole = UserRole.participant;

const participant = Participant(
  name: 'Andi Pratama',
  email: 'andi.pratama@gmail.com',
  institution: 'Universitas Airlangga',
  activity: 'Magang',
  supervisor: 'Budi Santoso, S.Pi',
  startDate: '15 Oktober 2026',
  endDate: '15 Desember 2026',
  placement: 'DKP Provinsi Jawa Timur, Surabaya',
  status: 'Sedang Berlangsung',
);

const attendanceRecords = [
  AttendanceRecord(
    date: '26 Okt 2026',
    checkIn: '07.28',
    checkOut: '15.32',
    status: AttendanceStatus.onTime,
  ),
  AttendanceRecord(
    date: '23 Okt 2026',
    checkIn: '07.45',
    checkOut: '15.31',
    status: AttendanceStatus.late,
  ),
  AttendanceRecord(
    date: '22 Okt 2026',
    checkIn: '07.30',
    checkOut: '15.29',
    status: AttendanceStatus.onTime,
  ),
  AttendanceRecord(
    date: '21 Okt 2026',
    checkIn: '-',
    checkOut: '-',
    status: AttendanceStatus.permission,
    note: 'Izin keperluan',
  ),
  AttendanceRecord(
    date: '20 Okt 2026',
    checkIn: '07.32',
    checkOut: '15.28',
    status: AttendanceStatus.onTime,
  ),
];

const adminParticipants = [
  AdminParticipant(
    name: 'Andi Pratama',
    activity: 'Magang',
    institution: 'Universitas Airlangga',
    checkIn: '07.28',
    checkOut: '15.32',
    status: AttendanceStatus.onTime,
  ),
  AdminParticipant(
    name: 'Siti Rahma',
    activity: 'PKL',
    institution: 'SMK PGRI PAL',
    checkIn: '07.45',
    checkOut: '15.30',
    status: AttendanceStatus.late,
  ),
  AdminParticipant(
    name: 'Budi Setiawan',
    activity: 'Magang',
    institution: 'ITS',
    checkIn: '-',
    checkOut: '-',
    status: AttendanceStatus.permission,
  ),
  AdminParticipant(
    name: 'Citra Lestari',
    activity: 'KP',
    institution: 'UPN Veteran Jawa Timur',
    checkIn: '-',
    checkOut: '-',
    status: AttendanceStatus.empty,
  ),
];