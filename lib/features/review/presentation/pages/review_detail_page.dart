import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/scheduling/data/models/schedule.dart'; 
import '../../data/models/review.dart';
import '../../data/datasources/review_api_service.dart';
import '../widgets/review_card.dart';
import '../widgets/review_form.dart';

class ReviewDetailPage extends StatefulWidget {
  const ReviewDetailPage({
    super.key,
    required this.schedule,
    required this.apiService,
    this.currentUsername, 
  });
  
  final Schedule schedule;
  final ReviewApiService apiService;
  final String? currentUsername;

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  bool _loading = false;
  bool _error = false;
  
  // Data dari API
  List<Review> _otherReviews = <Review>[];
  Review? _userReview; 
  double _avgRating = 0.0;
  int _reviewCount = 0;
  bool _canReview = false; // Memerlukan pembelian tiket

  @override
  void initState() {
    super.initState();
    _fetchReviewDetail();
  }

  Future<void> _fetchReviewDetail() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final Map<String, dynamic> data = await widget.apiService.fetchReviewDetailData(widget.schedule.id);

      final List<Review> allReviews = data['reviews'] as List<Review>;

      // Reset data
      _userReview = null;
      _otherReviews = [];
      _avgRating = data['avg_rating'] as double;
      _reviewCount = data['review_count'] as int;
      _canReview = data['can_review'] as bool;

      // Pisahkan review milik user dari review lainnya
      if (widget.currentUsername != null) {
        final int userReviewIndex = allReviews.indexWhere(
          (Review r) => r.isOwnedBy(widget.currentUsername),
        );
        
        if (userReviewIndex != -1) {
          _userReview = allReviews[userReviewIndex];
          _otherReviews = List<Review>.from(allReviews)..removeAt(userReviewIndex);
        } else {
          _otherReviews = allReviews;
        }
      } else {
        _otherReviews = allReviews;
      }

    } catch (e) {
      _error = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat ulasan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- CRUD Logic ---
  Future<void> _handleCreateOrUpdate(ReviewFormData initialData) async {
    if (widget.currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk memberi ulasan.')),
      );
      return;
    }
    
    final ReviewFormData? result = await showDialog<ReviewFormData>(
      context: context,
      builder: (_) => ReviewForm(initialData: initialData),
    );

    if (result == null) return;

    try {
      final String action = result.reviewId == null ? 'membuat' : 'mengupdate';
      await (result.reviewId == null
          ? widget.apiService.createReview(result)
          : widget.apiService.updateReview(result));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ulasan berhasil di$action.')),
        );
      }
      await _fetchReviewDetail(); // Refresh data
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ${initialData.reviewId == null ? 'membuat' : 'mengupdate'} ulasan: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _confirmDelete(int reviewId) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Ulasan'),
        content: const Text('Yakin ingin menghapus ulasan Anda?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pacilRedBase),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await widget.apiService.deleteReview(reviewId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan terhapus.')));
      await _fetchReviewDetail();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus ulasan.')));
    }
  }
  
  // Renders a consolidated card for the current user's review or a "Create" button
  Widget _buildUserReviewSection() {
    if (_userReview != null) {
      // User sudah membuat review
      final Review r = _userReview!;
      final ReviewFormData formData = ReviewFormData(
        reviewId: r.id,
        scheduleId: r.scheduleId,
        rating: r.rating,
        comment: r.comment ?? '',
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Ulasan Anda:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ReviewCard(
            review: r,
            isOwner: true,
            onEdit: () => _handleCreateOrUpdate(formData),
            onDelete: () => _confirmDelete(r.id),
          ),
        ],
      );
    } else if (widget.currentUsername != null && _canReview) {
      // User login, belum review, dan memenuhi syarat (sudah beli tiket)
      final ReviewFormData formData = ReviewFormData(
        scheduleId: widget.schedule.id,
        rating: 0, 
        comment: '',
      );
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => _handleCreateOrUpdate(formData),
          icon: const Icon(Icons.star),
          label: const Text('+ Tambah Ulasan Anda', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      );
    } else if (widget.currentUsername != null && !_canReview) {
      // User login tapi belum beli tiket
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            '⚠️ Anda harus membeli tiket event ini untuk dapat memberi ulasan.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.pacilRedDarker1),
          ),
        ),
      );
    } else {
      // User belum login
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'Silakan login untuk dapat memberi ulasan pada event ini.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.neutral500),
          ),
        ),
      );
    }
  }
  
  Widget _buildStarRating(double rating) {
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;
    final int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(fullStars, (index) => const Icon(Icons.star, color: Colors.amber, size: 20)),
        if (hasHalfStar) const Icon(Icons.star_half, color: Colors.amber, size: 20),
        ...List.generate(emptyStars, (index) => const Icon(Icons.star_border, color: AppColors.neutral300, size: 20)),
        const SizedBox(width: 8),
        Text(
          '${rating.toStringAsFixed(1)} ($_reviewCount Ulasan)',
          style: const TextStyle(fontSize: 14, color: AppColors.neutral700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.schedule.team1} vs ${widget.schedule.team2} Review'),
        backgroundColor: AppColors.pacilBlueDarker2,
      ),
      backgroundColor: AppColors.neutral50,
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Gagal memuat data review.', style: TextStyle(color: AppColors.pacilRedBase)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchReviewDetail, 
                      child: const Text('Coba Lagi')
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Event Header Info
                  Text(
                    '${widget.schedule.category}: ${widget.schedule.team1} vs ${widget.schedule.team2}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.schedule.location} | ${widget.schedule.date} @ ${widget.schedule.time}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.neutral700),
                  ),
                  const SizedBox(height: 12),
                  
                  // Average Rating Display
                  _buildStarRating(_avgRating),
                  
                  const Divider(height: 32, thickness: 1),
                  
                  // User Review Section (Logika 1 User = 1 Review)
                  _buildUserReviewSection(),

                  const Divider(height: 32, thickness: 1),

                  // Other Reviews
                  Text(
                    'Ulasan Lain (${_otherReviews.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_otherReviews.isEmpty)
                    const Center(child: Text('Belum ada ulasan dari pengguna lain.')),
                  
                  ..._otherReviews.map((Review r) => ReviewCard(
                    review: r,
                    isOwner: false, 
                    onEdit: () {}, 
                    onDelete: () {},
                  )).toList(),
                ],
              ),
            ),
    );
  }
}