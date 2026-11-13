import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// Presentation for authenticated accounts. All business data comes from the server.
class ConnectedDashboard extends StatefulWidget {
  const ConnectedDashboard({
    super.key,
    required this.access,
    required this.records,
    required this.historyLoaded,
    required this.busy,
    required this.onRefresh,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onLogout,
    this.error,
    this.notice,
    this.now,
  });

  final Map<String, dynamic> access;
  final List<Map<String, dynamic>> records;
  final bool historyLoaded;
  final bool busy;
  final VoidCallback onRefresh, onCheckIn, onCheckOut, onLogout;
  final String? error, notice;
  final DateTime? now;

  @override
  State<ConnectedDashboard> createState() => _ConnectedDashboardState();
}

class _ConnectedDashboardState extends State<ConnectedDashboard> {
  int _index = 0;
  bool get _admin => widget.access['role'] == 'admin';
  DateTime get _now =>
      (widget.now ?? DateTime.now()).toUtc().add(const Duration(hours: 7));
  String get _day => DateFormat('yyyy-MM-dd').format(_now);
  String get _name =>
      '${widget.access['name'] ?? widget.access['email'] ?? 'Peserta'}';
  Map<String, dynamic> get _today => widget.records.firstWhere(
    (record) => record['date'] == _day,
    orElse: () => <String, dynamic>{},
  );
  bool _recorded(dynamic sample) =>
      sample is Map &&
      sample['at'] is String &&
      DateTime.tryParse(sample['at'] as String) != null;
  String _time(dynamic sample) => !_recorded(sample)
      ? '--:--'
      : DateFormat('HH.mm').format(
          DateTime.parse(sample['at'] as String)
              .toUtc()
              .add(const Duration(hours: 7)),
        );

