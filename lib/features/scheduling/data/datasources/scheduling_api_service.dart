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
    final Uri uri = Uri.parse('$baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        ...query,
      },
    );
  }

  Future<List<Schedule>> fetchList({String filter = 'all'}) async {
    final http.Response res = await http.get(
      _uri('/scheduling/api/list/', <String, String>{'filter': filter}),
      headers: _headers(),
    );

    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || body['ok'] != true) {
      throw Exception('Gagal load list jadwal');
    }

    final List<dynamic> items = body['items'] as List<dynamic>? ?? <dynamic>[];
    return items
        .map(
          (dynamic e) => Schedule.fromJson(e as Map<String, dynamic>),
        )
        .toList();
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


