import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:oliminate_mobile/core/app_config.dart'; // Pastikan import ini ada
import 'models.dart';
import 'review_detail.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/left_drawer.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  // Default sort sesuai HTML: selected value="-review_count"
  String _sortOption = '-review_count';

  Future<List<EventReview>> fetchEvents(CookieRequest request) async {
    // Menggunakan AppConfig agar aman di Localhost/Android
    final String url = '${AppConfig.backendBaseUrl}/review/json/?sort=$_sortOption';
    final response = await request.get(url);
    
    List<EventReview> listEvents = [];
    for (var d in response) {
      if (d != null) {
        listEvents.add(EventReview.fromJson(d));
      }
    }
    return listEvents;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background agak abu terang biar card pop-up
      appBar: AppBar(
        title: const Text(
          'Review Pertandingan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF22629E), // Pacil Blue
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: LeftDrawer(),
      body: Column(
        children: [
          // === BAGIAN HEADER & SORTING (Mirip div class="flex justify-between") ===
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.white, // Header putih
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Event",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF22629E)),
                ),
                // Dropdown Sort
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8), // rounded-lg
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      icon: const Icon(Icons.sort, size: 20),
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                      items: const [
                        DropdownMenuItem(value: '-review_count', child: Text("Paling Populer")),
                        DropdownMenuItem(value: 'highest_rating', child: Text("Rating Tertinggi")),
                        DropdownMenuItem(value: 'lowest_rating', child: Text("Rating Terendah")),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _sortOption = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === BAGIAN LIST CARD (Mirip div class="grid") ===
          Expanded(
            child: FutureBuilder(
              future: fetchEvents(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Belum ada pertandingan yang tersedia", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Logic Grid: Jika lebar > 600 (Tablet/Web) pake 3 kolom, HP pake 2 kolom
                    int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    double aspectRatio = crossAxisCount == 2 ? 0.80 : 0.85;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, 
                        crossAxisSpacing: 16, // Jarak antar kolom
                        mainAxisSpacing: 16,  // Jarak antar baris
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        final event = snapshot.data![index];
                        return _buildEventCard(event);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET CARD DESIGN (Translasi dari class="card schedule-card") ===
  Widget _buildEventCard(EventReview event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // border-radius: 12px
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // shadow halus
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewDetailPage(scheduleId: event.id),
              ),
           );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR (Mirip tag <img>)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                  ? Image.network(
                      event.imageUrl!,
                      height: 180, // height: 200px (disesuaikan dikit biar proporsional di HP)
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildNoImage(),
                    )
                  : _buildNoImage(),
            ),

            // 2. KONTEN (Mirip div style="padding:16px")
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Team
                  Text(
                    "${event.team1} vs ${event.team2}",
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900, // Text Gray Dark
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Rating Section (Bintang & Angka)
                  Row(
                    children: [
                      // Render Bintang
                      ..._buildStarIcons(event.avgRating),
                      const SizedBox(width: 8),
                      // Text Rating
                      Text(
                        "${event.avgRating.toStringAsFixed(1)} ",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        "(${event.reviewCount} review)",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Metadata (Category & Location)
                  Row(
                    children: [
                      Icon(Icons.category, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        event.category,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tanggal & Waktu
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.pacilBlueLight3, // Light Blue Background
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Text(
                          "${event.date} | ${event.time.substring(0, 5)}",
                          style: const TextStyle(
                            color: AppColors.pacilBlueBase,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. TOMBOL (Mirip a class="btn btn-outline")
            // Tombol Detail
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity, // Bikin full width
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewDetailPage(scheduleId: event.id),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(
                      color: AppColors.pacilBlueBase,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Lihat Review',
                    style: TextStyle(
                      color: AppColors.pacilBlueBase,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk Placeholder No Image
  Widget _buildNoImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.neutral100,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
          SizedBox(height: 5),
          Text("No Image", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Helper untuk Membuat Ikon Bintang (Full, Half, Empty)
  List<Widget> _buildStarIcons(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.grey[400], size: 18));
      }
    }
    return stars;
  }
}