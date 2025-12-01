import 'package:flutter/material.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import '../../data/datasources/review_api_service.dart';

class ReviewForm extends StatefulWidget {
  const ReviewForm({super.key, this.initialData});

  final ReviewFormData? initialData;

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _commentC;
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _commentC = TextEditingController(text: widget.initialData?.comment ?? '');
    _currentRating = widget.initialData?.rating ?? 0;
  }

  @override
  void dispose() {
    _commentC.dispose();
    super.dispose();
  }
  
  void _submit() {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating wajib diisi.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final ReviewFormData result = ReviewFormData(
      reviewId: widget.initialData?.reviewId,
      scheduleId: widget.initialData!.scheduleId, // Schedule ID harus selalu ada
      rating: _currentRating,
      comment: _commentC.text.trim(),
    );

    // Mengembalikan data form yang sudah divalidasi ke halaman Detail
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initialData?.reviewId != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Ulasan' : 'Tambah Ulasan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Rating Selector
              const Text('Beri Rating Anda (1-5)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(5, (int index) {
                  final int starValue = index + 1;
                  final bool isSelected = starValue <= _currentRating;
                  return IconButton(
                    icon: Icon(
                      isSelected ? Icons.star : Icons.star_border,
                      color: isSelected ? Colors.amber : AppColors.neutral300,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentRating = starValue;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              
              // Comment Field
              TextFormField(
                controller: _commentC,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Komentar Anda',
                  hintText: 'Ceritakan pengalaman Anda di sini...',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) => (v == null || v.trim().isEmpty) ? 'Komentar wajib diisi' : null,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop<void>(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pacilBlueBase,
          ),
          child: Text(isEdit ? 'Perbarui' : 'Kirim Ulasan'),
        ),
      ],
    );
  }
}