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
    _initSession();

    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _comment = widget.existingReview!.comment;
    }
  }

  Future<void> _initSession() async {
    await _client.restoreCookies();
  }

  // --- CUSTOM SNACKBAR PREMIUM ---
  void showCustomSnackBar(BuildContext context, String message, {
    required bool isSuccess, 
    IconData? customIcon,
    String? customTitle, // Opsional: Judul Headline Custom
  }) {
    final IconData finalIcon = customIcon ?? (isSuccess ? Icons.check_circle_rounded : Icons.error_rounded);
    final Color finalColor = isSuccess ? const Color(0xFF2E7D32) : AppColors.pacilRedBase; // Hijau Tua vs Merah
    final String title = customTitle ?? (isSuccess ? "Berhasil" : "Gagal");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Container Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(finalIcon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            // Column Text (Headline & Subheadline)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: finalColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      showCustomSnackBar(context, "Berikan bintang terlebih dahulu.", isSuccess: false, customTitle: "Rating Kosong");
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
        body: {'rating': _rating.toString(), 'comment': _comment},
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            Navigator.pop(context, true);
            showCustomSnackBar(
              context, 
              isEdit ? "Ulasan Anda telah diperbarui." : "Ulasan berhasil ditambahkan.", 
              isSuccess: true
            );
          } else {
             showCustomSnackBar(context, data['message'] ?? "Gagal menyimpan data.", isSuccess: false);
          }
        } else {
          showCustomSnackBar(context, "Terjadi kesalahan server (${response.statusCode}).", isSuccess: false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showCustomSnackBar(context, "Periksa koneksi internet Anda.", isSuccess: false, customTitle: "Koneksi Error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReview != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400), 
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? "Edit Review" : "Tulis Review",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bagaimana pengalaman pertandingan ini?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.neutral500, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // --- RATING STAR DENGAN KOTAK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isActive = starValue <= _rating;
                      
                      return GestureDetector(
                        onTap: () => setState(() => _rating = starValue),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 6), // Jarak antar kotak
                          padding: const EdgeInsets.all(10), // Jarak bintang ke garis kotak
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12), // Sudut kotak agak melengkung
                            border: Border.all(
                              // Jika aktif (dipilih) warna kuning, jika tidak abu-abu muda
                              color: isActive ? Colors.amber : AppColors.neutral300, 
                              width: 2, // Ketebalan garis
                            ),
                            // Opsional: Tambah bayangan sedikit kalau aktif
                            boxShadow: isActive ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ] : [],
                          ),
                          child: Icon(
                            // Gunakan rounded star agar lebih modern
                            Icons.star_rounded, 
                            size: 32,
                            // Warna bintang: Kuning jika aktif, Abu-abu jika tidak
                            color: isActive ? Colors.amber : AppColors.neutral300,
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  if (_rating > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      _rating == 5 ? "Sempurna!" : _rating >= 4 ? "Sangat Bagus" : _rating >= 3 ? "Bagus" : "Kurang",
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                    )
                  ],

                  const SizedBox(height: 24),

                  // Text Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, fontFamily: 'Plus Jakarta Sans'), 
                        children: [
                          const TextSpan(text: "Komentar ", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.neutral900)),
                          TextSpan(text: "(Opsional)", style: TextStyle(color: AppColors.neutral300, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _comment,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Ceritakan pengalamanmu...",
                      hintStyle: const TextStyle(color: AppColors.neutral300),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.neutral300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.neutral300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.pacilBlueBase, width: 1.5)),
                      filled: true,
                      fillColor: AppColors.neutral50,
                    ),
                    onChanged: (val) => _comment = val,
                    validator: (val) => null, 
                  ),
                  
                  const SizedBox(height: 30),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.neutral300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            foregroundColor: AppColors.neutral700,
                          ),
                          child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pacilBlueBase,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            shadowColor: AppColors.pacilBlueBase.withOpacity(0.4),
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                isEdit ? "Simpan" : "Kirim", 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                              ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}