  String _date(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            _header(),
            if (widget.busy)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(),
              ),
            if (widget.error != null) _message(widget.error!, error: true),
            if (widget.notice != null) _message(widget.notice!),
            const SizedBox(height: 22),
            if (_index == 0) ..._home(),
            if (_index == 1) ..._history(),
            if (_index == 2) ..._profile(),
          ],
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_rounded),
          label: _admin ? 'Data Presensi' : 'Riwayat',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    ),
  );

  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _index == 0
                  ? (_now.hour < 11
                        ? 'Selamat pagi 👋'
                        : _now.hour < 15
                        ? 'Selamat siang 👋'
                        : _now.hour < 18
                        ? 'Selamat sore 👋'
                        : 'Selamat malam 👋')
                  : _index == 1
                  ? (_admin ? 'Data presensi peserta' : 'Riwayat presensi')
                  : 'Profil akun',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _name,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${_date(_now)} • WIB',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      IconButton(
        onPressed: () => setState(() => _index = 2),
        tooltip: 'Buka profil',
        style: IconButton.styleFrom(
          backgroundColor: AppColors.paleBlue,
          padding: const EdgeInsets.all(12),
        ),
        icon: const Icon(Icons.person_outline_rounded, color: AppColors.ocean),
      ),
    ],
  );

  Widget _message(String text, {bool error = false}) => Container(
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: error ? const Color(0xFFFFEEEE) : const Color(0xFFEAF8F3),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Semantics(
      liveRegion: true,
      child: Text(
        text,
        style: TextStyle(
          color: error ? AppColors.danger : AppColors.navy,
          height: 1.5,
        ),
      ),
    ),
  );

  Widget _hero() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.ocean, AppColors.navy],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.navy.withValues(alpha: .12),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SI-MELAYUR • DKP JAWA TIMUR',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _admin
                    ? 'Pantau kehadiran peserta'
                    : 'Akses peserta terverifikasi',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _admin ? 'Rekap kehadiran hari ini tersedia di Data Presensi.' : 'Akunmu telah lolos pemeriksaan kelayakan SI-MELAYUR saat masuk.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  List<Widget> _home() {
    final hasIn = _recorded(_today['checkIn']);
    final hasOut = _recorded(_today['checkOut']);
    return [
      _hero(),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: Text(
              _admin ? 'Ringkasan hari ini' : 'Presensi Hari Ini',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.busy ? null : widget.onRefresh,
            tooltip: 'Muat ulang riwayat',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.ocean),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _statusCard(
              'Masuk',
              _admin
                  ? '${widget.records.where((r) => _recorded(r['checkIn'])).length}'
                  : _time(_today['checkIn']),
              _admin
                  ? 'Peserta tercatat'
                  : hasIn
                  ? 'Sudah tercatat • WIB'
                  : 'Belum tercatat',
              Icons.login_rounded,
              hasIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statusCard(
              'Keluar',
              _admin
                  ? '${widget.records.where((r) => _recorded(r['checkOut'])).length}'
                  : _time(_today['checkOut']),
              _admin
                  ? 'Peserta tercatat'
                  : hasOut
                  ? 'Sudah tercatat • WIB'
                  : 'Belum tercatat',
              Icons.logout_rounded,
              hasOut,
            ),
          ),
        ],
      ),
      if (!_admin) ...[
        const SizedBox(height: 16),
        InfoCard(
          child: Row(
            children: [
              const Icon(
                Icons.location_searching_rounded,
                color: AppColors.ocean,
                size: 26,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemeriksaan lokasi',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lokasi perangkat akan diperiksa saat kamu melakukan presensi.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (!widget.historyLoaded)
          _empty(
            Icons.sync_rounded,
            'Riwayat belum dimuat',
            'Muat ulang data sebelum melakukan presensi.',
          )
        else if (hasOut)
          _message('Presensi masuk dan keluar hari ini sudah tercatat.')
        else
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: widget.busy
                  ? null
                  : hasIn
                  ? widget.onCheckOut
                  : widget.onCheckIn,
              icon: Icon(hasIn ? Icons.logout_rounded : Icons.login_rounded),
              label: Text(hasIn ? 'Presensi Keluar' : 'Presensi Masuk'),
            ),
          ),
      ],
      const SizedBox(height: 24),
      const Text(
        'Catatan Kehadiran',
        style: TextStyle(
          color: AppColors.navy,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      if (!widget.historyLoaded)
        _empty(
          Icons.cloud_off_outlined,
          'Data belum tersedia',
          'Coba muat ulang untuk mengambil catatan dari server.',
        )
      else if (widget.records.isEmpty)
        _empty(
          Icons.event_note_outlined,
          'Belum ada catatan presensi',
          'Presensi yang berhasil dicatat akan muncul di sini.',
        )
      else
        ...widget.records.take(3).map(_recordCard),
      TextButton(
        onPressed: () => setState(() => _index = 1),
        child: const Text('Lihat seluruh catatan →'),
      ),
    ];
  }

  Widget _statusCard(
    String title,
    String time,
    String subtitle,
    IconData icon,
    bool active,
  ) => InfoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: active ? AppColors.success : AppColors.ocean,
            size: 23,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: active ? AppColors.success : AppColors.muted,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  Widget _empty(IconData icon, String title, String description) => InfoCard(
    child: Column(
      children: [
        const SizedBox(height: 6),
        Icon(icon, size: 36, color: AppColors.ocean),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 6),
      ],
    ),
  );

  Widget _recordCard(Map<String, dynamic> record) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 17,
                color: AppColors.ocean,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '${record['date'] ?? 'Tanggal tidak tersedia'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          if (_admin)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'ID peserta: ${record['uid'] ?? '—'}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ),
          const Divider(height: 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Masuk  ${_time(record['checkIn'])}',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Keluar  ${_time(record['checkOut'])}',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Waktu Indonesia Barat',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );

  List<Widget> _history() => [
    const Text(
      'Catatan dari server',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.navy,
      ),
    ),
    const SizedBox(height: 6),
    Text(
      _admin
          ? 'Presensi peserta hari ini.'
          : 'Menampilkan hingga 31 hari yang memiliki catatan terbaru.',
      style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5),
    ),
    const SizedBox(height: 16),
    if (!widget.historyLoaded)
      _empty(
        Icons.cloud_off_outlined,
        'Riwayat belum dimuat',
        'Tekan muat ulang untuk mengambil data.',
      )
    else if (widget.records.isEmpty)
      _empty(
        Icons.history_rounded,
        'Belum ada catatan presensi',
        'Catatan akan tampil setelah presensi berhasil disimpan.',
      )
    else
      ...widget.records.map(_recordCard),
    const SizedBox(height: 12),
    OutlinedButton.icon(
      onPressed: widget.busy ? null : widget.onRefresh,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Muat ulang riwayat'),
    ),
  ];

  List<Widget> _profile() => [
    _hero(),
    const SizedBox(height: 20),
    InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          _profileLine('Nama', _name),
          const Divider(height: 28),
          _profileLine('Email Google', '${widget.access['email'] ?? '—'}'),
          const Divider(height: 28),
          _profileLine('Peran', _admin ? 'Admin/PJ' : 'Peserta'),
        ],
      ),
    ),
    const SizedBox(height: 20),
    OutlinedButton.icon(
      onPressed: widget.busy
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar dari akun?'),
                  content: const Text(
                    'Kamu dapat masuk kembali menggunakan akun Google.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && mounted) widget.onLogout();
            },
      icon: const Icon(Icons.logout_rounded),
      label: const Text('Keluar / Ganti Akun'),
    ),
  ];

  Widget _profileLine(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    ],
  );
}
