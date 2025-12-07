import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/review.dart';
import '../models/reviewable_schedule.dart'; 
// import 'package:oliminate_mobile/features/scheduling/data/models/schedule.dart'; 

class ReviewFormData {
  final int? reviewId; 
  final int scheduleId; 
  final int rating;
  final String comment;

  const ReviewFormData({
    this.reviewId,
    required this.scheduleId,
    required this.rating,
    required this.comment,
  });

  Map<String, String> toFormBody() {
    return <String, String>{
      'rating': rating.toString(),
      'comment': comment,
    };
  }
}

class ReviewApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ReviewApiService({required this.baseUrl, this.defaultHeaders = const <String, String>{}});

  Map<String, String> _headers({bool form = false}) {
    return <String, String>{
      ...defaultHeaders,
      if (form) 'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  Uri _uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  // >>>>>> PERBAIKAN: RETURN TYPE DIDEKLARASIKAN DAN DITERAPKAN DENGAN BENAR <<<<<<
  Future<List<ReviewableSchedule>> fetchReviewableEvents({String sort = '-review_count'}) async {
    final url = Uri.parse('$baseUrl/reviews/json/?sort=$sort'); 
    
    final response = await http.get(url, headers: defaultHeaders);

    final List<dynamic> body = jsonDecode(response.body) as List<dynamic>;

    if (response.statusCode != 200) {
      throw Exception('Gagal load daftar event reviewable');
    }

    return body
        .map((dynamic e) => ReviewableSchedule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 2. API: Mengambil SEMUA review + metadata untuk halaman Detail
  Future<Map<String, dynamic>> fetchReviewDetailData(int scheduleId) async {
    final http.Response res = await http.get(
      _uri('/review/api/list/$scheduleId/'), 
      headers: _headers(),
    );

    final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200) {
      throw Exception('Gagal load detail review event');
    }
    
    final List<dynamic> reviewsJson = body['reviews'] as List<dynamic>;
    
    return {
      'reviews': reviewsJson.map((r) => Review.fromJson(r as Map<String, dynamic>)).toList(),
      'can_review': body['can_review'] as bool,
      'avg_rating': (body['avg_rating'] ?? 0.0) as double, 
      'review_count': (body['review_count'] ?? 0) as int,   
    };
  }

  // 3. API: Create Review
  Future<Map<String, dynamic>> createReview(ReviewFormData formData) async {
    final String url = '/review/${formData.scheduleId}/add/';
    final http.Response res = await http.post(
      _uri(url),
      headers: _headers(form: true),
      body: formData.toFormBody(),
    );
    final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      final String errorMessage = (body['message'] ?? body['errors'] ?? 'Gagal membuat review').toString();
      throw Exception(errorMessage);
    }
    return body;
  }

  // 4. API: Update Review
  Future<Map<String, dynamic>> updateReview(ReviewFormData formData) async {
    final int id = formData.reviewId!;
    final String url = '/review/edit/$id/';
    final http.Response res = await http.post(
      _uri(url),
      headers: _headers(form: true),
      body: formData.toFormBody(),
    );
    final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      final String errorMessage = (body['message'] ?? body['errors'] ?? 'Gagal mengupdate review').toString();
      throw Exception(errorMessage);
    }
    return body;
  }

  // 5. API: Delete Review
  Future<void> deleteReview(int reviewId) async {
    final String url = '/review/delete/$reviewId/';
    final http.Response res = await http.post(
      _uri(url),
      headers: _headers(form: true),
    );
    final Map<String, dynamic> body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || body['success'] != true) {
      throw Exception('Gagal menghapus review');
    }
  }
}