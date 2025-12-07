import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/schedule.dart';

class SchedulingApiService {
  SchedulingApiService({
    required this.baseUrl,
    this.defaultHeaders = const <String, String>{},
  });

  final String baseUrl;
  final Map<String, String> defaultHeaders;

  Map<String, String> _headers({bool form = false}) {
    return <String, String>{
      ...defaultHeaders,
      if (form) 'Content-Type': 'application/x-www-form-urlencoded',
    };
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
      final Uri requestUri = _uri('/scheduling/api/list/', <String, String>{'filter': filter});
      
      final http.Response res = await http.get(
        requestUri,
        headers: _headers(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout: Tidak dapat terhubung ke server');
        },
      );

      if (res.statusCode != 200) {
        throw Exception(
          'HTTP ${res.statusCode}: ${res.reasonPhrase}\nURL: $requestUri\nBody: ${res.body}',
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
    final http.Response res = await http.post(
      _uri('/scheduling/api/create/'),
      headers: _headers(form: true),
      body: formData,
    );

    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || body['ok'] != true) {
      throw Exception(body['errors'] ?? 'Gagal membuat jadwal');
    }

    return Schedule.fromJson(body['item'] as Map<String, dynamic>);
  }

  Future<Schedule> updateSchedule(int id, Map<String, String> formData) async {
    final http.Response res = await http.post(
      _uri('/scheduling/api/$id/update/'),
      headers: _headers(form: true),
      body: formData,
    );

    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || body['ok'] != true) {
      throw Exception(body['errors'] ?? 'Gagal mengupdate jadwal');
    }

    return Schedule.fromJson(body['item'] as Map<String, dynamic>);
  }

  Future<void> deleteSchedule(int id) async {
    final http.Response res = await http.post(
      _uri('/scheduling/api/$id/delete/'),
      headers: _headers(form: true),
    );

    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || body['ok'] != true) {
      throw Exception('Gagal menghapus jadwal');
    }
  }

  Future<Map<String, dynamic>> makeCompleted(int id) async {
    final http.Response res = await http.post(
      _uri('/scheduling/api/$id/complete/'),
      headers: _headers(form: true),
    );

    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;
    return body;
  }

  Future<Map<String, dynamic>> makeReviewable(int id) async {
    final http.Response res = await http.post(
      _uri('/scheduling/api/$id/make-reviewable/'),
      headers: _headers(form: true),
    );

    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;
    return body;
  }
}


