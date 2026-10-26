import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    this.stage = AttendanceType.checkIn,
  });

  final AttendanceType stage;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late LocationCheckState _state;

  @override
  void initState() {
    super.initState();

    _state = LocationCheckState.checking;

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      setState(() {
        _state = LocationCheckState.valid;
      });
    });
  }

  String get _attendanceLabel {
    return widget.stage == AttendanceType.checkIn
        ? 'Presensi Masuk'
        : 'Presensi Keluar';
  }

  bool get _canConfirm {
    return _state == LocationCheckState.valid;
  }

  void _simulateLocationCheck() {
    setState(() {
      _state = LocationCheckState.checking;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      setState(() {
        _state = LocationCheckState.valid;
      });
    });
  }

  void _confirmAttendance() {
    if (!_canConfirm) return;

    final isCheckIn = widget.stage == AttendanceType.checkIn;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Presensi berhasil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_attendanceLabel pada '
                '${isCheckIn ? '07.30' : '15.32'} WIB telah dicatat.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCheckIn = widget.stage == AttendanceType.checkIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isCheckIn),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationCard(),
                    const SizedBox(height: 18),
                    _buildLocationStatus(),
                    const SizedBox(height: 18),
                    _buildAttendanceInfo(isCheckIn),
                    const SizedBox(height: 24),
                    _buildConfirmButton(),
                    const SizedBox(height: 12),
                    _buildDemoSelector(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCheckIn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navy,
            AppColors.ocean,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
            ),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckIn ? 'Presensi Masuk' : 'Presensi Keluar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pastikan berada di area DKP Jawa Timur',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.ocean.withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ocean.withValues(alpha: 0.16),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.ocean,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DKP Provinsi Jawa Timur',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Surabaya',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus() {
    final data = _locationStatusData();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: data.color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              data.icon,
              color: data.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (_state == LocationCheckState.valid)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 22,
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceInfo(bool isCheckIn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail presensi',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.location_city_rounded,
            label: 'Lokasi',
            value: 'DKP Provinsi Jawa Timur',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            value: '26 Oktober 2026',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Jadwal',
            value: isCheckIn ? '07.30 WIB' : '15.30 WIB',
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final enabled = _canConfirm;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: enabled ? _confirmAttendance : null,
        icon: Icon(
          enabled
              ? Icons.check_circle_outline_rounded
              : Icons.location_searching_rounded,
        ),
        label: Text(
          enabled
              ? 'Konfirmasi $_attendanceLabel'
              : 'Memeriksa lokasi...',
        ),
      ),
    );
  }

  Widget _buildDemoSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paleBlue.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tune_rounded,
            size: 18,
            color: AppColors.muted,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Simulasi kondisi lokasi',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: _simulateLocationCheck,
            child: const Text('Cek ulang'),
          ),
        ],
      ),
    );
  }

  _LocationStatusData _locationStatusData() {
    switch (_state) {
      case LocationCheckState.checking:
        return const _LocationStatusData(
          icon: Icons.location_searching_rounded,
          title: 'Sedang memeriksa lokasi',
          description:
              'Mohon tunggu, sistem sedang memvalidasi lokasi perangkat.',
          color: AppColors.info,
          background: AppColors.paleBlue,
        );

      case LocationCheckState.valid:
        return const _LocationStatusData(
          icon: Icons.verified_rounded,
          title: 'Lokasi memenuhi syarat',
          description:
              'Perangkat terdeteksi berada di area presensi.',
          color: AppColors.success,
          background: Color(0xFFEAF8F3),
        );

      case LocationCheckState.outsideArea:
        return const _LocationStatusData(
          icon: Icons.location_off_rounded,
          title: 'Di luar area presensi',
          description:
              'Silakan berada di area DKP Jawa Timur untuk melakukan presensi.',
          color: Colors.red,
          background: Color(0xFFFFF0F0),
        );

      case LocationCheckState.inaccurate:
        return const _LocationStatusData(
          icon: Icons.gps_not_fixed_rounded,
          title: 'Akurasi lokasi belum memadai',
          description:
              'Pindah ke area terbuka lalu coba periksa lokasi kembali.',
          color: AppColors.warning,
          background: Color(0xFFFFF8E8),
        );

      case LocationCheckState.permissionDenied:
        return const _LocationStatusData(
          icon: Icons.location_disabled_rounded,
          title: 'Izin lokasi belum diberikan',
          description:
              'Aktifkan izin lokasi untuk melanjutkan presensi.',
          color: AppColors.warning,
          background: Color(0xFFFFF8E8),
        );

      case LocationCheckState.serviceDisabled:
        return const _LocationStatusData(
          icon: Icons.gps_off_rounded,
          title: 'Layanan lokasi tidak aktif',
          description:
              'Aktifkan layanan lokasi pada perangkat.',
          color: AppColors.warning,
          background: Color(0xFFFFF8E8),
        );

      case LocationCheckState.mockLocation:
        return const _LocationStatusData(
          icon: Icons.warning_amber_rounded,
          title: 'Indikasi lokasi simulasi',
          description:
              'Presensi tidak dapat dilanjutkan karena lokasi perangkat terindikasi simulasi.',
          color: Colors.red,
          background: Color(0xFFFFF0F0),
        );

      case LocationCheckState.noInternet:
        return const _LocationStatusData(
          icon: Icons.wifi_off_rounded,
          title: 'Tidak ada koneksi internet',
          description:
              'Periksa koneksi internet lalu coba kembali.',
          color: Colors.red,
          background: Color(0xFFFFF0F0),
        );

      case LocationCheckState.alreadyRecorded:
        return const _LocationStatusData(
          icon: Icons.info_outline_rounded,
          title: 'Presensi sudah tercatat',
          description:
              'Presensi untuk periode ini sudah tersimpan.',
          color: AppColors.info,
          background: AppColors.paleBlue,
        );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
          child: Icon(
            icon,
            color: AppColors.ocean,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationStatusData {
  const _LocationStatusData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color background;
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ocean.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    const grid = 32.0;

    for (double x = 0; x <= size.width; x += grid) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y <= size.height; y += grid) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}