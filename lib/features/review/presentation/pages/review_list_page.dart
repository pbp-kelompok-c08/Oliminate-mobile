import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/scheduling/data/models/schedule.dart'; 
import 'package:oliminate_mobile/features/review/data/datasources/review_api_service.dart';
import 'package:oliminate_mobile/features/review/data/models/reviewable_schedule.dart'; 
import 'review_detail_page.dart';
import '../widgets/review_form.dart'; 

// --- MOCK DATA GLOBAL UNTUK FALLBACK ---
// Dibuat sebagai final List<ReviewableSchedule>
final List<ReviewableSchedule> _globalMockEvents = [
  ReviewableSchedule.fromJson({
    'id': 100, 'category': 'FUTSAL', 'team1': 'FASILKOM', 'team2': 'FT', 
    'location': 'GOR Fasilkom', 'date': '2025-11-20', 'time': '19:00', 'status': 'reviewable',
    'image_url': 'https://placehold.co/600x400/3293EC/FFFFFF?text=Futsal+Final',
    'avg_rating': 4.5, 'review_count': 12, 'caption': 'Pertandingan final simulasi.',
  }),
  ReviewableSchedule.fromJson({
    'id': 101, 'category': 'BADMINTON', 'team1': 'FH', 'team2': 'FISIP', 
    'location': 'Gymnasium', 'date': '2025-11-21', 'time': '14:00', 'status': 'reviewable',
    'image_url': 'https://placehold.co/600x400/9E292D/FFFFFF?text=Badminton+Simulasi',
    'avg_rating': 3.1, 'review_count': 5, 'caption': 'Laga beregu pertama simulasi.',
  }),
];
// ----------------------------------------


class ReviewListPage extends StatefulWidget {
  const ReviewListPage({
    super.key,
    required this.baseUrl,
    this.currentUsername,
    this.authHeaders,
  });

  final String baseUrl;
  final String? currentUsername;
  final Map<String, String>? authHeaders;

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late final ReviewApiService _reviewApi; 
  
  bool _loading = false;
  bool _error = false;
  // Diinisialisasi sebagai list kosong yang aman (non-nullable)
  List<ReviewableSchedule> _reviewableEvents = const []; 
  String _currentSort = '-review_count'; 

  @override
  void initState() {
    super.initState();
    _reviewApi = ReviewApiService(
      baseUrl: widget.baseUrl,
      defaultHeaders: widget.authHeaders ?? <String, String>{},
    );
    _fetchReviewableEvents();
  }

