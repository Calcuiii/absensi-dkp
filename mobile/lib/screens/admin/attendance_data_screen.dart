import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'participant_detail_screen.dart';

class AttendanceDataScreen extends StatefulWidget {
  const AttendanceDataScreen({super.key});

  @override
  State<AttendanceDataScreen> createState() => _AttendanceDataScreenState();
}

class _AttendanceDataScreenState extends State<AttendanceDataScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _status = 'Semua';
  String _selectedDate = '26 Oktober 2026';

  final List<String> _statusFilters = const [
    'Semua',
    'Tepat waktu',
    'Terlambat',
    'Izin/Sakit',
    'Belum masuk',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<AdminParticipant> get _filteredParticipants {
    final query = _searchController.text.trim().toLowerCase();

    return adminParticipants.where((participant) {
      final matchesSearch =
          query.isEmpty ||
          participant.name.toLowerCase().contains(query) ||
          participant.activity.toLowerCase().contains(query) ||
          participant.institution.toLowerCase().contains(query);

      final matchesStatus = switch (_status) {
        'Tepat waktu' => participant.status == AttendanceStatus.onTime,
        'Terlambat' => participant.status == AttendanceStatus.late,
        'Izin/Sakit' => participant.status == AttendanceStatus.permission,
        'Belum masuk' => participant.status == AttendanceStatus.empty,
        _ => true,
      };

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _openDateFilter() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Tanggal',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.ocean,
                  ),
                  title: const Text(
                    '26 Oktober 2026',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Hari ini'),
                  trailing: _selectedDate == '26 Oktober 2026'
                      ? const Icon(Icons.check_circle, color: AppColors.ocean)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDate = '26 Oktober 2026';
                    });

                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.date_range_outlined,
                    color: AppColors.ocean,
                  ),
                  title: const Text(
                    'Pilih tanggal lain',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Gunakan kalender untuk melihat tanggal tertentu',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2026, 10, 26),
                      firstDate: DateTime(2026, 1, 1),
                      lastDate: DateTime(2026, 12, 31),
                    );

                    if (picked == null || !mounted) return;

                    const months = [
                      'Januari',
                      'Februari',
                      'Maret',
                      'April',
                      'Mei',
                      'Juni',
                      'Juli',
                      'Agustus',
                      'September',
                      'Oktober',
                      'November',
                      'Desember',
                    ];

                    setState(() {
                      _selectedDate =
                          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openStatusFilter() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Status',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: _status,
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _status = value;
                    });

                    Navigator.pop(sheetContext);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _statusFilters.map((filter) {
                      return RadioListTile<String>(
                        value: filter,
                        activeColor: AppColors.ocean,
                        title: Text(filter),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDownloadOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unduh Rekap Presensi',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Format file rekap dapat disesuaikan dengan kebutuhan sistem final.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_chart_outlined,
                      color: AppColors.ocean,
                    ),
                  ),
                  title: const Text(
                    'Excel (.xlsx)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('Format rekap tabel'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur unduh Excel masih berupa prototype.',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.ocean,
                    ),
                  ),
                  title: const Text(
                    'CSV (.csv)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text('Format data sederhana'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur unduh CSV masih berupa prototype.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final participants = _filteredParticipants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Presensi'),
        actions: [
          IconButton(
            tooltip: 'Unduh rekap',
            onPressed: _openDownloadOptions,
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            setState(() {});
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            InfoCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.paleBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.ocean,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tanggal Presensi',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDate,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _openDateFilter,
                    child: const Text('Ubah'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama peserta...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _openStatusFilter,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(Icons.tune),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _status == filter,
                      onSelected: (_) {
                        setState(() {
                          _status = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Daftar Peserta',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${participants.length} peserta',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (participants.isEmpty)
              const EmptyState(
                icon: Icons.search_off_outlined,
                title: 'Data tidak ditemukan',
                message: 'Tidak ada peserta yang sesuai dengan pencarian atau filter yang dipilih.',
              )
            else
              ...participants.map(
                (participant) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AttendanceParticipantCard(
                    participant: participant,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ParticipantDetailScreen(name: participant.name),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const DemoNote(
              text: 'Prototype: fitur Unduh Rekap masih berupa rancangan. Format CSV/Excel dan mekanisme unduh perlu dikonfirmasi pada implementasi final.',
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceParticipantCard extends StatelessWidget {
  final AdminParticipant participant;
  final VoidCallback onTap;

  const _AttendanceParticipantCard({
    required this.participant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(participant.status);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.paleBlue,
                child: Text(
                  _getInitials(participant.name),
                  style: const TextStyle(
                    color: AppColors.ocean,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
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
                    const SizedBox(height: 3),
                    Text(
                      '${participant.activity} • ${participant.institution}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TimeItem(
                          icon: Icons.login_outlined,
                          label: participant.checkIn == '-'
                              ? 'Masuk -'
                              : 'Masuk ${participant.checkIn}',
                        ),
                        const SizedBox(width: 10),
                        _TimeItem(
                          icon: Icons.logout_outlined,
                          label: participant.checkOut == '-'
                              ? 'Keluar -'
                              : 'Keluar ${participant.checkOut}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Icon(status.icon, color: status.color, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    status.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: status.color,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusInfo _statusInfo(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const _StatusInfo(
          label: 'Tepat waktu',
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );

      case AttendanceStatus.late:
        return const _StatusInfo(
          label: 'Terlambat',
          color: AppColors.warning,
          icon: Icons.schedule_outlined,
        );

      case AttendanceStatus.permission:
        return const _StatusInfo(
          label: 'Izin/Sakit',
          color: AppColors.info,
          icon: Icons.assignment_outlined,
        );

      case AttendanceStatus.empty:
        return const _StatusInfo(
          label: 'Belum masuk',
          color: AppColors.muted,
          icon: Icons.remove_circle_outline,
        );
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _TimeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TimeItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.muted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
