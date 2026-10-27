import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Demo state:
  // false = belum presensi masuk
  // true  = sudah presensi masuk, belum keluar
  // null  = sudah masuk dan keluar
  bool? _attendanceStage = false;

  Future<void> _openAttendance(AttendanceType type) async {
    final recorded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AttendanceScreen(stage: type)),
    );

    if (!mounted || recorded != true) return;

    setState(() {
      if (type == AttendanceType.checkIn) {
        _attendanceStage = true;
      } else {
        _attendanceStage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCheckedIn =
        _attendanceStage == true || _attendanceStage == null;

    final bool hasCheckedOut = _attendanceStage == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // HEADER
              // ==========================================
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat pagi 👋',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          participant.name,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Senin, 26 Oktober 2026',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.ocean,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==========================================
              // STATUS KEGIATAN
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.ocean, AppColors.navy],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status kegiatan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Sedang Berlangsung',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '15 Okt 2026 — 15 Des 2026',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // PENEMPATAN & JADWAL
              // ==========================================
              InfoCard(
                child: Column(
                  children: [
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      label: 'Penempatan',
                      value: 'DKP Provinsi Jawa Timur, Surabaya',
                    ),
                    const Divider(height: 24),
                    _InfoLine(
                      icon: Icons.schedule_outlined,
                      label: 'Jadwal Presensi',
                      value: '07.30 – 15.30 WIB',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==========================================
              // PRESENSI HARI INI
              // ==========================================
              const SectionTitle(title: 'Presensi Hari Ini'),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _AttendanceStatusCard(
                      title: 'Masuk',
                      time: hasCheckedIn ? '07.28' : '--:--',
                      description: hasCheckedIn
                          ? 'Tepat waktu'
                          : 'Belum tercatat',
                      icon: Icons.login_rounded,
                      active: hasCheckedIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AttendanceStatusCard(
                      title: 'Keluar',
                      time: hasCheckedOut ? '15.32' : '--:--',
                      description: hasCheckedOut
                          ? 'Tepat waktu'
                          : 'Belum tercatat',
                      icon: Icons.logout_rounded,
                      active: hasCheckedOut,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==========================================
              // LOCATION STATUS
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.ocean.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.paleBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_searching_rounded,
                        color: AppColors.ocean,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status lokasi',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Lokasi akan diperiksa saat presensi',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                      size: 22,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // MAIN ACTION
              // ==========================================
              _buildAttendanceAction(),

              const SizedBox(height: 22),

              // ==========================================
              // RINGKASAN KEHADIRAN
              // ==========================================
              const SectionTitle(title: 'Ringkasan Kehadiran'),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Metric(label: 'Hadir', value: '12'),
                    _Metric(label: 'Terlambat', value: '2'),
                    _Metric(label: 'Izin/Sakit', value: '1'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // PROTOTYPE NOTE
              // ==========================================
              const DemoNote(
                text:
                    'Asumsi prototype: toleransi keterlambatan 15 menit. '
                    'Setelah 07.45 WIB, status menjadi terlambat. '
                    'Ketentuan final perlu dikonfirmasi.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceAction() {
    if (_attendanceStage == false) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () {
            _openAttendance(AttendanceType.checkIn);
          },
          icon: const Icon(Icons.login_rounded, size: 21),
          label: const Text(
            'Presensi Masuk',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      );
    }

    if (_attendanceStage == true) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () {
            _openAttendance(AttendanceType.checkOut);
          },
          icon: const Icon(Icons.logout_rounded, size: 21),
          label: const Text(
            'Presensi Keluar',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.20)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 23),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presensi hari ini selesai',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Presensi masuk dan keluar sudah tercatat.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.ocean, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceStatusCard extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final IconData icon;
  final bool active;

  const _AttendanceStatusCard({
    required this.title,
    required this.time,
    required this.description,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = active ? AppColors.success : AppColors.muted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? AppColors.success.withValues(alpha: 0.18)
              : AppColors.ocean.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.success.withValues(alpha: 0.10)
                      : AppColors.paleBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const Spacer(),
              if (active)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 17,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}
