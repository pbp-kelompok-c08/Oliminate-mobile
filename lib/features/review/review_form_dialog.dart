import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/core/django_client.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'models.dart';

class ReviewFormDialog extends StatefulWidget {
  final int scheduleId;
  final UserReview? existingReview;

  const ReviewFormDialog({
    super.key,
    required this.scheduleId,
    this.existingReview,
  });

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  String _comment = "";
  bool _isLoading = false;
  late DjangoClient _client;

  @override
  void initState() {
    super.initState();
    _client = DjangoClient(baseUrl: AppConfig.backendBaseUrl);
    _client.restoreCookies(); 

    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _comment = widget.existingReview!.comment;
    }
  }

  // --- CUSTOM SNACKBAR HELPER (Copy) ---
  void showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.confirmation_number_outlined, 
              color: Colors.white, size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isError ? "Perhatian" : "Berhasil",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isError 
            ? AppColors.pacilRedBase 
            : const Color(0xFFE53935), // Merah sesuai request
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      showCustomSnackBar(context, "Silakan pilih rating bintang terlebih dahulu!", isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final isEdit = widget.existingReview != null;
    final url = isEdit
        ? '/review/edit-flutter/${widget.existingReview!.id}/'
        : '/review/add-flutter/${widget.scheduleId}/';

    try {
      final response = await _client.postForm(
        url,
        body: {
          'rating': _rating.toString(),
          'comment': _comment,
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            Navigator.pop(context, true); // Sukses
            // PAKAI CUSTOM SNACKBAR DI SINI
            showCustomSnackBar(context, isEdit ? "Review berhasil diperbarui!" : "Review berhasil ditambahkan!");
          } else {
             showCustomSnackBar(context, data['message'] ?? "Gagal menyimpan", isError: true);
          }
        } else {
          showCustomSnackBar(context, "Terjadi kesalahan server", isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showCustomSnackBar(context, "Error: $e", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReview != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Bantu kami menjadi lebih baik!",
                  textAlign: TextAlign.center,
                  // --- FIX: FONT WEIGHT JADI W600 ---
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.neutral900),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Bagaimana Anda akan mendeskripsikan pengalaman Anda?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.neutral500, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final isActive = starValue <= _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starValue),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          size: 32,
                          color: isActive ? Colors.amber : AppColors.neutral300,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Comment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bagikan Pengalaman Anda", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral900)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _comment,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Tulis review Anda di sini...",
                        hintStyle: const TextStyle(color: AppColors.neutral300),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.neutral300)),
                      ),
                      onChanged: (val) => _comment = val,
                      validator: (val) => val == null || val.isEmpty ? "Komentar tidak boleh kosong" : null,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.neutral700,
                        side: const BorderSide(color: AppColors.neutral300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Batal"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pacilBlueBase,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isEdit ? "Perbarui" : "Kirim"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}