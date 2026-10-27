# Backend Absensi DKP & Integrasi SI-MELAYUR

Backend RESTful API untuk Sistem Presensi DKP berbasis Geofencing dan integrasi sistem magang **SI-MELAYUR**.

Dibuat menggunakan **Laravel 12**, **PHP 8.2+**, dan **Laravel Sanctum**.

---

## 🎯 Pembagian Tugas & Tanggung Jawab Anggota 2
- **Tanggung Jawab Utama**: Data peserta dan aturan akses SI-MELAYUR.
- **Pekerjaan yang Dikerjakan**:
  - Memeriksa sistem SI-MELAYUR & validasi status peserta.
  - Membuat & menyesuaikan RESTful API untuk integrasi Flutter mobile dan Dashboard PJ/Admin.
  - Mencocokkan email Google yang terverifikasi dengan data pangkalan SI-MELAYUR.
  - Memeriksa status diterima (`accepted`/`active`) dan validasi rentang tanggal periode magang.
  - Mengatur arsitektur database, relasi model, geofencing coordinates, dan hak akses otentikasi API.

---

## 🚀 Fitur Backend

1. **Google OAuth & Validasi SI-MELAYUR (`/api/auth/google-login`)**:
   - Menerima profil login akun Google dari aplikasi mobile Flutter.
   - Melakukan cross-check ke tabel `si_melayur_participants`:
     - Apakah email terdaftar?
     - Apakah status peserta berstatus diterima/aktif?
     - Apakah tanggal saat ini berada dalam rentang `start_date` dan `end_date`?
   - Memberikan pesan penolakan jika email tidak terdaftar atau periode magang sudah berakhir.
   - Mengeluarkan Sanctum API Token jika valid.

2. **Presensi Masuk & Keluar (`/api/attendance/check-in`, `/api/attendance/check-out`)**:
   - Validasi Geofencing lokasi kantor DKP dengan formula Haversine.
   - Deteksi GPS palsu / Mock Location (`is_mock`).
   - Memberikan status presensi: `valid` atau `rejected` beserta alasan penolakan.

3. **Riwayat & Status Hari Ini (`/api/attendance/today`, `/api/attendance/history`)**:
   - Memeriksa status presensi harian peserta.
   - Menyediakan riwayat presensi peserta (paginasi).

4. **API Dashboard Admin / PJ DKP (`/api/admin/*`)**:
   - Rekap total peserta dan presensi hari ini (`/api/admin/summary`).
   - Daftar riwayat presensi seluruh peserta dengan filter status dan tanggal (`/api/admin/attendances`).
   - Konfigurasi titik koordinat & radius geofencing DKP (`/api/admin/geofence`).
   - Sinkronisasi data peserta SI-MELAYUR (`/api/admin/sync-participant`).

---

## 🛠️ Instalasi & Menjalankan

1. Clone repositori dan checkout ke branch `backend`:
   ```bash
   git clone https://github.com/Calcuiii/absensi-dkp.git
   cd absensi-dkp
   git checkout backend
   ```

2. Pasang dependensi Composer:
   ```bash
   composer install
   ```

3. Setup environment file:
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. Jalankan migrasi dan seeder:
   ```bash
   php artisan migrate --seed
   ```

5. Jalankan server lokal:
   ```bash
   php artisan serve
   ```
   API akan berjalan di `http://127.0.0.1:8000`.

---

## 📋 Daftar Endpoint API

| Method | Endpoint | Keterangan | Autentikasi |
|---|---|---|---|
| `POST` | `/api/auth/google-login` | Login Google & validasi SI-MELAYUR | Public |
| `GET` | `/api/auth/profile` | Profil peserta & info SI-MELAYUR | Bearer Token |
| `POST` | `/api/auth/logout` | Logout & cabut token | Bearer Token |
| `GET` | `/api/attendance/today` | Status presensi hari ini & info geofence | Bearer Token |
| `POST` | `/api/attendance/check-in` | Presensi masuk (validasi geofence & mock) | Bearer Token |
| `POST` | `/api/attendance/check-out` | Presensi keluar (validasi geofence & mock) | Bearer Token |
| `GET` | `/api/attendance/history` | Riwayat presensi peserta | Bearer Token |
| `GET` | `/api/admin/summary` | Rekap kehadiran untuk PJ/Admin | Admin / Public |
| `GET` | `/api/admin/attendances` | Filter daftar presensi peserta | Admin / Public |
| `POST` | `/api/admin/geofence` | Update koordinat & radius kantor DKP | Admin / Public |
| `POST` | `/api/admin/sync-participant`| Sinkronisasi data peserta SI-MELAYUR | Admin / Public |
