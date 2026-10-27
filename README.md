# SI-MELAYUR — Presensi Mobile DKP Jatim

Arsitektur pengembangan: **Flutter/Dart + Firebase Authentication (Google) + Cloud Firestore + Cloud Functions + Geolocator**, dengan verifikasi peserta melalui API SI-MELAYUR.

Keputusan ini mengikuti rencana teknologi awal dan arahan pemilik proyek pada 27 Oktober 2026. Laravel yang sudah ada dipertahankan sebagai referensi; aplikasi baru tidak menggunakan login Sanctum atau database Laravel.

## Mulai

```powershell
. .\scripts\dev-env.ps1
Set-Location mobile
flutter pub get
flutter run --dart-define=APP_MODE=demo
```

Untuk tampilan admin: tambahkan `--dart-define=DEMO_ROLE=admin`. Tanpa mode demo, aplikasi memerlukan konfigurasi Firebase. Jika konfigurasi belum ada, aplikasi menampilkan petunjuk dan pilihan membuka demo secara eksplisit.

## Struktur

- `mobile/`: satu aplikasi Flutter Android; UI awal diambil dari branch `mobile-karina` commit `d632efb` dan disatukan dengan kerangka Android lokal.
- `functions/`: validasi peserta/lokasi, penyimpanan presensi, riwayat, dan rekap admin melalui Firebase.
- `firestore.rules`, `storage.rules`: akses klien langsung tertutup; data bisnis diakses melalui fungsi server.
- `docs/ARSITEKTUR.md`: keputusan arsitektur, pemetaan teknologi, kontrak integrasi, serta status fitur.
- `docs/MULAI-FIREBASE.md`: panduan Firebase untuk pemula.
- `app/`, `routes/`, `database/`, `tests/`, `composer.*`: implementasi Laravel lama sebagai referensi, terpisah dari runtime Firebase.

## Status

Demo bisa digunakan tanpa akun Firebase. Jalur tersambung menyediakan kode login Google, presensi masuk/pulang, riwayat peserta, dan rekap admin dasar. Project Firebase pengembangan sudah dibuat, Google Authentication diaktifkan, dan Firestore disiapkan dengan settings/office nonaktif. Halaman login Karina memakai alur Firebase. Cloud Functions belum dideploy dan API SI-MELAYUR belum tersedia, sehingga integrasi end-to-end belum dapat diverifikasi.

Izin/lampiran, koreksi dengan audit persisten, profil rinci, dan ekspor masih berupa UI demo. Lihat batas implementasi di dokumen arsitektur; aplikasi belum siap untuk data operasional.

## Pemeriksaan lokal

```powershell
node --test functions/test/*.test.js
Set-Location mobile
flutter analyze
flutter test
flutter build apk --debug --dart-define=APP_MODE=demo
```

Untuk Firebase sungguhan ikuti [panduan mulai](docs/MULAI-FIREBASE.md). Untuk backend lama lihat [referensi Laravel](docs/REFERENSI-LARAVEL.md). Alat lokal dijelaskan di [SETUP-LOKAL.md](SETUP-LOKAL.md).
