import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oliminate_mobile/core/django_client.dart';

import '../models/schedule.dart';

class SchedulingApiService {
  SchedulingApiService({
    required this.baseUrl,
    required this.djangoClient,
  });

  final String baseUrl;
  final DjangoClient djangoClient;

  /// Helper untuk cek apakah response adalah HTML
  bool _isHtmlResponse(String body) {
    final trimmed = body.trim();
    return trimmed.startsWith('<!DOCTYPE') ||
        trimmed.startsWith('<!doctype') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<HTML') ||
        trimmed.toLowerCase().contains('<!doctype') ||
        trimmed.toLowerCase().contains('<html');
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    // Pastikan tidak ada double slash
    final String cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    final String cleanPath = path.startsWith('/') ? path : '/$path';
    final Uri uri = Uri.parse('$cleanBaseUrl$cleanPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        ...query,
      },
    );
  }

  Future<List<Schedule>> fetchList({String filter = 'all'}) async {
    try {
      // Pakai djangoClient.get() untuk handle cookies dan headers
      final res = await djangoClient.get(
        '/scheduling/api/list/?filter=$filter',
        followRedirects: false,
      );

      if (res.statusCode != 200) {
        throw Exception(
          'HTTP ${res.statusCode}: ${res.reasonPhrase}\nURL: ${_uri('/scheduling/api/list/')}\nBody: ${res.body}',
        );
      }

      // Cek apakah response adalah HTML
      if (_isHtmlResponse(res.body)) {
        throw Exception(
          'Server mengembalikan halaman HTML. Status: ${res.statusCode}\n'
          'URL: ${_uri('/scheduling/api/list/')}',
        );
      }

      final Map<String, dynamic> body =
          jsonDecode(res.body) as Map<String, dynamic>;

      if (body['ok'] != true) {
        throw Exception(
          'Response tidak OK: ${body['errors'] ?? body.toString()}',
        );
      }

      final List<dynamic> items = body['items'] as List<dynamic>? ?? <dynamic>[];
      return items
          .map(
            (dynamic e) => Schedule.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } on http.ClientException catch (e) {
      throw Exception(
        'Gagal terhubung ke server. Pastikan koneksi internet aktif dan server dapat diakses.\n'
        'URL: ${_uri('/scheduling/api/list/')}\n'
        'Error: ${e.message}',
      );
    } on FormatException catch (e) {
      throw Exception('Format response tidak valid: $e');
    } catch (e) {
      throw Exception('Error tidak diketahui: $e');
    }
  }

  Future<Schedule> createSchedule(Map<String, String> formData) async {
    try {
      final res = await djangoClient.postForm(
        '/scheduling/api/create/',
        body: formData,
        followRedirects: false,
      );

      // Cek apakah response adalah HTML (error page) - cek dulu sebelum decode
      final bodyText = res.body;
      
      if (_isHtmlResponse(bodyText)) {
        throw Exception(
          'Server mengembalikan halaman HTML (${res.statusCode}).\n'
          'Kemungkinan:\n'
          '- Endpoint tidak ditemukan (404)\n'
          '- Tidak ter-authenticate (302/403)\n'
          '- CSRF token tidak valid\n'
          'URL: ${_uri('/scheduling/api/create/')}\n'
          'Response preview: ${bodyText.substring(0, bodyText.length > 200 ? 200 : bodyText.length)}',
        );
      }

      // Cek status code
      if (res.statusCode != 200) {
        throw Exception(
          'HTTP ${res.statusCode}: ${res.reasonPhrase}\n'
          'URL: ${_uri('/scheduling/api/create/')}\n'
          'Body: ${bodyText.substring(0, bodyText.length > 200 ? 200 : bodyText.length)}',
        );
      }

      // Validasi response tidak kosong
      if (bodyText.trim().isEmpty) {
        throw Exception('Response kosong dari server');
      }

      // Decode JSON dengan error handling
      Map<String, dynamic> body;
      try {
        body = jsonDecode(bodyText) as Map<String, dynamic>;
      } on FormatException catch (e) {
        throw Exception(
          'Format response tidak valid (bukan JSON):\n$e\n'
          'Response mungkin adalah HTML error page.\n'
          'Response preview: ${bodyText.substring(0, bodyText.length > 200 ? 200 : bodyText.length)}',
        );
      }

      if (body['ok'] != true) {
        throw Exception(body['errors'] ?? 'Gagal membuat jadwal');
      }

      return Schedule.fromJson(body['item'] as Map<String, dynamic>);
    } on FormatException catch (e) {
      throw Exception(
        'Format response tidak valid (bukan JSON):\n$e\n'
        'Response mungkin adalah HTML error page.',
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Schedule> updateSchedule(int id, Map<String, String> formData) async {
    try {
      final res = await djangoClient.postForm(
        '/scheduling/api/$id/update/',
        body: formData,
        followRedirects: false,
      );

      if (res.statusCode != 200) {
        if (res.body.trim().startsWith('<!DOCTYPE') ||
            res.body.trim().startsWith('<html')) {
          throw Exception(
            'Server mengembalikan halaman HTML. Status: ${res.statusCode}',
          );
        }
        throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
      }

      if (res.body.trim().startsWith('<!DOCTYPE') ||
          res.body.trim().startsWith('<html')) {
        throw Exception('Server mengembalikan HTML padahal diharapkan JSON');
      }

      final Map<String, dynamic> body =
          jsonDecode(res.body) as Map<String, dynamic>;

      if (body['ok'] != true) {
        throw Exception(body['errors'] ?? 'Gagal mengupdate jadwal');
      }

      return Schedule.fromJson(body['item'] as Map<String, dynamic>);
    } on FormatException catch (e) {
      throw Exception('Format response tidak valid: $e');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      final res = await djangoClient.postForm(
        '/scheduling/api/$id/delete/',
        body: <String, String>{},
        followRedirects: false,
      );

      if (res.statusCode != 200) {
        if (res.body.trim().startsWith('<!DOCTYPE') ||
            res.body.trim().startsWith('<html')) {
          throw Exception(
            'Server mengembalikan halaman HTML. Status: ${res.statusCode}',
          );
        }
        throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
      }

      if (res.body.trim().startsWith('<!DOCTYPE') ||
          res.body.trim().startsWith('<html')) {
        throw Exception('Server mengembalikan HTML padahal diharapkan JSON');
      }

      final Map<String, dynamic> body =
          jsonDecode(res.body) as Map<String, dynamic>;

      if (body['ok'] != true) {
        throw Exception('Gagal menghapus jadwal');
      }
    } on FormatException catch (e) {
      throw Exception('Format response tidak valid: $e');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> makeCompleted(int id) async {
    try {
      final res = await djangoClient.postForm(
        '/scheduling/api/$id/complete/',
        body: <String, String>{},
        followRedirects: false,
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
      }

      if (res.body.trim().startsWith('<!DOCTYPE') ||
          res.body.trim().startsWith('<html')) {
        throw Exception('Server mengembalikan HTML padahal diharapkan JSON');
      }

      final Map<String, dynamic> body =
          jsonDecode(res.body) as Map<String, dynamic>;
      return body;
    } on FormatException catch (e) {
      throw Exception('Format response tidak valid: $e');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> makeReviewable(int id) async {
    try {
      final res = await djangoClient.postForm(
        '/scheduling/api/$id/make-reviewable/',
        body: <String, String>{},
        followRedirects: false,
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase}');
      }

      if (res.body.trim().startsWith('<!DOCTYPE') ||
          res.body.trim().startsWith('<html')) {
        throw Exception('Server mengembalikan HTML padahal diharapkan JSON');
      }

      final Map<String, dynamic> body =
          jsonDecode(res.body) as Map<String, dynamic>;
      return body;
    } on FormatException catch (e) {
      throw Exception('Format response tidak valid: $e');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

