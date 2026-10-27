import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'screens/common/firebase_app.dart';
import 'services/firebase_gateway.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (const String.fromEnvironment('APP_MODE') == 'demo') {
    runApp(const SiMelayurApp());
    return;
  }
  if (!FirebaseConfig.configured) {
    runApp(
      const FirebaseAppShell(
        configurationError:
            'Pengelola perlu menghubungkan aplikasi ke Firebase dan SI-MELAYUR terlebih dahulu. '
            'Demo tersedia untuk melihat tampilan dengan data contoh.',
      ),
    );
    return;
  }
  try {
    await Firebase.initializeApp(options: FirebaseConfig.options);
    runApp(const FirebaseAppShell());
  } catch (_) {
    runApp(
      const FirebaseAppShell(
        configurationError: 'Koneksi awal Firebase belum berhasil. Hubungi pengelola untuk memeriksa konfigurasi aplikasi.',
      ),
    );
  }
}
