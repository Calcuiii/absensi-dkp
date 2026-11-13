import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../app.dart';
import '../../services/firebase_gateway.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';
import '../participant/connected_dashboard.dart';

class FirebaseAppShell extends StatelessWidget {
  const FirebaseAppShell({super.key, this.configurationError});
  final String? configurationError;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SI-MELAYUR',
    debugShowCheckedModeBanner: false,
    builder: (context, child) => FirebaseConfig.localBackend
        ? Column(
            children: [
              const Material(
                color: Color(0xFFFFE6A6),
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        'UJI LOKAL • DATA PENGUJIAN',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          )
        : child ?? const SizedBox.shrink(),
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
  bool _historyLoaded = false;
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
      _historyLoaded = true;
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
        _historyLoaded = false;
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

  @override
  Widget build(BuildContext context) {
    if (_access == null) {
      return LoginScreen(onSignIn: _login, busy: _busy, error: _error);
    }
    return ConnectedDashboard(
      access: _access!,
      records: _records,
      historyLoaded: _historyLoaded,
      busy: _busy,
      error: _error,
      notice: _notice,
      onRefresh: () => _perform(_refresh),
      onCheckIn: () => _record('checkIn'),
      onCheckOut: () => _record('checkOut'),
      onLogout: _logout,
    );
  }
}
