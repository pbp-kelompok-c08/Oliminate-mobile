import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/user-profile/main_profile.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'models.dart';
import 'review_detail.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  String _sortOption = '-review_count';
  final _authRepo = AuthRepository.instance;

  Future<List<EventReview>> fetchEvents() async {
    await _authRepo.init();
    final res = await _authRepo.client.get('/review/json/?sort=$_sortOption');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((d) => EventReview.fromJson(d)).toList();
    } else {
      throw Exception('Gagal memuat data');
    }
  }

  // Color palette matching ticketing design
  static const Color _primaryDark = Color(0xFF113352);
  static const Color _primaryBlue = Color(0xFF3293EC);
  static const Color _accentTeal = Color(0xFF0D9488);
  static const Color _primaryRed = Color(0xFFEA3C43);
  static const Color _neutralBg = Color(0xFFF5F5F5);
  static const Color _textDark = Color(0xFF113352);
  static const Color _textGrey = Color(0xFF3D3D3D);
  static const Color _borderLight = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _neutralBg,
      appBar: AppBar(
        title: const Text(
          'Review Pertandingan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _buildHeaderControls(),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<EventReview>>(
                  future: fetchEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: _primaryBlue));
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: _primaryRed)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: _primaryBlue,
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderLight),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortOption,
              icon: Icon(Icons.sort_rounded, color: _primaryBlue, size: 18),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textGrey),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: _primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pertandingan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Cek lagi nanti untuk memberikan review Anda.',
            style: TextStyle(fontSize: 13, color: _textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- HELPER: Proxy URL for external images to avoid CORS issues ---
  String _getProxyImageUrl(String imageUrl) {
    final encodedUrl = Uri.encodeComponent(imageUrl);
    return '${AppConfig.backendBaseUrl}/merchandise/proxy-image/?url=$encodedUrl';
  }

  // --- EVENT CARD ---
  Widget _buildEventCard(EventReview event) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewDetailPage(scheduleId: event.id))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 160,
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? Image.network(
                        _getProxyImageUrl(event.imageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholder(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: _primaryBlue,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : _placeholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${event.team1} vs ${event.team2}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ..._buildStarIcons(event.avgRating),
                        const SizedBox(width: 8),
                        Text(event.avgRating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: _textDark)),
                        Text(" (${event.reviewCount})", style: TextStyle(color: _textGrey, fontSize: 12)),
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
        Icon(icon, size: 14, color: _textGrey),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: _textGrey)),
      ],
    );
  }

  Widget _actionButton(EventReview event) {
    return Container(
      decoration: BoxDecoration(
        color: _accentTeal,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewDetailPage(scheduleId: event.id))),
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text('Lihat Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.image_outlined, size: 48, color: _textGrey.withOpacity(0.5)),
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
        stars.add(Icon(Icons.star_border, color: _borderLight, size: 18));
      }
    }
    return stars;
  }
}