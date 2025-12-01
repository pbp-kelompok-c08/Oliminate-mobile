// lib/features/review/data/models/review.dart
class Review {
  const Review({
    required this.id,
    required this.scheduleId,
    required this.reviewerUsername,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.updatedAt,
  });

  final int id;
  final int scheduleId;
  final String reviewerUsername;
  final int rating;
  final String? comment;
  final String createdAt;
  final String? updatedAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      scheduleId: json['schedule_id'] as int,
      reviewerUsername: (json['reviewer'] ?? 'Anonim') as String,
      rating: json['rating'] as int,
      comment: (json['comment'] ?? '') as String,
      createdAt: (json['created_at'] ?? '') as String,
      updatedAt: json['updated_at'] as String?,
    );
  }
  
  // Helper untuk mengecek kepemilikan
  bool isOwnedBy(String? username) {
    return username != null && reviewerUsername == username;
  }
}