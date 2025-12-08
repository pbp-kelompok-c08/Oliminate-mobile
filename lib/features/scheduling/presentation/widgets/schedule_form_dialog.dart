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

    return AlertDialog(
      title: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _textField(_categoryC, 'Kategori', requiredField: true),
              _textField(_locationC, 'Lokasi', requiredField: true),
              _textField(_team1C, 'Tim 1', requiredField: true),
              _textField(_team2C, 'Tim 2', requiredField: true),
              _textField(
                _dateC,
                'Tanggal (YYYY-MM-DD)',
                requiredField: true,
              ),
              _textField(
                _timeC,
                'Jam (HH:MM)',
                requiredField: true,
              ),
              _textField(_imageUrlC, 'Gambar (URL)'),
              _textField(_captionC, 'Catatan / Caption', maxLines: 3),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed:
              _submitting ? null : () => Navigator.of(context).pop<void>(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pacilBlueBase,
          ),
          child: Text(isEdit ? 'Simpan' : 'Buat'),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController c,
    String label, {
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: requiredField
            ? (String? v) =>
                (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
            : null,
      ),
    );
  }
}


