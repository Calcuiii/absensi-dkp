# Aplikasi Flutter SI-MELAYUR

Jalankan dari folder ini setelah mengaktifkan `scripts/dev-env.ps1` dari root repository.

```powershell
flutter pub get
flutter run --dart-define=APP_MODE=demo
```

Demo admin:

```powershell
flutter run --dart-define=APP_MODE=demo --dart-define=DEMO_ROLE=admin
```

Data demo hanya untuk memeriksa UI dan tidak dikirim ke Firebase. Role demo tidak digunakan untuk memberi akses admin sungguhan.

Untuk layanan Firebase, isi salinan `firebase-config.example.json` bernama `firebase-config.local.json`, siapkan layanan sesuai panduan, lalu jalankan:

```powershell
flutter run --dart-define-from-file=firebase-config.local.json
```

Project Firebase pengembangan tim sudah terdaftar melalui alias dev. Konfigurasi aplikasi disimpan lokal dan tidak masuk Git; setiap pengembang menyiapkan file lokalnya sendiri. Cloud Functions belum dideploy dan endpoint SI-MELAYUR belum tersedia.

Panduan: [Mulai Firebase](../docs/MULAI-FIREBASE.md). Keputusan dan status fitur: [Arsitektur](../docs/ARSITEKTUR.md).
