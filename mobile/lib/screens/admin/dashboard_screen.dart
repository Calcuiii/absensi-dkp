import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'participant_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  List<AdminParticipant> get _filteredParticipants {
    if (_searchQuery.isEmpty) {
      return adminParticipants;
    }

    return adminParticipants.where((participant) {
      return participant.name.toLowerCase().contains(_searchQuery) ||
          participant.activity.toLowerCase().contains(_searchQuery) ||
          participant.institution.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ringkasan Monitoring'),
        actions: [
          IconButton(
            tooltip: 'Informasi',
            onPressed: _showInformation,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _buildDateHeader(),
              const SizedBox(height: 16),
              _buildStats(),
              const SizedBox(height: 24),
              _buildSearchSection(),
              const SizedBox(height: 20),
              _buildParticipantHeader(),
              const SizedBox(height: 10),
              _buildParticipantList(),
              const SizedBox(height: 16),
              const DemoNote(
                text:
                    'Data yang terlihat mengikuti hak akses akun PJ/Admin. '
                    'Label “Izin/Sakit Tercatat” hanya menunjukkan catatan '
                    'yang tersimpan dan tidak berarti izin telah disetujui.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monitoring Presensi',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: AppColors.muted,
            ),
            const SizedBox(width: 7),
            Text(
              _todayDate(),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    const totalParticipants = 24;
    const checkedIn = 18;
    const notCheckedIn = 4;
    const late = 3;
    const permission = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Hari Ini',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: const [
            _Stat(
              label: 'Total Peserta',
              value: '$totalParticipants',
              icon: Icons.groups_outlined,
              color: AppColors.ocean,
            ),
            _Stat(
              label: 'Sudah Masuk',
              value: '$checkedIn',
              icon: Icons.login_outlined,
              color: AppColors.success,
            ),
            _Stat(
              label: 'Belum Masuk',
              value: '$notCheckedIn',
              icon: Icons.schedule_outlined,
              color: AppColors.muted,
            ),
            _Stat(
              label: 'Terlambat',
              value: '$late',
              icon: Icons.warning_amber_rounded,
              color: AppColors.danger,
            ),
            _Stat(
              label: 'Izin/Sakit Tercatat',
              value: '$permission',
              icon: Icons.assignment_late_outlined,
              color: AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari nama peserta',
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 52,
          height: 52,
          child: OutlinedButton(
            onPressed: _showDateFilter,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Icon(Icons.tune, color: AppColors.ocean),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Peserta Hari Ini',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${_filteredParticipants.length} peserta',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantList() {
    final participants = _filteredParticipants;

    if (participants.isEmpty) {
      return const _EmptyParticipantState();
    }

    return Column(
      children: participants
          .map((participant) => _buildParticipantCard(context, participant))
          .toList(),
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    AdminParticipant participant,
  ) {
    final statusInfo = _getStatusInfo(participant.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ParticipantDetailScreen(name: participant.name),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(participant.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${participant.activity} • ${participant.institution}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.login_outlined,
                            size: 13,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            participant.checkIn == '-'
                                ? 'Masuk -'
                                : 'Masuk ${participant.checkIn}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.logout_outlined,
                            size: 13,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            participant.checkOut == '-'
                                ? 'Keluar -'
                                : 'Keluar ${participant.checkOut}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(
                  text: statusInfo.label,
                  icon: statusInfo.icon,
                  color: statusInfo.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: 23,
      backgroundColor: AppColors.paleBlue,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          color: AppColors.ocean,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  _StatusInfo _getStatusInfo(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const _StatusInfo(
          label: 'Masuk',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        );

      case AttendanceStatus.late:
        return const _StatusInfo(
          label: 'Terlambat',
          icon: Icons.warning_amber_rounded,
          color: AppColors.danger,
        );

      case AttendanceStatus.permission:
        return const _StatusInfo(
          label: 'Izin/Sakit Tercatat',
          icon: Icons.assignment_late_outlined,
          color: AppColors.info,
        );

      case AttendanceStatus.empty:
        return const _StatusInfo(
          label: 'Belum Masuk',
          icon: Icons.schedule_outlined,
          color: AppColors.muted,
        );
    }
  }

  String _todayDate() {
    return 'Senin, 26 Oktober 2026';
  }

  Future<void> _refreshData() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data monitoring diperbarui.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDateFilter() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Monitoring',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih tanggal untuk melihat data presensi.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.today_outlined,
                    color: AppColors.ocean,
                  ),
                  title: const Text(
                    'Hari ini',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('26 Oktober 2026'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.date_range_outlined,
                    color: AppColors.ocean,
                  ),
                  title: const Text(
                    'Pilih rentang tanggal',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Untuk kebutuhan monitoring atau rekap'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDateRangePicker();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDateRangePicker() async {
    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      initialDateRange: DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 26),
      ),
    );

    if (!mounted || selectedRange == null) {
      return;
    }

    final start = _formatDate(selectedRange.start);
    final end = _formatDate(selectedRange.end);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter tanggal: $start – $end'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showInformation() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Monitoring Presensi',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Halaman ini digunakan PJ/Admin untuk memantau '
            'presensi peserta pada data yang menjadi kewenangan akun. '
            'Detail peserta dapat dibuka untuk melihat informasi '
            'presensi dan melakukan koreksi jika diperlukan.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusInfo {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyParticipantState extends StatelessWidget {
  const _EmptyParticipantState();

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.paleBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_search_outlined,
                color: AppColors.ocean,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Peserta tidak ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Coba gunakan kata kunci nama, kegiatan, atau institusi lain.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
