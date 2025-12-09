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

  // --- 1. CUSTOM SNACKBAR HELPER ---
  void showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.confirmation_number_outlined, // Icon Tiket/Check
              color: Colors.white, 
              size: 28,
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
            ? AppColors.pacilRedBase // Merah untuk Error
            : const Color(0xFFE53935), // Merah "Mahal" (Red 600) untuk sukses sesuai request
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- 2. CUSTOM DELETE DIALOG ---
  Future<bool> showCreativeDeleteDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Hapus Review?",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Yakin ingin menghapus review ini? Tindakan ini tidak bisa dibatalkan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.neutral500),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal", style: TextStyle(color: AppColors.neutral500)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pacilRedBase,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: CircleAvatar(
                  backgroundColor: AppColors.pacilRedBase.withOpacity(0.1),
                  radius: 35,
                  child: const Icon(Icons.delete_forever_rounded, color: AppColors.pacilRedBase, size: 35),
                ),
              ),
            ],
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
    // PANGGIL DIALOG BARU DISINI
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
            // PANGGIL SNACKBAR BARU DISINI
            showCustomSnackBar(context, "Review berhasil dihapus");
          }
        }
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      averageRating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(children: _buildStarIcons(averageRating, size: 20))
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
                              showCustomSnackBar(context, "Silakan login terlebih dahulu.", isError: true);
                              return;
                            }

                            if (hasReviewed) {
                              // USER MINTA WARNA MERAH UNTUK WARNING INI
                              showCustomSnackBar(context, "Kamu sudah menambahkan review!", isError: false);
                              return; 
                            }

                            if (canReview) {
                              _showReviewForm(context); 
                            } else {
                              showCustomSnackBar(context, "Anda harus membeli tiket untuk review!", isError: true);
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
                    // --- 3. LABEL DIEDIT (Sign Diedit) ---
                    Row(
                      children: [
                        Flexible(
                          child: RichText(
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
                        // Logika sederhana: Jika mau nampilin label, ganti true/logic kamu
                        if (true) ...[ 
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Text(
                              "Diedit",
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
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