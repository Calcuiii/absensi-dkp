# SI-MELAYUR — Presensi Mobile DKP Jatim

Aplikasi peserta dan Admin/PJ menggunakan **Flutter/Dart + Firebase Authentication, Cloud Firestore, Cloud Functions, dan Geolocator**. Data resmi peserta diverifikasi melalui API SI-MELAYUR dari proyek Laravel **KP-DKP yang terpisah**.

Backend Laravel presensi lama dan frontend Vite bawaannya sudah dibersihkan dari repository ini. Sumber UI awal berasal dari branch `mobile-karina`, commit `d632efb`.

## Struktur proyek

- `mobile/`: aplikasi Flutter, antarmuka demo dan antarmuka tersambung.
- `functions/`: backend Firebase, adapter API SI-MELAYUR, validasi presensi, dan tes server.
- `scripts/`: pengaturan alat dan pengujian integrasi lokal.
- `docs/`: arsitektur, panduan Firebase, dan integrasi SI-MELAYUR.
- `firebase.json`, `firestore.rules`, `firestore.indexes.json`, `storage.rules`: konfigurasi Firebase.

## Menjalankan demo

Dari folder repository, di terminal PowerShell VS Code:

```powershell
. .\scripts\dev-env.ps1
cd mobile
flutter pub get
flutter run --dart-define=APP_MODE=demo
```

Tambahkan `--dart-define=DEMO_ROLE=admin` untuk demo admin. Demo menggunakan data contoh dan tidak memerlukan API atau akun Firebase.

## Menjalankan integrasi lokal

Jalankan API Laravel dari proyek KP-DKP secara terpisah. Siapkan `functions/.env.local` dan `functions/.secret.local` mengikuti panduan integrasi. Dari root repository:

```powershell
.\scripts\start-local-backend.ps1
```

Di terminal lain:

```powershell
. .\scripts\dev-env.ps1
cd mobile
flutter run --dart-define-from-file=firebase-config.local.json --dart-define=USE_LOCAL_BACKEND=true
```

Mode debug lokal menggunakan Auth, Functions dan Firestore emulator. Google Sign-In native dan pemeriksaan kelayakan melalui Laravel telah dicoba secara interaktif. Tujuh pemeriksaan HTTP lintas layanan juga lulus menggunakan identitas simulasi di Auth emulator. Pengujian emulator bukan deployment produksi.

## Pengujian

```powershell
npm.cmd ci --prefix functions
npm.cmd test --prefix functions
cd mobile
flutter analyze
flutter test --dart-define=USE_LOCAL_BACKEND=true
```

Hasil terakhir sebelum pembersihan: 54 tes server dan 13 tes Flutter lulus. Beranda tersambung menampilkan akun terverifikasi, status presensi, riwayat, dan profil dari data server. Pengaturan lokasi kantor perlu disiapkan sebelum presensi lokasi berhasil diuji. Izin/lampiran, koreksi persisten, dan ekspor belum tersambung. Cloud Functions belum dideploy.

## Dokumentasi dan konfigurasi lokal

- [Persiapan lokal](SETUP-LOKAL.md)
- [Arsitektur](docs/ARSITEKTUR.md)
- [Panduan Firebase](docs/MULAI-FIREBASE.md)
- [Integrasi SI-MELAYUR](docs/INTEGRASI-SI-MELAYUR.md)

File `mobile/firebase-config.local.json`, `mobile/android/app/google-services.json`, `functions/.env.local`, `functions/.secret.local`, APK, cache, dan `.local-backups/` diabaikan Git. Jangan unggah arsip pemulihan lokal: arsip tersebut dapat berisi konfigurasi rahasia dari backend lama.
