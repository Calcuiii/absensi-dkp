> Pembaruan 27 Oktober 2026: arsitektur aktif mengikuti Flutter + Firebase. UI Karina sudah disatukan di mobile/. Laravel di root adalah referensi lama. Mulai dari docs/MULAI-FIREBASE.md dan docs/ARSITEKTUR.md. Informasi pemeriksaan kerangka awal di bawah adalah catatan 22 Oktober, bukan hasil uji fitur Firebase terbaru.
# Persiapan pengembangan SI-MELAYUR

Alat pengembangan disimpan di `C:\dev\si-melayur`. Lokasi ini tidak memiliki spasi agar kompatibel dengan alat Android. SDK, cache, dan kredensial lokal tidak perlu dimasukkan ke Git.

## Alat yang terpasang

- Flutter 3.47.7 stable dan Dart 3.13.5.
- Temurin Java 17.0.20.1.
- Android SDK Platform 36 dan 34, Build Tools 36.0.0, Platform Tools 37.0.1, NDK 28.2.13676358, CMake 3.22.1, dan command-line tools.
- Firebase CLI 15.34.1 dan FlutterFire CLI 1.4.1.
- Ekstensi VS Code Flutter dan Dart 3.144.0.
- PHP 8.4.25, Composer 2.10.2, Node.js 24.21.0, dan Git dari instalasi yang sudah tersedia.

## Membuka terminal pengembangan

Dari folder repository, jalankan PowerShell:

```powershell
. .\scripts\dev-env.ps1
flutter doctor -v
```

Script mengaktifkan Flutter, Dart, Java, Android SDK, Firebase CLI, dan FlutterFire CLI untuk terminal yang sedang digunakan. Tidak perlu mengganti PATH Windows secara global.

Script juga menentukan lokasi socket sementara Java yang pendek untuk menghindari error `Unable to establish loopback connection` pada Gradle di mesin ini.

## Struktur

- Root repository: backend Laravel 12 yang sudah ada, bukan keputusan backend final.
- `mobile/`: kerangka aplikasi Flutter Android untuk peserta dan Admin/PJ dalam aplikasi yang sama.
- `scripts/dev-env.ps1`: pengaturan alat pengembangan lokal.
- `package-lock.json`: versi dependensi frontend bawaan Laravel.

## Rancangan teknologi

Mobile menggunakan Flutter/Dart. Paket yang dipersiapkan: `firebase_core`, `firebase_auth`, `google_sign_in`, `cloud_firestore`, `firebase_storage`, `geolocator`, `http`, `image_picker`, dan `intl`.

Tidak ada paket geofencing latar belakang: jarak dari titik kantor dapat dihitung dengan Geolocator saat presensi. Backend tetap harus memeriksa hak akses, periode, waktu server, koordinat, akurasi, dan aturan presensi sebelum penyimpanan. Indikator mock location dari perangkat merupakan sinyal tambahan, bukan bukti keaslian lokasi.

## Konfigurasi Firebase yang masih diperlukan

1. Tentukan Firebase project milik tim dan application ID Android final. `com.example.si_melayur` hanya ID sementara kerangka awal.
2. Masuk lewat `firebase login`, lalu dari `mobile/` jalankan `flutterfire configure --platforms=android --project=ID_PROJECT` setelah memilih project yang benar.
3. Aktifkan Google Sign-In, Firestore, dan Storage pada project tersebut. Tentukan lokasi data dan tinjau biaya sebelum membuat resource.
4. Daftarkan fingerprint SHA-1/SHA-256 sertifikat debug dan nantinya sertifikat rilis untuk login Google Android.
5. Siapkan aturan Firestore/Storage dan validasi backend sebelum menghubungkan data nyata. Service account dan kunci penandatanganan tidak boleh masuk Git.

Langkah yang membutuhkan akun/resource cloud belum dijalankan. Firebase belum diinisialisasi dalam kode aplikasi. Belum ada deployment atau perubahan pada layanan SI-MELAYUR.

## Menjalankan kerangka mobile

```powershell
. .\scripts\dev-env.ps1
Set-Location mobile
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```

Untuk `flutter run`, hubungkan HP Android dengan USB debugging aktif dan izinkan koneksinya di HP. Periksa dengan `flutter devices`. Android Studio/emulator bukan syarat untuk membuat APK lewat alat yang dipasang ini; emulator belum disiapkan.

## Backend yang sudah ada

PHP dan Composer menggunakan instalasi Herd yang sudah tersedia. Dependensi dipasang berdasarkan `composer.lock`; `.env` lokal dibuat dari contoh dan application key dibuat tanpa menampilkan nilainya. Tidak ada migrasi atau seeding database yang dijalankan.

```powershell
composer install
php artisan test
php artisan serve --host=127.0.0.1
```

Backend saat ini memakai Sanctum dan model database Laravel. Endpoint Google login menerima email dari request; integrasi Firebase ID token belum ada. Route admin juga belum memiliki middleware autentikasi di deklarasi route. Bagian ini perlu ditinjau sebelum penggunaan data nyata dan sebelum memutuskan arsitektur final Laravel atau Cloud Functions.

## Pemeriksaan awal

- Branch persiapan: `chore/setup-development-environment`. Pekerjaan baru wajib diawali dengan branch baru sesuai `AGENTS.md`.
- `flutter doctor -v`: tidak menemukan masalah lingkungan.
- `flutter analyze`: tidak menemukan masalah kode pada kerangka awal.
- `flutter test`: pengujian bawaan kerangka awal lulus; ini belum menguji fitur presensi.
- `flutter build apk --debug`: berhasil. Hasilnya `mobile/build/app/outputs/flutter-apk/app-debug.apk`, yaitu APK debug kerangka awal, bukan aplikasi presensi yang sudah selesai.
- Backend: 8 pengujian, 18 assertion lulus; build frontend bawaan Laravel juga berhasil.

## Dokumentasi resmi

- Flutter: https://docs.flutter.dev/install/manual
- Android SDK: https://developer.android.com/tools
- FlutterFire: https://firebase.google.com/docs/flutter/setup
