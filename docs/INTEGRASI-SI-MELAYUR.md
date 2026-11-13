# Integrasi API SI-MELAYUR (KP-DKP)

## Pembaruan beranda tersambung

Pengguna telah menyelesaikan login Google interaktif dan memberikan tangkapan layar beranda dengan nama peserta dari API. Ini mengonfirmasi alur Google Sign-In native menuju Auth emulator, Functions emulator dan Laravel lokal; pengujian Firebase Auth cloud/deployment belum termasuk.

Beranda sederhana diganti desain kartu yang mengikuti gaya prototipe Karina. Nama/email memakai hasil pemeriksaan akses, status masuk/keluar dan riwayat memakai respons server, tanggal ditampilkan dalam WIB. Navigasi Beranda, Riwayat, dan Profil telah terhubung. Izin/sakit dan koreksi persisten belum tersedia pada alur tersambung. Tidak ada angka kehadiran atau data peserta contoh yang digunakan dalam beranda ini.

Sebanyak 13 tes Flutter lulus, termasuk pergantian masuk ke keluar berdasarkan catatan server, penanganan riwayat gagal dimuat, dan navigasi profil/riwayat. APK lokal berhasil dibangun dan diperbarui pada Android emulator. Pengaturan lokasi kantor tetap perlu disiapkan sebelum pengujian presensi lokasi yang berhasil.

## Hasil uji lintas proyek 8 November 2026

Functions, Auth, dan Firestore emulator berhasil dijalankan pada laptop yang sama dengan Laravel. Skrip `node scripts/test-local-integration.cjs` memeriksa respons Laravel untuk pengajuan uji 4, otorisasi callable, kelayakan peserta, riwayat, larangan admin, dan penolakan presensi saat pengaturan kantor belum valid. Identitas Google dalam skrip ini adalah simulasi Auth emulator; jangan menyebut hasil ini sebagai keberhasilan login Google nyata.

Token dibaca dari file lokal yang diberikan pengguna pada proyek KP-DKP, lalu disimpan pada `functions/.secret.local`; nilainya tidak disertakan dalam dokumen atau Flutter. Koreksi path sumber: `KP-DKP/.codex-artifacts/attendance-local/integration.env`.

Menyalakan backend lokal dari root proyek:

```powershell
.\scripts\start-local-backend.ps1
```

Menjalankan aplikasi pada Android emulator (di terminal lain, setelah mengaktifkan dev-env):

```powershell
cd mobile
flutter run --dart-define-from-file=firebase-config.local.json --dart-define=USE_LOCAL_BACKEND=true
```

Mode ini hanya aktif pada build debug. Android emulator mengakses localhost laptop lewat 10.0.2.2. Aplikasi menggunakan Google Sign-In native, lalu menukar kredensial ke Auth emulator; Functions dan data presensi memakai emulator. Tidak ada penulisan presensi ke Firestore cloud. Mode diberi penanda UJI LOKAL. Untuk uji interaktif, pengguna memilih akun uji yang telah disiapkan di Laravel; password/OTP diisi sendiri pada layar Google, bukan melalui chat.

Login Google interaktif belum terbukti sampai pengguna menyelesaikan pemilihan akun dan hasil aplikasi diperiksa. Jangan memakai token Google simulasi dari skrip sebagai pengganti uji tersebut. HTTP loopback pada Android dibuka hanya melalui network security configuration build debug.

Bagian berikut mendokumentasikan kontrak dan persiapan awal; pernyataan pengujian lintas proyek yang tertunda di bagian lama telah diperbarui oleh hasil di atas.

Kontrak dari proyek KP-DKP diterima pada 8 November 2026. Implementasi presensi menggunakan POST `/api/participants/verify`, Bearer token server, JSON request `{ "email": "email-dari-firebase-token" }` dan header Accept JSON.

Contoh respons valid (is_active harus mempunyai nilai boolean):

```json
{"participant":{"id":"123","email":"peserta@example.com","full_name":"Contoh Peserta","status":"accepted","is_active":true,"start_date":"2026-10-01","end_date":"2026-12-31"}}
```

