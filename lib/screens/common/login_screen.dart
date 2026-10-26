import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'access_check_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _loginWithGoogle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AccessCheckScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // =========================
              // MARINE ILLUSTRATION
              // =========================
              SizedBox(
                height: 285,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.ocean,
                            AppColors.navy,
                          ],
                        ),
                      ),
                    ),

                    // Decorative wave / circle
                    Positioned(
                      left: -70,
                      bottom: -85,
                      child: Container(
                        width: 230,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(120),
                        ),
                      ),
                    ),

                    Positioned(
                      right: -55,
                      top: 35,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),

                    // Simple marine illustration
                    const Positioned(
                      right: 28,
                      bottom: 12,
                      child: Icon(
                        Icons.sailing,
                        size: 118,
                        color: Colors.white54,
                      ),
                    ),

                    // Lighthouse-style visual
                    Positioned(
                      left: 48,
                      bottom: 35,
                      child: Column(
                        children: [
                          Container(
                            width: 38,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5),
                              ),
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Small light
                    Positioned(
                      left: 57,
                      bottom: 91,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // LOGIN CARD
              // =========================
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      const Center(
                        child: AppLogo(size: 64),
                      ),

                      const SizedBox(height: 14),

                      // App name
                      const Text(
                        'SI-MELAYUR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Welcome
                      const Text(
                        'Selamat datang',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Masuk untuk melakukan presensi peserta '
                        'Magang, KP, dan PKL di Dinas Kelautan '
                        'dan Perikanan Provinsi Jawa Timur.',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Google login
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _loginWithGoogle(context),
                          icon: const Icon(
                            Icons.account_circle_outlined,
                            size: 22,
                            color: AppColors.navy,
                          ),
                          label: const Text(
                            'Masuk dengan Google',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: AppColors.ocean.withValues(alpha: 0.25),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Registration information
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.paleBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.ocean.withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.ocean,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Pendaftaran peserta dilakukan melalui '
                                'website SI-MELAYUR. Gunakan akun Google '
                                'yang sama dengan email pendaftaran.',
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

                      const SizedBox(height: 20),

                      const Text(
                        'DKP Provinsi Jawa Timur • Surabaya',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
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
}