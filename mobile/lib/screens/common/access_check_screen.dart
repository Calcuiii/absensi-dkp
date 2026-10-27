import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../admin/admin_shell.dart';
import '../participant/participant_shell.dart';

class AccessCheckScreen extends StatefulWidget {
  const AccessCheckScreen({super.key});

  @override
  State<AccessCheckScreen> createState() => _AccessCheckScreenState();
}

class _AccessCheckScreenState extends State<AccessCheckScreen> {
  AccessState _state = AccessState.checking;
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startAccessCheck();
  }

  void _startAccessCheck() {
    _timer?.cancel();

    setState(() {
      _state = AccessState.checking;
    });

    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      setState(() {
        _state = AccessState.allowed;
      });

      _navigateToHome();
    });
  }

  void _handleRetry() {
    _startAccessCheck();
  }

  void _navigateToHome() {
    if (!mounted || _hasNavigated || _state != AccessState.allowed) {
      return;
    }

    _hasNavigated = true;

    final Widget destination = demoRole == UserRole.admin
        ? const AdminShell()
        : const ParticipantShell();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  void _exitToLogin() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==========================================
              // HEADER MARINE
              // ==========================================
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.ocean, AppColors.navy],
                        ),
                      ),
                    ),

                    Positioned(
                      right: -55,
                      top: -60,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),

                    Positioned(
                      left: -70,
                      bottom: -80,
                      child: Container(
                        width: 220,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(120),
                        ),
                      ),
                    ),

                    const Positioned(
                      right: 34,
                      bottom: 18,
                      child: Icon(
                        Icons.sailing,
                        size: 92,
                        color: Colors.white54,
                      ),
                    ),

                    const Positioned(
                      left: 44,
                      bottom: 28,
                      child: Icon(
                        Icons.location_on,
                        size: 54,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // CONTENT CARD
              // ==========================================
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildContent(),
                  ),
                ),
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case AccessState.checking:
        return _buildChecking();

      case AccessState.notAccepted:
        return _buildError(
          key: const ValueKey('notAccepted'),
          icon: Icons.person_off_outlined,
          title: 'Akun belum terdaftar',
          message:
              'Akun Google yang digunakan belum terdaftar sebagai peserta '
              'yang diterima di SI-MELAYUR.',
        );

      case AccessState.serviceError:
        return _buildError(
          key: const ValueKey('serviceError'),
          icon: Icons.cloud_off_outlined,
          title: 'Layanan sedang tidak tersedia',
          message:
              'Pemeriksaan data peserta belum dapat dilakukan. '
              'Silakan coba lagi beberapa saat kemudian.',
          showRetry: true,
        );

      case AccessState.expired:
        return _buildError(
          key: const ValueKey('expired'),
          icon: Icons.event_busy_outlined,
          title: 'Masa kegiatan telah berakhir',
          message:
              'Akses peserta untuk periode kegiatan ini telah berakhir. '
              'Silakan keluar dan gunakan akun lain jika diperlukan.',
        );

      case AccessState.allowed:
        return _buildChecking();
    }
  }

  Widget _buildChecking() {
    return Column(
      key: const ValueKey('checking'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        const AppLogo(size: 68),

        const SizedBox(height: 18),

        const Text(
          'Memeriksa akses',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Sedang memeriksa data akun dan periode kegiatan. '
          'Mohon tunggu sebentar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
        ),

        const SizedBox(height: 28),

        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(14),
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.ocean,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 19,
                color: AppColors.ocean,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sistem sedang memastikan akun dan periode '
                  'kegiatan sesuai dengan data SI-MELAYUR.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError({
    required Key key,
    required IconData icon,
    required String title,
    required String message,
    bool showRetry = false,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, color: AppColors.ocean, size: 34),
        ),

        const SizedBox(height: 22),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        if (showRetry) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleRetry,
              child: const Text(
                'Coba Lagi',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _exitToLogin,
            child: const Text(
              'Keluar / Ganti Akun',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