  Future<void> _fetchReviewableEvents({bool showSnack = false}) async {
    // 1. Mulai Loading/Reset Error State
    setState(() {
      _loading = true;
      _error = false;
    });

    List<ReviewableSchedule> fetchedEvents = [];
    bool fetchFailed = false;

    try {
      // Panggilan API
      fetchedEvents = await _reviewApi.fetchReviewableEvents();
      if (!mounted) return;
      
      _reviewableEvents = fetchedEvents; // Assign list yang berhasil di fetch

    } catch (e) {
      if (!mounted) return;
      fetchFailed = true;
      if (showSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat event: ${e.toString()}. Menampilkan data simulasi.')),
        );
      }

    } finally {
      // 2. Selesaikan Loading/Set Final State
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = fetchFailed;
        
        // Logika Fallback Teraman:
        // Jika fetch gagal (_error=true) DAN list hasil fetch (setelah error) kosong,
        // kita timpa dengan mock data agar UI tampil.
        if (_error && _reviewableEvents.isEmpty) {
             _reviewableEvents = _globalMockEvents;
        } else if (!_error && _reviewableEvents.isEmpty) {
             // Jika tidak ada error tapi list kosong, biarkan kosong.
             _reviewableEvents = const [];
        }
      });
    }
  }
  
  void _openReviewDetail(Schedule schedule) {
     Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewDetailPage(
          schedule: schedule,
          apiService: _reviewApi,
          currentUsername: widget.currentUsername,
        ),
      ),
    ).then((_) {
      _fetchReviewableEvents(); 
    });
  }

  Widget _buildStarRating(double rating) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;
    final int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(fullStars, (index) => const Icon(Icons.star, color: Colors.amber, size: 18)),
        if (hasHalfStar) const Icon(Icons.star_half, color: Colors.amber, size: 18),
        ...List.generate(emptyStars, (index) => const Icon(Icons.star_border, color: AppColors.neutral300, size: 18)),
      ],
    );
  }
  
  // Widget Dropdown Sorting (meniru style HTML)
  Widget _buildSortDropdown() {
    final List<Map<String, String>> sortOptions = [
      {'value': '-review_count', 'label': 'Paling Populer (Ulasan Terbanyak)'},
      {'value': 'highest_rating', 'label': 'Rating Tertinggi (5, 4, 3...)'},
      {'value': 'lowest_rating', 'label': 'Rating Terendah (1, 2, 3...)'},
    ];

    return DropdownButtonHideUnderline(
      child: Container( 
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButton<String>(
          value: _currentSort,
          alignment: Alignment.centerRight,
          borderRadius: BorderRadius.circular(10),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.pacilBlueDarker2),
          style: const TextStyle(fontSize: 14, color: AppColors.neutral900),
          dropdownColor: Colors.white,
          items: sortOptions.map((Map<String, String> option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label']!, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _currentSort = newValue;
              });
              // Logika sorting yang sebenarnya akan ada di Django API
            }
          },
        ),
      ),
    );
  }

  // Widget untuk menampilkan setiap event dalam bentuk card
  Widget _buildEventCard(ReviewableSchedule rs) {
    final Schedule s = rs.schedule;
    final String? imageUrl = rs.imageUrl;
    final double avgRating = rs.avgRating;
    final int reviewCount = rs.reviewCount;

    return GestureDetector(
      onTap: () => _openReviewDetail(s),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image / Placeholder Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 150,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildNoImagePlaceholder(),
                      )
                    : _buildNoImagePlaceholder(),
              ),
            ),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.team1} vs ${s.team2}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.neutral900),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Rating Section 
                        Row(
                          children: [
                            _buildStarRating(avgRating),
                            const SizedBox(width: 8),
                            Text(
                              '${avgRating.toStringAsFixed(1)} ($reviewCount review)',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.neutral700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Text(
                          '${s.category} — ${s.location}',
                          style: const TextStyle(fontSize: 14, color: AppColors.neutral700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (s.caption != null && s.caption!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              s.caption!,
                              style: const TextStyle(fontSize: 13, color: AppColors.neutral500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    
                    // Button Section
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _openReviewDetail(s),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.pacilBlueBase,
                            side: const BorderSide(color: AppColors.pacilBlueBase, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Lihat Review', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoImagePlaceholder() {
    return Container(
      color: AppColors.neutral100,
      alignment: Alignment.center,
      child: const Text(
        'No Image',
        style: TextStyle(fontSize: 12, color: AppColors.neutral500),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Logika penentuan list yang akan ditampilkan.
    // Jika _error TRUE DAN _reviewableEvents kosong (berarti fetch gagal dan belum ada data),
    // kita gunakan mock data.
    final List<ReviewableSchedule> displayEvents = _error && _reviewableEvents.isEmpty ? _globalMockEvents : _reviewableEvents;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Pertandingan'),
        backgroundColor: AppColors.pacilBlueDarker2,
      ),
      backgroundColor: AppColors.neutral50,
      body: RefreshIndicator(
        onRefresh: _fetchReviewableEvents,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header dan Sorting
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Event yang Siap Diberi Ulasan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  _buildSortDropdown(),
                ],
              ),
            ),
            
            // State indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error
                      ? Center(child: Text('Terjadi error saat memuat event. Menampilkan data simulasi.', style: TextStyle(fontSize: 12, color: AppColors.pacilRedBase)))
                      : displayEvents.isEmpty 
                          ? const Center(child: Text('Tidak ada event yang siap untuk direview.', style: TextStyle(fontSize: 12, color: AppColors.neutral500)))
                          : const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 12),
            
            // Grid View Event Reviewable
            Expanded(
              child: displayEvents.isEmpty && !_loading && !_error
                  ? const SizedBox.shrink()
                  : LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final int crossAxisCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                                
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: crossAxisCount == 1 ? 0.8 : 0.7, 
                          ),
                          itemCount: displayEvents.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ReviewableSchedule rs = displayEvents[index];
                            return _buildEventCard(rs);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}