ID tersebut merupakan ID pengajuan Laravel, bukan Firebase UID. Presensi tetap memakai UID Firebase sebagai pemilik catatan. API hanya mencari layanan magang_pkl; pemilihan pengajuan/WOPPS menjadi tanggung jawab Laravel. Adapter tidak memilih record atau membuat fallback jika terdapat beberapa pengajuan.

HTTP 200 tetap diperiksa terhadap email, status accepted, boolean is_active=true, dan periode tanggal inklusif Asia/Jakarta. Keaktifan resmi di Laravel perlu ditetapkan oleh pengelola; jangan menggunakan nilai contoh untuk data operasional.

## Penanganan kegagalan

| HTTP Laravel | Perilaku adapter |
|---|---|
| 401/403 | Tahan akses; konfigurasi kredensial/izin/HTTPS perlu diperiksa pengelola |
| 404 | Tolak akses peserta/pengajuan tidak ditemukan |
| 409 | Tahan akses; tampilkan alasan aman untuk data ambigu, tidak lengkap, periode tidak valid, atau keputusan tidak didukung |
| 422 | Tahan akses karena email belum dapat diverifikasi |
| 429 | Ikuti Retry-After; tunggu otomatis hanya bila maksimal 1 detik, selain itu kembalikan resource-exhausted beserta retryAfterSeconds jika tersedia |
| 500/502/503/504 atau gangguan jaringan | Maksimal satu retry dengan jeda 250 ms, kemudian unavailable |
| JSON tidak valid pada 200 | Tahan akses, tanpa menerima peserta |

Setiap percobaan memiliki timeout 5 detik termasuk pembacaan respons, maksimal dua percobaan. Redirect tidak diikuti agar kredensial tidak berpindah tujuan. Pesan mentah dari server tidak diteruskan ke aplikasi. Semua kegagalan verifikasi menahan presensi; pengiriman baru tetap harus melewati verifikasi lagi.

## Pengujian lokal dua proyek

1. Pada proyek KP-DKP, jalankan migrasi attendance_active sesuai panduan proyek tersebut, siapkan token integrasi, akun peserta uji, dan tetapkan keaktifan resmi. Jalankan Laravel pada 127.0.0.1:8000.
2. Di proyek ini, buat `functions/.env.local` dengan konfigurasi berikut:

```dotenv
SI_MELAYUR_URL=http://127.0.0.1:8000/api/participants/verify
```

3. Buat `functions/.secret.local` dengan `SI_MELAYUR_API_KEY=<token-integrasi-lokal>`. File rahasia ini diabaikan Git. Jangan mengirim nilainya lewat chat.
4. Dari root absensi-dkp, aktifkan scripts/dev-env.ps1 lalu jalankan emulator Functions, Firestore dan Auth sesuai lingkungan pengujian. Contoh:

```powershell
firebase emulators:start --only functions,firestore,auth --project demo-si-melayur
```

HTTP loopback hanya diterima saat Firebase menetapkan FUNCTIONS_EMULATOR=true. Cloud Functions cloud tetap wajib memakai HTTPS. Jangan mengatur penanda emulator pada deployment. URL di atas hanya berlaku jika Functions emulator dan Laravel berjalan pada laptop/host yang sama; container/WSL memerlukan penyesuaian jaringan.

Autentikasi Google nyata dan Auth emulator adalah jalur berbeda. Flutter saat ini masih mengarah ke layanan cloud; menyalakan emulator saja belum mengalihkan Flutter ke emulator. Pengujian lintas proyek berikutnya perlu menyiapkan routing dan akun uji emulator secara eksplisit.

## Konfigurasi cloud dan status

SI_MELAYUR_URL harus diganti endpoint HTTPS yang dapat dijangkau dari cloud; SI_MELAYUR_API_KEY disimpan sebagai Firebase secret. Laravel membatasi 60 request/menit/IP; retry ikut memakai kuota tersebut. Tidak ada deploy, tunnel, migrasi Laravel, atau penetapan status peserta yang dilakukan oleh perubahan adapter ini.

Tes adapter menggunakan respons terkendali, termasuk autentikasi API gagal, 409, 429, timeout, retry, dan periode. Tes tersebut belum membuktikan komunikasi nyata dengan Laravel. Masih diperlukan migrasi dan kredensial KP-DKP, penetapan peserta aktif, pengujian lintas proyek, serta endpoint deployment HTTPS.
