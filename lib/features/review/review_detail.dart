import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/core/django_client.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'models.dart';
import 'review_form_dialog.dart';

class ReviewDetailPage extends StatefulWidget {
  final int scheduleId;
  const ReviewDetailPage({super.key, required this.scheduleId});

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  late DjangoClient _client;
  bool _isClientReady = false;

  @override
  void initState() {
    super.initState();
    _client = DjangoClient(baseUrl: AppConfig.backendBaseUrl);
    _initSession();
  }

  Future<void> _initSession() async {
    await _client.restoreCookies();
    setState(() {
      _isClientReady = true;
    });
  }

  Future<Map<String, dynamic>> fetchDetail() async {
    final response = await _client.get('/review/json/${widget.scheduleId}/');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  // --- 1. CUSTOM SNACKBAR PREMIUM ---
  void showCustomSnackBar(BuildContext context, String message, {
    required bool isSuccess, 
    IconData? customIcon,
    String? customTitle, // Opsional: Judul Headline Custom
  }) {
    final IconData finalIcon = customIcon ?? (isSuccess ? Icons.check_circle_rounded : Icons.error_rounded);
    final Color finalColor = isSuccess ? const Color(0xFF2E7D32) : AppColors.pacilRedBase; 
    final String title = customTitle ?? (isSuccess ? "Berhasil" : "Gagal");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Container Icon Bubble
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(finalIcon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            // Column Text
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
                    maxLines: 2, overflow: TextOverflow.ellipsis,
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
        elevation: 6,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- 2. DELETE DIALOG YANG KONSISTEN & RESPONSIVE ---
  Future<bool> showCreativeDeleteDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            // --- FIXED MAX WIDTH (Agar Konsisten dengan Form Dialog) ---
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Besar di Tengah
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pacilRedBase.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_forever_rounded, color: AppColors.pacilRedBase, size: 40),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    "Hapus Review?",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tindakan ini tidak bisa dibatalkan. Review Anda akan hilang selamanya.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.neutral500),
                  ),
                  
                  const SizedBox(height: 30),

