import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import '../../data/models/schedule.dart';

class ScheduleFormResult {
  ScheduleFormResult({
    this.id,
    required this.category,
    required this.location,
    required this.team1,
    required this.team2,
    required this.date,
    required this.time,
    this.imageUrl,
    this.caption,
  });

  final int? id;
  final String category;
  final String location;
  final String team1;
  final String team2;
  final String date;
  final String time;
  final String? imageUrl;
  final String? caption;

  Map<String, String> toFormBody() {
    return <String, String>{
      'category': category,
      'location': location,
      'team1': team1,
      'team2': team2,
      'date': date,
      'time': time,
      if (imageUrl != null) 'image_url': imageUrl!,
      if (caption != null) 'caption': caption!,
    };
  }
}

class ScheduleFormDialog extends StatefulWidget {
  const ScheduleFormDialog({super.key, this.initial});

  final Schedule? initial;

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _categoryC;
  late final TextEditingController _locationC;
  late final TextEditingController _team1C;
  late final TextEditingController _team2C;
  late final TextEditingController _dateC;
  late final TextEditingController _timeC;
  late final TextEditingController _imageUrlC;
  late final TextEditingController _captionC;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final Schedule? s = widget.initial;
    _categoryC = TextEditingController(text: s?.category ?? '');
    _locationC = TextEditingController(text: s?.location ?? '');
    _team1C = TextEditingController(text: s?.team1 ?? '');
    _team2C = TextEditingController(text: s?.team2 ?? '');
    _dateC = TextEditingController(text: s?.date ?? '');
    _timeC = TextEditingController(text: s?.time ?? '');
    _imageUrlC = TextEditingController(text: s?.imageUrl ?? '');
    _captionC = TextEditingController(text: s?.caption ?? '');

    // Parse existing date if editing
    if (s?.date != null && s!.date.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(s.date);
      } catch (_) {}
    }

    // Parse existing time if editing
    if (s?.time != null && s!.time.isNotEmpty) {
      try {
        final parts = s.time.split(':');
        if (parts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _categoryC.dispose();
    _locationC.dispose();
    _team1C.dispose();
    _team2C.dispose();
    _dateC.dispose();
    _timeC.dispose();
    _imageUrlC.dispose();
    _captionC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pacilBlueDarker1,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.neutral900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateC.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pacilBlueDarker1,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.neutral900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeC.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;

    setState(() {
      _submitting = true;
    });

    final ScheduleFormResult result = ScheduleFormResult(
      id: widget.initial?.id,
      category: _categoryC.text.trim(),
      location: _locationC.text.trim(),
      team1: _team1C.text.trim(),
      team2: _team2C.text.trim(),
      date: _dateC.text.trim(),
      time: _timeC.text.trim(),
      imageUrl:
          _imageUrlC.text.trim().isEmpty ? null : _imageUrlC.text.trim(),
      caption: _captionC.text.trim().isEmpty ? null : _captionC.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initial != null;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.pacilBlueDarker1,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Text(
                isEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _categoryC,
                        label: 'Kategori',
                        hint: 'Contoh: Sepak Bola, Basket, Voli',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _locationC,
                        label: 'Lokasi',
                        hint: 'Contoh: Stadion GBK',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _team1C,
                        label: 'Tim 1',
                        hint: 'Nama tim pertama',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _team2C,
                        label: 'Tim 2',
                        hint: 'Nama tim kedua',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      // Date Picker
                      _buildDateField(),
                      const SizedBox(height: 16),

                      // Time Picker
                      _buildTimeField(),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _imageUrlC,
                        label: 'Gambar (URL)',
                        hint: 'https://example.com/image.jpg',
                        required: false,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _captionC,
                        label: 'Catatan / Caption',
                        hint: 'Tambahkan keterangan (opsional)',
                        required: false,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel Button (Outline)
                  OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop<void>(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral700,
                      side: const BorderSide(color: AppColors.neutral300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),

                  // Submit Button (Primary)
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pacilBlueDarker1,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEdit ? 'Submit' : 'Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.neutral500.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.pacilBlueDarker1,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.pacilRedBase),
            ),
          ),
          validator: required
              ? (String? v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateC,
          readOnly: true,
          onTap: _pickDate,
          decoration: InputDecoration(
            hintText: 'Pilih tanggal',
            hintStyle: TextStyle(color: AppColors.neutral500.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.pacilBlueDarker1,
              ),
              onPressed: _pickDate,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.pacilBlueDarker1,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.pacilRedBase),
            ),
          ),
          validator: (String? v) =>
              (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _timeC,
          readOnly: true,
          onTap: _pickTime,
          decoration: InputDecoration(
            hintText: 'Pilih jam',
            hintStyle: TextStyle(color: AppColors.neutral500.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.access_time_rounded,
                color: AppColors.pacilBlueDarker1,
              ),
              onPressed: _pickTime,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.pacilBlueDarker1,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.pacilRedBase),
            ),
          ),
          validator: (String? v) =>
              (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
        ),
      ],
    );
  }
}
