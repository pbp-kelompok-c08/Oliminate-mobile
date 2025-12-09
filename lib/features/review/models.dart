import 'dart:convert';

class EventReview {
  final int id;
  final String team1;
  final String team2;
  final String category;
  final String location;
  final String date;
  final String time;
  final String? imageUrl;
  final double avgRating;
  final int reviewCount;

  EventReview({
    required this.id,
    required this.team1,
    required this.team2,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    this.imageUrl,
    required this.avgRating,
    required this.reviewCount,
  });

  factory EventReview.fromJson(Map<String, dynamic> json) {
    return EventReview(
      id: json['id'],
      team1: json['team1'],
      team2: json['team2'],
      category: json['category'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      imageUrl: json['image_url'],
      avgRating: (json['avg_rating'] as num).toDouble(),
      reviewCount: json['review_count'],
    );
  }
}

class UserReview {
  final int id;
  final String reviewer;
  final int rating;
  final String comment;
  final String createdAt;
  final bool isOwner;
  final String? profilePicture;

  UserReview({
    required this.id,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.isOwner,
    this.profilePicture,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'],
      reviewer: json['reviewer'],
      rating: json['rating'],
      comment: json['comment'] ?? "",
      createdAt: json['created_at'],
      isOwner: json['is_owner'],
      profilePicture: json['profile_picture'],
    );
  }
}