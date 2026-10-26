# SI-MELAYUR — Flutter UI/UX Prototype

Prototype lengkap UI mobile Android untuk presensi peserta Magang, KP, dan PKL di Dinas Kelautan dan Perikanan Provinsi Jawa Timur.

## Jalankan

```bash
flutter pub get
flutter run -d chrome
```

Untuk Android:

```bash
flutter devices
flutter run
```

## Struktur

- `lib/screens/common/` — Splash, Login, Pemeriksaan Akses
- `lib/screens/participant/` — Beranda, Presensi, Riwayat, Izin/Sakit, Profil
- `lib/screens/admin/` — Ringkasan, Data Presensi, Detail Peserta, Koreksi, Profil
- `lib/widgets/` — komponen reusable
- `lib/theme/` — warna dan theme
- `lib/data/` — data contoh
- `lib/models/` — model sederhana

## Menguji role Admin/PJ

Buka `lib/data/demo_data.dart` dan ubah:

```dart
const UserRole demoRole = UserRole.participant;
```

menjadi:

```dart
const UserRole demoRole = UserRole.admin;
```

Role ini hanya untuk prototype. Aplikasi final tidak menyediakan pilihan bebas role; role harus datang dari autentikasi/integrasi SI-MELAYUR.

## Kondisi presensi

Halaman proses presensi menyediakan preview untuk seluruh kondisi penting: mengambil lokasi, valid, di luar area, akurasi buruk, izin lokasi, layanan lokasi, indikasi lokasi simulasi, offline, berhasil, dan sudah tercatat.

## Catatan asumsi

- Jam masuk 07.30 WIB dan jam pulang 15.30 WIB.
- Toleransi keterlambatan 15 menit sampai 07.45 WIB adalah **asumsi prototype dan harus dikonfirmasi**.
- Radius dan titik koordinat pada peta adalah placeholder.
- CSV/Excel adalah usulan format rekap dan perlu dikonfirmasi.
- Google Login, API SI-MELAYUR, Firestore, geofencing produksi, dan mock-location detection produksi belum dihubungkan.
- Tidak ada face recognition, QR code, validasi WiFi, WFH/WFA, chat internal, manajemen tugas, atau pendaftaran magang.
