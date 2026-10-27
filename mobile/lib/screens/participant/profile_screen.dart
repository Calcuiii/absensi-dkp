import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../common/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty) return 'P';

    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(participant.name);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // =========================
          // PROFILE HEADER
          // =========================
          Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.25),
                      width: 5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ocean,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  participant.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  participant.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                const StatusPill(
                  text: 'Peserta Aktif',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // DATA PESERTA
          // =========================
          const SectionTitle(title: 'Informasi Peserta'),
          const SizedBox(height: 10),

          InfoCard(
            child: Column(
              children: [
                _infoRow(
                  Icons.school_outlined,
                  'Instansi asal',
                  participant.institution,
                ),
                _divider(),
                _infoRow(
                  Icons.work_outline,
                  'Jenis kegiatan',
                  participant.activity,
                ),
                _divider(),
                _infoRow(
                  Icons.location_on_outlined,
                  'Penempatan',
                  participant.placement,
                ),
                _divider(),
                _infoRow(
                  Icons.person_outline,
                  'PJ/Pembimbing',
                  participant.supervisor,
                ),
                _divider(),
                _infoRow(
                  Icons.calendar_today_outlined,
                  'Periode',
                  '${participant.startDate} — ${participant.endDate}',
                ),
                _divider(),
                _statusRow(),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =========================
          // INFORMATION NOTE
          // =========================
          const DemoNote(
            text:
                'Data utama bersumber dari SI-MELAYUR dan ditampilkan sebagai '
                'informasi. Peserta tidak dapat mengubah data utama dari aplikasi ini.',
          ),

          const SizedBox(height: 22),

          // =========================
          // LOGOUT
          // =========================
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutConfirmation(context),
              icon: const Icon(Icons.logout_outlined),
              label: const Text(
                'Keluar / Ganti Akun',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.ocean),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: AppColors.muted.withValues(alpha: 0.10));
  }

  Widget _statusRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(
                Icons.verified_outlined,
                size: 18,
                color: AppColors.ocean,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Status periode',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          StatusPill(
            text: 'Sedang Berlangsung',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Keluar dari akun?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Anda akan kembali ke halaman masuk SI-MELAYUR. '
            'Untuk menggunakan akun lain, silakan masuk kembali.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout(context);
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
