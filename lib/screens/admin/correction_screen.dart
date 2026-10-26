import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CorrectionScreen extends StatefulWidget {
  const CorrectionScreen({super.key});

  @override
  State<CorrectionScreen> createState() => _CorrectionScreenState();
}

class _CorrectionScreenState extends State<CorrectionScreen> {
  static const String _initialCheckIn = '07.28';
  static const String _initialCheckOut = '15.32';

  late final TextEditingController _checkInController;
  late final TextEditingController _checkOutController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();

    _checkInController = TextEditingController(
      text: _initialCheckIn,
    );
    _checkOutController = TextEditingController(
      text: _initialCheckOut,
    );
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koreksi Presensi'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const DemoNote(
              text:
                  'Perubahan presensi harus memiliki alasan. Sistem menyimpan '
                  'pelaku, waktu, alasan, dan perubahan untuk riwayat koreksi.',
            ),
            const SizedBox(height: 20),

            const SectionTitle(
              title: 'Identitas Presensi',
            ),
            const SizedBox(height: 10),

            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    label: 'Peserta',
                    value: 'Andi Pratama',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    label: 'Tanggal',
                    value: '26 Oktober 2026',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    label: 'Kegiatan',
                    value: 'Magang',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const SectionTitle(
              title: 'Data Awal',
            ),
            const SizedBox(height: 10),

            InfoCard(
              child: Column(
                children: [
                  _buildTimeRow(
                    icon: Icons.login_outlined,
                    label: 'Jam masuk',
                    value: '$_initialCheckIn WIB',
                  ),
                  const Divider(height: 24),
                  _buildTimeRow(
                    icon: Icons.logout_outlined,
                    label: 'Jam keluar',
                    value: '$_initialCheckOut WIB',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const SectionTitle(
              title: 'Perubahan',
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checkInController,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Jam masuk',
                      hintText: '07.30',
                      prefixIcon: Icon(Icons.login_outlined),
                      suffixText: 'WIB',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _checkOutController,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Jam keluar',
                      hintText: '15.30',
                      prefixIcon: Icon(Icons.logout_outlined),
                      suffixText: 'WIB',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Alasan koreksi *',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _reasonController,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText:
                    'Contoh: Peserta lupa melakukan presensi masuk.',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _showConfirmation,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text(
                  'Lihat Ringkasan Perubahan',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const SectionTitle(
              title: 'Riwayat Koreksi',
            ),
            const SizedBox(height: 10),

            InfoCard(
              child: Column(
                children: const [
                  _HistoryRow(
                    pelaku: 'Budi Santoso, S.Pi',
                    waktu: '21 Okt 2026 • 16.02',
                    alasan: 'Koreksi jam masuk',
                    perubahan: 'Masuk: 07.20 → 07.28',
                  ),
                  Divider(height: 28),
                  _HistoryRow(
                    pelaku: 'Budi Santoso, S.Pi',
                    waktu: '20 Okt 2026 • 15.45',
                    alasan: 'Koreksi jam keluar',
                    perubahan: 'Keluar: 15.15 → 15.28',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Riwayat koreksi tidak dapat dihapus dan digunakan sebagai catatan perubahan presensi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.paleBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.ocean,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  void _showConfirmation() {
    final checkIn = _checkInController.text.trim();
    final checkOut = _checkOutController.text.trim();
    final reason = _reasonController.text.trim();

    if (checkIn.isEmpty || checkOut.isEmpty) {
      _showMessage(
        'Jam masuk dan jam keluar wajib diisi.',
      );
      return;
    }

    if (reason.isEmpty) {
      _showMessage(
        'Alasan koreksi wajib diisi.',
      );
      return;
    }

    if (checkIn == _initialCheckIn &&
        checkOut == _initialCheckOut) {
      _showMessage(
        'Belum ada perubahan data presensi.',
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Koreksi',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pastikan perubahan berikut sudah benar sebelum disimpan.',
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                _buildConfirmationRow(
                  'Jam masuk',
                  '$_initialCheckIn → $checkIn WIB',
                ),
                const SizedBox(height: 10),

                _buildConfirmationRow(
                  'Jam keluar',
                  '$_initialCheckOut → $checkOut WIB',
                ),
                const SizedBox(height: 16),

                const Text(
                  'Alasan',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),

                Text(
                  reason,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
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
                _saveCorrection();
              },
              child: const Text(
                'Simpan Koreksi',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmationRow(
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paleBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCorrection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Koreksi presensi berhasil disimpan.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String pelaku;
  final String waktu;
  final String alasan;
  final String perubahan;

  const _HistoryRow({
    required this.pelaku,
    required this.waktu,
    required this.alasan,
    required this.perubahan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                pelaku,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                waktu,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          alasan,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          perubahan,
          style: const TextStyle(
            color: AppColors.ocean,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}