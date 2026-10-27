import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final List<PermissionRecord> _records = [
    const PermissionRecord(
      id: '1',
      type: PermissionType.sick,
      startDate: '10 Oktober 2026',
      endDate: '11 Oktober 2026',
      description: 'Demam dan batuk',
      attachmentName: 'surat_sakit.jpg',
      attachmentPath: '',
      hasAttachment: true,
    ),
    const PermissionRecord(
      id: '2',
      type: PermissionType.personal,
      startDate: '3 Oktober 2026',
      endDate: '3 Oktober 2026',
      description: 'Mengurus dokumen kuliah',
      attachmentName: 'bukti_izin.jpg',
      attachmentPath: '',
      hasAttachment: true,
    ),
  ];

  Future<void> _openForm() async {
    final result = await Navigator.of(context).push<PermissionRecord>(
      MaterialPageRoute(builder: (_) => const PermissionForm()),
    );

    if (!mounted || result == null) return;

    setState(() {
      _records.insert(0, result);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan izin berhasil disimpan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Izin / Sakit')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Catatan Izin/Sakit',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _openForm,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._records.map(_buildPermissionItem),
          const SizedBox(height: 8),
          const DemoNote(
            text:
                'Sampaikan izin kepada PJ melalui WhatsApp terlebih dahulu. '
                'Formulir ini digunakan untuk mencatat izin dan melampirkan bukti. '
                'Catatan tersimpan tidak otomatis berarti izin telah disetujui PJ.',
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(PermissionRecord record) {
    final bool isSick = record.type == PermissionType.sick;

    final IconData icon = isSick
        ? Icons.sick_outlined
        : Icons.assignment_outlined;

    final Color color = isSick ? AppColors.danger : AppColors.info;

    final String typeLabel = isSick ? 'Sakit' : 'Izin Keperluan';

    final String date = record.startDate == record.endDate
        ? record.startDate
        : '${record.startDate} – ${record.endDate}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InfoCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRecordDetail(record),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.description,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.hasAttachment
                              ? '1 lampiran'
                              : 'Tanpa lampiran',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetail(PermissionRecord record) {
    final bool isSick = record.type == PermissionType.sick;

    final String typeLabel = isSick ? 'Sakit' : 'Izin Keperluan';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Detail Catatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 18),
                _detailRow('Jenis', typeLabel),
                _detailRow(
                  'Tanggal',
                  record.startDate == record.endDate
                      ? record.startDate
                      : '${record.startDate} – ${record.endDate}',
                ),
                _detailRow('Keterangan', record.description),
                _detailRow(
                  'Lampiran',
                  record.hasAttachment
                      ? record.attachmentName
                      : 'Tidak ada lampiran',
                ),
                const SizedBox(height: 12),
                const DemoNote(
                  text:
                      'Catatan ini hanya digunakan untuk pencatatan izin/sakit. '
                      'Persetujuan tetap disampaikan melalui PJ.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PermissionForm extends StatefulWidget {
  const PermissionForm({super.key});

  @override
  State<PermissionForm> createState() => _PermissionFormState();
}

class _PermissionFormState extends State<PermissionForm> {
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _descriptionController = TextEditingController();

  String _type = 'Sakit';

  DateTime? _startDate;
  DateTime? _endDate;

  Uint8List? _attachment;
  String _attachmentName = '';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (image == null) return;

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _attachment = bytes;
        _attachmentName = image.name;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti tidak dapat dipilih. Silakan coba lagi.'),
        ),
      );
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime now = DateTime.now();

    final DateTime initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final DateTime firstDate = DateTime(2026, 1, 1);
    final DateTime lastDate = DateTime(2030, 12, 31);

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : initialDate.isAfter(lastDate)
          ? lastDate
          : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (!mounted || selected == null) return;

    if (isStart) {
      setState(() {
        _startDate = selected;

        if (_endDate != null && _endDate!.isBefore(selected)) {
          _endDate = selected;
        }
      });
      return;
    }

    if (_startDate != null && selected.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
        ),
      );
      return;
    }

    setState(() {
      _endDate = selected;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'dd/mm/yyyy';

    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    final String year = date.year.toString();

    return '$day/$month/$year';
  }

  void _save() {
    final String description = _descriptionController.text.trim();

    if (_startDate == null) {
      _showError('Tanggal mulai wajib diisi.');
      return;
    }

    if (_endDate == null) {
      _showError('Tanggal selesai wajib diisi.');
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _showError('Tanggal selesai tidak boleh sebelum tanggal mulai.');
      return;
    }

    if (description.isEmpty) {
      _showError('Keterangan singkat wajib diisi.');
      return;
    }

    final PermissionRecord record = PermissionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type == 'Sakit' ? PermissionType.sick : PermissionType.personal,
      startDate: _formatLongDate(_startDate!),
      endDate: _formatLongDate(_endDate!),
      description: description,
      attachmentName: _attachmentName,
      attachmentPath: '',
      hasAttachment: _attachment != null,
    );

    Navigator.of(context).pop(record);
  }

  String _formatLongDate(DateTime date) {
    const List<String> months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan Izin')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const DemoNote(
            text:
                'Sampaikan izin kepada PJ melalui WhatsApp terlebih dahulu. '
                'Formulir ini digunakan untuk mencatat izin dan melampirkan bukti. '
                'Unggah bagian percakapan yang relevan saja.',
          ),
          const SizedBox(height: 20),

          const Text(
            'Jenis',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: RadioGroup<String>(
              groupValue: _type,
              onChanged: (String? value) {
                if (value == null) return;

                setState(() {
                  _type = value;
                });
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Sakit'),
                    value: 'Sakit',
                    activeColor: AppColors.ocean,
                  ),
                  RadioListTile<String>(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    title: const Text('Izin Keperluan'),
                    value: 'Izin Keperluan',
                    activeColor: AppColors.ocean,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Tanggal Mulai',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 7),

          _dateField(
            value: _formatDate(_startDate),
            onTap: () => _selectDate(isStart: true),
          ),

          const SizedBox(height: 14),

          const Text(
            'Tanggal Selesai',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 7),

          _dateField(
            value: _formatDate(_endDate),
            onTap: () => _selectDate(isStart: false),
          ),

          const SizedBox(height: 16),

          const Text(
            'Keterangan Singkat',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 7),

          TextField(
            controller: _descriptionController,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Contoh: Demam dan batuk',
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Bukti',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 7),

          if (_attachment == null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Kamera'),
                  ),
                ),
              ],
            )
          else
            _buildAttachmentPreview(),

          const SizedBox(height: 8),

          const Text(
            'Unggah bagian percakapan WhatsApp yang relevan saja atau foto dokumen pendukung.',
            style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text(
                'Simpan Catatan Izin',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField({required String value, required VoidCallback onTap}) {
    final bool isSelected = value != 'dd/mm/yyyy';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: isSelected ? AppColors.navy : AppColors.muted,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _attachment!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.attach_file, size: 16, color: AppColors.muted),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _attachmentName,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _attachment = null;
                    _attachmentName = '';
                  });
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