                  // Tombol Sejajar (Konsisten dengan ReviewFormDialog)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
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
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pacilRedBase, // Merah karena Delete
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            shadowColor: AppColors.pacilRedBase.withOpacity(0.4),
                          ),
                          child: const Text(
                            "Hapus", 
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    ) ?? false;
  }

  Future<void> _showReviewForm(BuildContext context, {UserReview? existingReview}) async {
    final bool? result = await showDialog(
      context: context,
      builder: (context) => ReviewFormDialog(
        scheduleId: widget.scheduleId,
        existingReview: existingReview,
      ),
    );

    if (result == true) {
      setState(() {}); 
    }
  }

  Future<void> deleteReview(int reviewId) async {
    bool confirm = await showCreativeDeleteDialog(context);

    if (confirm) {
      final response = await _client.postForm(
        '/review/delete-flutter/$reviewId/',
        body: {}, 
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {}); 
          if (mounted) {
            showCustomSnackBar(
              context, 
              "Review Anda berhasil dihapus dari daftar.", 
              isSuccess: true
            );
          }
        }
      } else {
        if(mounted) showCustomSnackBar(context, "Gagal menghapus review.", isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text("Detail Review", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.pacilBlueDarker2,
        foregroundColor: Colors.white,
      ),
      body: !_isClientReady
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
              future: fetchDetail(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.pacilBlueBase));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: AppColors.pacilRedBase)));
                }

                final data = snapshot.data!;
                final schedule = data['schedule'];
                
                final String location = schedule['location'] ?? '-';
                final String date = schedule['date'] ?? '-';
                final String time = schedule['time'] != null ? schedule['time'].toString().substring(0, 5) : '-';

                final bool canReview = data['can_review'] ?? false;
                final List<UserReview> reviews = (data['reviews'] as List).map((e) => UserReview.fromJson(e)).toList();
                
                UserReview? myReview;
                try {
                  myReview = reviews.firstWhere((r) => r.isOwner);
                } catch (e) {
                  myReview = null;
                }
                bool hasReviewed = myReview != null;

                double averageRating = 0;
                if (reviews.isNotEmpty) {
                  averageRating = reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${schedule['category']}: ${schedule['team1']} vs ${schedule['team2']}",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.neutral500),
                              const SizedBox(width: 4),
                              Text(
                                "$location • $date • $time",
                                style: const TextStyle(fontSize: 14, color: AppColors.neutral500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.neutral300),
                        ],
                      ),
                      
                      const SizedBox(height: 20),

                      // Score Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neutral100),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text("Total Review", style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                                const SizedBox(height: 4),
                                Text(
                                  "${reviews.length}",
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                                ),
                              ],
                            ),
                            Container(height: 40, width: 1, color: AppColors.neutral300),
                            Column(
                              children: [
                                const Text("Rating Rata-Rata", style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      averageRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 32, 
                                        fontWeight: FontWeight.bold, 
                                        color: AppColors.neutral900,
                                        height: 1.0, 
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(children: _buildStarIcons(averageRating, size: 24))
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tombol Logic
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!_client.isAuthenticated) {
                              showCustomSnackBar(context, "Silakan login terlebih dahulu untuk mengakses fitur ini.", isSuccess: false, customTitle: "Akses Ditolak");
                              return;
                            }

                            if (hasReviewed) {
                              showCustomSnackBar(
                                context, 
                                "Kamu sudah memberikan ulasan untuk pertandingan ini.", 
                                isSuccess: false, 
                                customTitle: "Sudah Direview",
                                customIcon: Icons.confirmation_number_outlined 
                              );
                              return; 
                            }

                            if (canReview) {
                              _showReviewForm(context); 
                            } else {
                              showCustomSnackBar(
                                context, 
                                "Anda harus membeli tiket pertandingan ini untuk memberikan review!", 
                                isSuccess: false, 
                                customTitle: "Tiket Diperlukan",
                                customIcon: Icons.confirmation_number_outlined 
                              );
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Tambah Review"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pacilBlueBase,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // List Review
                      const Text(
                        "Review Pertandingan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.neutral900),
                      ),
                      const SizedBox(height: 12),

                      if (reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.rate_review_outlined, size: 40, color: AppColors.neutral300),
                              SizedBox(height: 10),
                              Text("Belum ada review.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.neutral700)),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildReviewCard(reviews[index]);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildReviewCard(UserReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.profilePicture != null && review.profilePicture!.isNotEmpty)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(review.profilePicture!),
                  backgroundColor: AppColors.pacilBlueLight3,
                )
              else
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.pacilBlueLight3,
                  child: Text(
                    review.reviewer.isNotEmpty ? review.reviewer[0].toUpperCase() : "?",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pacilBlueBase),
                  ),
                ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: AppColors.neutral500),
                              children: [
                                const TextSpan(text: "Review dari "),
                                TextSpan(
                                  text: review.reviewer,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pacilBlueDarker1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        if (review.isEdited) ...[ 
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 10, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  "Diedit",
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: Colors.grey.shade600, 
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ..._buildStarIcons(review.rating.toDouble(), size: 14),
                        const SizedBox(width: 8),
                        Text(review.createdAt, style: const TextStyle(fontSize: 11, color: AppColors.neutral500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(review.comment, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.neutral900)),

          if (review.isOwner) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.neutral100),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showReviewForm(context, existingReview: review),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: TextButton.styleFrom(foregroundColor: AppColors.neutral500),
                ),
                TextButton.icon(
                  onPressed: () => deleteReview(review.id),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Hapus"),
                  style: TextButton.styleFrom(foregroundColor: AppColors.pacilRedBase),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  List<Widget> _buildStarIcons(double rating, {double size = 18}) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: size));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
      } else {
        stars.add(Icon(Icons.star_border, color: AppColors.neutral300, size: size));
      }
    }
    return stars;
  }
}