import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/user-profile/edit_profile.dart'; // Import untuk navigasi profil
import 'models.dart';
import 'review_detail.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String _sortOption = '-review_count';

  Future<List<EventReview>> fetchEvents(CookieRequest request) async {
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
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Review Pertandingan'),
        backgroundColor: AppColors.pacilBlueDarker1, //
        foregroundColor: Colors.white,
        elevation: 0,
        // Hapus Left Drawer dengan mengganti leading menjadi null (opsional) atau matikan otomatis
        automaticallyImplyLeading: false, 
        actions: [
          // IKON ORANG DI SISI KANAN (Sama dengan Scheduling Page)
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      // Drawer dihapus agar tidak muncul ikon garis tiga di kiri
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _buildHeaderControls(),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder(
                  future: fetchEvents(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.pacilBlueBase));
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: AppColors.pacilRedBase)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (_, index) {
                          final event = snapshot.data![index];
                          return _buildEventCard(event);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HEADER & DROPDOWN ---
  Widget _buildHeaderControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Daftar Event",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortOption,
              icon: const Icon(Icons.sort_rounded, color: AppColors.pacilBlueDarker1),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral700),
              items: const [
                DropdownMenuItem(value: '-review_count', child: Text("Populer")),
                DropdownMenuItem(value: 'highest_rating', child: Text("Rating ↑")),
                DropdownMenuItem(value: 'lowest_rating', child: Text("Rating ↓")),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _sortOption = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.pacilBlueDarker1.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: AppColors.pacilBlueDarker1.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada pertandingan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.neutral900),
          ),
          const SizedBox(height: 8),
          Text(
            'Cek lagi nanti untuk memberikan review Anda.',
            style: TextStyle(fontSize: 14, color: AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- EVENT CARD ---
  Widget _buildEventCard(EventReview event) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewDetailPage(scheduleId: event.id))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 180,
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                    : _placeholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${event.team1} vs ${event.team2}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ..._buildStarIcons(event.avgRating),
                        const SizedBox(width: 8),
                        Text(event.avgRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(" (${event.reviewCount})", style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _iconInfo(Icons.category_outlined, event.category),
                    const SizedBox(height: 4),
                    _iconInfo(Icons.location_on_outlined, event.location),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _actionButton(event),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.neutral500),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: AppColors.neutral700)),
      ],
    );
  }

  Widget _actionButton(EventReview event) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.pacilBlueDarker1, AppColors.pacilBlueBase]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewDetailPage(scheduleId: event.id))),
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Lihat Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.neutral100,
      child: Icon(Icons.image_outlined, size: 48, color: AppColors.neutral500),
    );
  }

  List<Widget> _buildStarIcons(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (i <= rating.floor()) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
      } else if (i == rating.floor() + 1 && (rating - rating.floor()) >= 0.5) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
      } else {
        stars.add(Icon(Icons.star_border, color: AppColors.neutral300, size: 18));
      }
    }
    return stars;
  }
}