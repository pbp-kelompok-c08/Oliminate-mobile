import 'package:oliminate_mobile/features/scheduling/data/models/schedule.dart';

// Model ini digunakan HANYA di modul Review untuk menampung data Schedule
// yang diperkaya dengan data rating dan count, tanpa memodifikasi model Schedule asli.
class ReviewableSchedule {
  // Gunakan Schedule asli untuk properti dasar (id, category, team1, dll.)
  final Schedule schedule; 
  
  // Properti tambahan dari API Review yang tidak ada di model Schedule asli:
  final String? imageUrl; 
  final double avgRating;
  final int reviewCount;

  const ReviewableSchedule({
    required this.schedule,
    this.imageUrl,
    required this.avgRating,
    required this.reviewCount,
  });

  factory ReviewableSchedule.fromJson(Map<String, dynamic> json) {
    // Helper untuk mengolah nilai yang mungkin berupa string, int, atau double
    double? parseToDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }
    
    // --- LANGKAH PENTING: MENYARING JSON UNTUK MODEL SCHEDULE ASLI ---
    // Buat salinan JSON agar Schedule.fromJson hanya melihat field yang dikenali.
    final Map<String, dynamic> scheduleJsonCopy = Map<String, dynamic>.from(json);
    
    // Hapus field yang asing dari API Review.
    // Ini penting agar Schedule.fromJson TIDAK error.
    scheduleJsonCopy.remove('image_url');
    scheduleJsonCopy.remove('avg_rating');
    scheduleJsonCopy.remove('review_count');

    // 1. Ambil data mentah Schedule (aman karena field asing sudah dihapus)
    final Schedule baseSchedule = Schedule.fromJson(scheduleJsonCopy);

    // 2. Buat objek ReviewableSchedule
    return ReviewableSchedule(
      schedule: baseSchedule,
      // Ambil data tambahan dari JSON API original
      imageUrl: json['image_url'] as String?, 
      avgRating: parseToDouble(json['avg_rating']) ?? 0.0,
      reviewCount: (json['review_count'] ?? 0) as int, 
    );
  }
}