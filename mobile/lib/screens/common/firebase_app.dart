import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../app.dart';
import '../../services/firebase_gateway.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class FirebaseAppShell extends StatelessWidget {
  const FirebaseAppShell({super.key, this.configurationError});
  final String? configurationError;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SI-MELAYUR',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    home: configurationError == null
        ? const ConnectedHome()
        : ConfigurationScreen(message: configurationError!),
  );
}

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SI-MELAYUR')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.settings_outlined, size: 64, color: AppColors.ocean),
        const SizedBox(height: 24),
        const Text(
          'Layanan belum disiapkan',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const SiMelayurApp())),
          child: const Text('Lihat demo dengan data contoh'),
        ),
      ],
    ),
  );
}

class ConnectedHome extends StatefulWidget {
  const ConnectedHome({super.key, this.gateway});
  final FirebaseGateway? gateway;
  @override
  State<ConnectedHome> createState() => _ConnectedHomeState();
}

class _ConnectedHomeState extends State<ConnectedHome> {
  late final _gateway = widget.gateway ?? FirebaseGateway();
  Map<String, dynamic>? _access;
  List<Map<String, dynamic>> _records = [];
  bool _busy = false;
  String? _error;
  String? _notice;

  Future<void> _perform(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = switch (error) {
            ServiceFailure failure => failure.message,
            FirebaseException failure =>
              failure.message ?? 'Layanan Firebase belum siap.',
            _ => 'Proses belum berhasil. Silakan coba kembali.',
          };
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    final result = await _gateway.call(
      _access?['role'] == 'admin' ? 'getAdminAttendance' : 'getMyAttendance',
    );
    if (!mounted) return;
    setState(() {
      _records = (result['records'] as List)
          .map((record) => Map<String, dynamic>.from(record as Map))
          .toList();
      if (result['limited'] == true) {
        _notice = 'Menampilkan maksimal 200 catatan hari ini.';
      }
    });
  }

  Future<void> _login() => _perform(() async {
    final result = await _gateway.signIn();
    if (!mounted) return;
    setState(() => _access = result);
    await _refresh();
  });

  Future<void> _logout() => _perform(() async {
    await _gateway.signOut();
    if (mounted) {
      setState(() {
        _access = null;
        _records = [];
      });
    }
  });

  Future<void> _record(String stage) => _perform(() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ServiceFailure(
        'Aktifkan layanan lokasi perangkat terlebih dahulu.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw const ServiceFailure(
        'Izinkan akses lokasi melalui pengaturan aplikasi.',
      );
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    final result = await _gateway.call('recordAttendance', {
      'stage': stage,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'isMocked': position.isMocked,
      'capturedAt': position.timestamp.millisecondsSinceEpoch,
    });
    if (!mounted) return;
    setState(
      () => _notice = result['duplicate'] == true
          ? 'Presensi sudah tercatat sebelumnya.'
          : 'Presensi berhasil dicatat oleh server.',
    );
    await _refresh();
  });

  String _time(dynamic sample) {
    if (sample is! Map || sample['at'] is! String) return '—';
    final date = DateTime.tryParse(sample['at'] as String);
    return date == null
        ? '—'
        : '${DateFormat('HH.mm').format(date.toUtc().add(const Duration(hours: 7)))} WIB';
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = _access != null;
    final admin = _access?['role'] == 'admin';
    if (!loggedIn) {
      return LoginScreen(onSignIn: _login, busy: _busy, error: _error);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('SI-MELAYUR'),
        actions: [
          if (loggedIn)
            IconButton(
              onPressed: _busy ? null : _logout,
              tooltip: 'Keluar / Ganti Akun',
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              loggedIn
                  ? (admin ? 'Presensi peserta hari ini' : 'Presensi saya')
                  : 'Selamat datang',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              loggedIn ? '${_access!['name'] ?? _access!['email']}' : 'Gunakan akun Google yang sama dengan email pendaftaran SI-MELAYUR.',
            ),
            const SizedBox(height: 20),
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            if (_notice != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_notice!),
              ),
            if (!loggedIn)
              ElevatedButton.icon(
                onPressed: _busy ? null : _login,
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('Masuk dengan Google'),
              ),
            if (loggedIn) ...[
              if (!admin) ...[
                ElevatedButton.icon(
                  onPressed: _busy ? null : () => _record('checkIn'),
                  icon: const Icon(Icons.login),
                  label: const Text('Presensi Masuk'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _busy ? null : () => _record('checkOut'),
                  icon: const Icon(Icons.logout),
                  label: const Text('Presensi Keluar'),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _perform(_refresh),
                icon: const Icon(Icons.refresh),
                label: const Text('Muat ulang riwayat'),
              ),
              const SizedBox(height: 20),
              if (_records.isEmpty) const Text('Belum ada catatan presensi.'),
              ..._records.map(
                (record) => Card(
                  child: ListTile(
                    title: Text('${record['date']}'),
                    subtitle: Text(
                      '${admin ? '${record['uid']}\n' : ''}'
                      'Masuk: ${_time(record['checkIn'])}\nKeluar: ${_time(record['checkOut'])}',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
