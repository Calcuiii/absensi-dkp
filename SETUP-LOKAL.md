# Persiapan lokal aplikasi presensi

Editor yang digunakan tetap Visual Studio Code. Proyek ini berisi Flutter dan Firebase; tidak ada perintah Composer, Artisan, atau Vite yang perlu dijalankan dari folder ini.

## Alat pengembangan

- Flutter/Dart dan Android SDK: pada mesin pengembangan ini berada di `C:\dev\si-melayur`.
- `scripts/dev-env.ps1`: mengatur PATH Flutter, Java 17 untuk Android, Android SDK, cache, Firebase CLI, dan FlutterFire CLI pada terminal aktif.
- `scripts/start-local-backend.ps1`: memakai Java bawaan Android Studio jika tersedia untuk menjalankan emulator Firebase.
- Node.js untuk pengembangan Functions; runtime deployment pada functions/package.json adalah Node.js 22. Mesin lokal memakai Node.js 24 sehingga pengujian runtime deployment tetap perlu diperiksa di CI.
- Android Studio dipakai untuk Android SDK dan emulator; kode bisa tetap diedit di VS Code.

Script lingkungan memuat lokasi khusus mesin ini. Anggota tim menyesuaikan lokasi SDK/Java/Flutter dengan instalasi masing-masing. SDK dan cache tidak perlu disalin ke repository.

## Mengaktifkan terminal

```powershell
. .\scripts\dev-env.ps1
flutter doctor -v
flutter devices
```

Buka emulator Android atau sambungkan HP dengan USB debugging sebelum menjalankan aplikasi.

## Demo aplikasi

```powershell
cd mobile
flutter pub get
flutter run --dart-define=APP_MODE=demo
```

Untuk demo admin, tambahkan `--dart-define=DEMO_ROLE=admin`. Mode demo menggunakan data contoh.

## Firebase dan API SI-MELAYUR lokal

Project pengembangan Firebase sudah terdaftar melalui alias dev. Setiap pengembang tetap memerlukan akses yang sesuai dan konfigurasi lokalnya sendiri. Jangan menyalin kredensial melalui Git atau chat.

- Salin `mobile/firebase-config.example.json` menjadi `mobile/firebase-config.local.json`, lalu isi konfigurasi aplikasi Firebase milik tim.
- `functions/.env.local` menyimpan SI_MELAYUR_URL.
- `functions/.secret.local` menyimpan SI_MELAYUR_API_KEY.
- Website/API Laravel SI-MELAYUR dijalankan di proyek KP-DKP yang terpisah, bukan dari folder ini.

Jalankan backend lokal dari root repository:

```powershell
.\scripts\start-local-backend.ps1
```

Di terminal terpisah:

```powershell
. .\scripts\dev-env.ps1
cd mobile
flutter run --dart-define-from-file=firebase-config.local.json --dart-define=USE_LOCAL_BACKEND=true
```

Untuk pemeriksaan HTTP lintas layanan, setelah Laravel dan emulator Firebase siap:

```powershell
node scripts/test-local-integration.cjs
```

Skrip memakai peserta uji dan identitas simulasi Auth emulator; tidak menggantikan uji login Google interaktif. Lihat [panduan integrasi](docs/INTEGRASI-SI-MELAYUR.md) untuk persiapan peserta dan token lokal.

## Pengujian dan APK

```powershell
npm.cmd ci --prefix functions
npm.cmd test --prefix functions
cd mobile
flutter analyze
flutter test --dart-define=USE_LOCAL_BACKEND=true
flutter build apk --debug --dart-define=APP_MODE=demo
```

APK berada di `mobile/build/app/outputs/flutter-apk/app-debug.apk`. Build dengan flag berbeda akan menghasilkan mode aplikasi berbeda pada lokasi output yang sama.

## Riwayat pembersihan

Backend Laravel presensi lama dan frontend Vite bawaannya dihapus dari root absensi-dkp pada 13 November 2026. Kode lama yang terlacak dapat ditemukan dalam riwayat Git. Arsip pemulihan lokal lengkap berada di `.local-backups/laravel-cleanup-2026-11-13/`; arsip ini diabaikan Git dan tidak boleh dibagikan karena dapat memuat rahasia lokal. Proyek KP-DKP terpisah tetap diperlukan untuk integrasi API peserta.
