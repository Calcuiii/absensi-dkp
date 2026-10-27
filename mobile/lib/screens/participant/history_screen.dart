import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _failed = false;
  String _selectedMonth = 'Oktober 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
        actions: [
          IconButton(
            tooltip: 'Preview kondisi gagal',
            onPressed: () {
              setState(() {
                _failed = !_failed;
              });
            },
            icon: const Icon(Icons.bug_report_outlined),
          ),
        ],
      ),
      body: _failed ? _buildErrorState() : _buildHistory(),
    );
  }

  Widget _buildErrorState() {
    return EmptyState(
      title: 'Riwayat gagal dimuat',
      message: 'Data presensi belum dapat dimuat. Silakan coba lagi.',
      icon: Icons.cloud_off_outlined,
      onRetry: () {
        setState(() {
          _failed = false;
        });
      },
    );
  }

  Widget _buildHistory() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _buildIntro(),
        const SizedBox(height: 18),
        _buildMonthSelector(),
        const SizedBox(height: 16),
        _buildSummary(),
        const SizedBox(height: 22),
        const SectionTitle(title: 'Riwayat Presensi'),
        const SizedBox(height: 10),
        ...attendanceRecords.map((record) => _record(context, record)),
        const SizedBox(height: 4),
        const DemoNote(
          text:
              'Detail riwayat menampilkan waktu presensi, lokasi, status, '
              'dan koreksi jika ada. Peserta tidak dinyatakan tidak hadir '
              'hanya karena belum ada presensi.',
        ),
      ],
    );
  }

  Widget _buildIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pantau presensi',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: AppColors.navy,
            height: 1.15,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Lihat catatan kehadiran dan status presensi selama periode magang.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _showMonthPicker,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.ocean,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Periode',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Pilih bulan untuk melihat riwayat',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _selectedMonth,
              style: const TextStyle(
                color: AppColors.ocean,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final late = attendanceRecords
        .where((record) => record.status == AttendanceStatus.late)
        .length;

    final permission = attendanceRecords
        .where((record) => record.status == AttendanceStatus.permission)
        .length;

    final completed = attendanceRecords
        .where((record) => record.hasCheckIn && record.hasCheckOut)
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            label: 'Tercatat',
            value: '$completed',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryItem(
            label: 'Terlambat',
            value: '$late',
            icon: Icons.schedule_outlined,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryItem(
            label: 'Izin/Sakit',
            value: '$permission',
            icon: Icons.assignment_outlined,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _record(BuildContext context, AttendanceRecord record) {
    final statusInfo = _statusInfo(record.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HistoryDetail(record: record)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.date,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        record.status == AttendanceStatus.permission
                            ? record.note.isNotEmpty
                                  ? record.note
                                  : 'Izin/Sakit tercatat'
                            : '${record.checkIn} masuk  •  '
                                  '${record.checkOut} keluar',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusPill(
                      text: statusInfo.label,
                      icon: statusInfo.icon,
                      color: statusInfo.color,
                    ),
                    const SizedBox(height: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _HistoryStatusInfo _statusInfo(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const _HistoryStatusInfo(
          label: 'Tepat waktu',
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );

      case AttendanceStatus.late:
        return const _HistoryStatusInfo(
          label: 'Terlambat',
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );

      case AttendanceStatus.permission:
        return const _HistoryStatusInfo(
          label: 'Izin/Sakit',
          color: AppColors.info,
          icon: Icons.assignment_outlined,
        );

      case AttendanceStatus.empty:
        return const _HistoryStatusInfo(
          label: 'Belum tercatat',
          color: AppColors.muted,
          icon: Icons.remove_circle_outline,
        );
    }
  }

  void _showMonthPicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        const months = ['Oktober 2026', 'September 2026', 'Agustus 2026'];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih periode',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...months.map(
                  (month) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      month == _selectedMonth
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: month == _selectedMonth
                          ? AppColors.ocean
                          : AppColors.muted,
                    ),
                    title: Text(
                      month,
                      style: TextStyle(
                        fontWeight: month == _selectedMonth
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: AppColors.navy,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedMonth = month;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryStatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _HistoryStatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class HistoryDetail extends StatelessWidget {
  final AttendanceRecord record;

  const HistoryDetail({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isPermission = record.status == AttendanceStatus.permission;
    final statusInfo = _detailStatusInfo(record.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Presensi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Presensi',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: StatusPill(
                    text: statusInfo.label,
                    icon: statusInfo.icon,
                    color: statusInfo.color,
                  ),
                ),
                const SizedBox(height: 18),
                _line('Tanggal', record.date),
                if (isPermission) ...[
                  _line(
                    'Jenis',
                    record.note.isNotEmpty ? record.note : 'Izin/Sakit',
                  ),
                  _line('Presensi Masuk', '-'),
                  _line('Presensi Keluar', '-'),
                ] else ...[
                  _line(
                    'Presensi Masuk',
                    record.hasCheckIn ? '${record.checkIn} WIB' : '-',
                  ),
                  _line(
                    'Presensi Keluar',
                    record.hasCheckOut ? '${record.checkOut} WIB' : '-',
                  ),
                ],
                _line('Lokasi', 'DKP Provinsi Jawa Timur, Surabaya'),
                _line('Koreksi', 'Tidak ada'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (isPermission)
            const InfoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Catatan izin/sakit digunakan untuk mencatat '
                      'informasi yang telah disampaikan kepada PJ. '
                      'Tercatat tidak berarti otomatis disetujui.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          const DemoNote(
            text:
                'Jika ada koreksi presensi, detail perubahan sebelum '
                'dan sesudah koreksi akan ditampilkan di halaman ini.',
          ),
        ],
      ),
    );
  }

  _HistoryStatusInfo _detailStatusInfo(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const _HistoryStatusInfo(
          label: 'Tepat waktu',
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );

      case AttendanceStatus.late:
        return const _HistoryStatusInfo(
          label: 'Terlambat',
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );

      case AttendanceStatus.permission:
        return const _HistoryStatusInfo(
          label: 'Izin/Sakit',
          color: AppColors.info,
          icon: Icons.assignment_outlined,
        );

      case AttendanceStatus.empty:
        return const _HistoryStatusInfo(
          label: 'Belum tercatat',
          color: AppColors.muted,
          icon: Icons.remove_circle_outline,
        );
    }
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.navy,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
