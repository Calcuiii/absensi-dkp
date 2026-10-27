# Mulai Firebase dari nol

Firebase adalah layanan backend yang dikelola Google. Dalam proyek ini Authentication menangani login, Firestore menyimpan data, dan Cloud Functions memeriksa aturan sebelum presensi disimpan. Kamu tidak perlu menjalankan Laravel untuk alur baru.

Editor tetap **Visual Studio Code**. Buka folder proyek seperti biasa, gunakan ekstensi Flutter/Dart, dan jalankan perintah di terminal VS Code. Firebase Console hanya dibuka di browser untuk pengaturan layanan. Android Studio bukan syarat editor; HP Android dapat digunakan untuk menjalankan aplikasi.

## 1. Coba demo terlebih dahulu

Dari folder `absensi-dkp`:

```powershell
. .\scripts\dev-env.ps1
Set-Location mobile
flutter pub get
flutter run --dart-define=APP_MODE=demo
```

Hubungkan HP Android dengan USB debugging. Untuk demo admin tambahkan `--dart-define=DEMO_ROLE=admin`. Data contoh tidak dikirim ke Firebase. Mode demo bukan bukti bahwa autentikasi atau GPS nyata telah berfungsi.

## 2. Buat project milik tim

1. Buka [Firebase Console](https://console.firebase.google.com/) dengan akun Google pengelola tim.
2. Buat project khusus pengembangan, misalnya nama `SI-MELAYUR Capstone Dev`. Catat **Project ID** yang ditampilkan; jangan menebaknya dari nama project.
3. Google Analytics tidak dibutuhkan oleh implementasi ini.
4. Tambahkan anggota tim dari pengaturan akses sesuai kebutuhan. Jangan berbagi kata sandi akun Google.

Demo dan pengujian lokal dapat dijalankan tanpa mengaktifkan pembayaran. Deployment Cloud Functions memerlukan paket **Blaze (pay as you go)**. Putuskan bersama tim sebelum mengaktifkannya, lihat kuota dan atur pemberitahuan anggaran; pemberitahuan anggaran bukan batas belanja otomatis. Belum ada billing atau resource cloud yang dibuat oleh pekerjaan ini.

## 3. Daftarkan aplikasi Android dan aktifkan Google

1. Tambahkan aplikasi Android di project. ID Android kode saat ini: `com.example.si_melayur` (sementara). Jika ID final berbeda, ubah `applicationId`, namespace, package serta lokasi `MainActivity.kt` bersama-sama sebelum mendaftarkan aplikasi final.
2. Di komputer pengembangan, dapatkan fingerprint sertifikat debug dari `mobile/android` dengan `.\gradlew.bat signingReport` setelah mengaktifkan script lingkungan. Daftarkan SHA-1 dan SHA-256 yang sesuai. Sertifikat rilis didaftarkan tersendiri nanti.
3. Aktifkan Authentication → penyedia **Google**, lalu tentukan email dukungan.
4. Ambil API key, Android app ID (bentuk `1:...:android:...`), Project ID, dan messaging sender ID dari pengaturan project. Ambil OAuth **Web client ID** dari konfigurasi Google Sign-In pada project yang sama. Web client ID berbeda dari Android client ID.
5. Salin `mobile/firebase-config.example.json` menjadi `mobile/firebase-config.local.json` dan isi nilai tersebut. File lokal diabaikan Git. Nilai konfigurasi Firebase bukan service-account private key; jangan menaruh rahasia server di file ini.

Kode menggunakan `Firebase.initializeApp(options: ...)` secara eksplisit sehingga tidak mengharuskan file `firebase_options.dart`. Google Sign-In Android memakai Web client ID melalui `serverClientId`. Jangan menjalankan `firebase init` ulang hingga menimpa konfigurasi repository.

## 4. Buat Firestore dengan akses tertutup

1. Buat database Firestore default untuk project pengembangan, pilih mode production dan lokasi yang disepakati tim. Lokasi fungsi pada kode adalah Jakarta `asia-southeast2`; usahakan lokasi data selaras. Lokasi database bukan keputusan yang dapat diubah sembarangan setelah dibuat.
2. Buat dokumen `settings/office` melalui console dengan field berikut, menggunakan nilai kantor yang telah diverifikasi:

| Field | Tipe | Isi |
|---|---|---|
| `active` | boolean | `true` setelah konfigurasi siap |
| `latitude` | number | Lintang titik presensi resmi |
| `longitude` | number | Bujur titik presensi resmi |
| `radiusMeters` | number | Radius hasil kesepakatan/pengujian |
| `maxAccuracyMeters` | number | Ambang akurasi hasil pengujian |

Tidak perlu membuat Storage untuk menguji presensi inti; lampiran izin belum tersambung. Jangan mengubah rules menjadi `allow read, write: if true` untuk mengatasi error akses.

## 5. Hubungkan SI-MELAYUR bersama pengelolanya

Minta dokumentasi endpoint HTTPS, metode autentikasi server, dan akun peserta uji. Kontrak usulan terdapat di [ARSITEKTUR.md](ARSITEKTUR.md). Bila format sebenarnya berbeda, adapter harus diubah dan diuji terlebih dahulu.

Tanpa API resmi, mode Firebase tidak dapat menyatakan peserta aktif. Jangan memasukkan email sembarang sebagai peserta sah untuk data operasional.

## 6. Siapkan dan pasang layanan ketika tim siap

Dari folder `absensi-dkp`, setelah keputusan biaya dan akses disepakati:

```powershell
. .\scripts\dev-env.ps1
firebase login
firebase use --add
Set-Location functions
npm.cmd ci
npm.cmd test
Set-Location ..
```

Pilih project tim yang benar pada `firebase use --add`. Runtime deployment adalah Node.js 22. Tes lokal mesin ini dijalankan dengan Node.js 24; gunakan Node.js 22 pada CI/emulator untuk menyamai deployment.

Salin `functions/.env.example` menjadi `functions/.env` dan isi **alamat API HTTPS nyata** pada `SI_MELAYUR_URL`. Simpan kunci API sebagai secret dengan perintah interaktif berikut; jangan menaruh nilainya di chat/Git:

```powershell
firebase functions:secrets:set SI_MELAYUR_API_KEY
firebase deploy --only functions,firestore
```

Perintah deploy di atas belum dijalankan. Jika nanti Storage diaktifkan, pasang juga rules tertutup melalui `firebase deploy --only storage` sebelum penggunaan lampiran. Cloud Functions memvalidasi token, dan fungsi sendiri memeriksa Google, email terverifikasi, serta peran admin.

## 7. Jalankan aplikasi tersambung

```powershell
Set-Location mobile
flutter run --dart-define-from-file=firebase-config.local.json
```

Gunakan akun Google peserta uji yang dikenal SI-MELAYUR. Untuk admin, pengelola membuat dokumen `users/{Firebase-UID}` dengan `role` bernilai `admin` melalui console setelah akun Google tercatat di Authentication. Jangan memberikan peran admin kepada pengguna dari formulir aplikasi.

## 8. Pengujian sebelum dipakai tim

- Peserta diterima/aktif dalam periode boleh login; peserta belum diterima atau di luar periode ditolak.
- Masuk/pulang diuji pada lokasi valid, di luar radius, izin lokasi ditolak, GPS kurang akurat, dan offline.
- Presensi pulang tanpa masuk ditolak. Pengiriman ulang atau bersamaan tidak menggandakan catatan.
- Waktu tercatat berasal dari server dan tanggal mengikuti WIB; ganti jam ponsel untuk memastikan bukti usang/masa depan ditahan.
- Peserta tidak dapat memakai endpoint admin atau membaca data peserta lain. Perubahan role di ponsel tidak memengaruhi otorisasi server.
- Riwayat harus sesuai catatan Firestore. Pesan sukses hanya muncul setelah konfirmasi server.

Untuk pemeriksaan lokal tanpa akun Firebase:

```powershell
node --test functions/test/*.test.js
Set-Location mobile
flutter analyze
flutter test
flutter build apk --debug --dart-define=APP_MODE=demo
```

## Dokumentasi resmi

- [Setup Firebase Flutter](https://firebase.google.com/docs/flutter/setup)
- [Google login pada Flutter](https://firebase.google.com/docs/auth/flutter/federated-auth)
- [Mulai Cloud Functions dan kebutuhan Blaze](https://firebase.google.com/docs/functions/get-started)
- [Paket biaya Firebase](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans)
