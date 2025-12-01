import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oliminate_mobile/core/http_client_factory_stub.dart'
    if (dart.library.html) 'package:oliminate_mobile/core/http_client_factory_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple HTTP client to talk to Django using session + CSRF cookies.
class DjangoClient {
  DjangoClient({required this.baseUrl, http.Client? httpClient})
    : _client = httpClient ?? createHttpClient(),
      _manualCookieHandling = httpClient == null ? supportsManualCookies : true;

  final String baseUrl;
  final http.Client _client;
  final bool _manualCookieHandling;

  static const _prefsKey = 'django_cookies';
  static const Duration _defaultTimeout = Duration(seconds: 20);

  Map<String, String> _cookies = {};
  String? _csrfToken;

  Uri _uri(String path) => Uri.parse(baseUrl + path);

  String get _cookieHeader =>
      _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  /// Load cookies persisted from previous sessions.
  Future<void> restoreCookies() async {
    if (!_manualCookieHandling) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      _cookies = decoded.map((k, v) => MapEntry(k, v.toString()));
      _csrfToken = _cookies['csrftoken'];
    }
  }

  /// Persist current cookies so the session survives restart.
  Future<void> saveCookies() async {
    if (!_manualCookieHandling) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_cookies));
  }

  Future<void> clearCookies() async {
    _cookies.clear();
    _csrfToken = null;
    if (_manualCookieHandling) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    }
  }

  /// Ensure we have a CSRF token by hitting the given path (GET).
  /// Defaults to a lightweight CSRF endpoint instead of the login page.
  Future<void> ensureCsrfToken({String path = '/authentication/api/csrf/'}) async {
    if (_csrfToken != null) return;

    Future<bool> _tryFetch(String targetPath) async {
      final res = await get(targetPath, followRedirects: false);
      if (res.statusCode != 200 && res.statusCode != 302) {
        return false;
      }
      // _csrfToken will be filled by _extractCsrfFromHtml inside get().
      return _csrfToken != null;
    }

    final fetched = await _tryFetch(path);
    if (!fetched && path != '/users/login/') {
      await _tryFetch('/users/login/');
    }
  }

  Future<http.Response> get(String path, {bool followRedirects = true}) async {
    final req = http.Request('GET', _uri(path));
    _attachHeaders(req);
    req.followRedirects = followRedirects;
    req.maxRedirects = 0;

    final streamed = await _client.send(req).timeout(_defaultTimeout);
    final res = await http.Response.fromStream(streamed);
    _updateCookiesFrom(res);
    await saveCookies();
    _extractCsrfFromHtml(res.body);
    return res;
  }

  Future<http.Response> postForm(
    String path, {
    required Map<String, String> body,
    bool followRedirects = false,
  }) async {
    // Always fetch CSRF from the dedicated endpoint instead of the POST URL.
    await ensureCsrfToken();
    final req = http.Request('POST', _uri(path));
    req.followRedirects = followRedirects;
    req.maxRedirects = 0;
    _attachHeaders(req);
    req.headers['content-type'] = 'application/x-www-form-urlencoded';
    if (_csrfToken != null) {
      req.headers['X-CSRFToken'] = _csrfToken!;
      body['csrfmiddlewaretoken'] = _csrfToken!;
    }
    req.bodyFields = body;

    final streamed = await _client.send(req).timeout(_defaultTimeout);
    final res = await http.Response.fromStream(streamed);
    _updateCookiesFrom(res);
    await saveCookies();
    _extractCsrfFromHtml(res.body);
    return res;
  }

  Future<http.StreamedResponse> postMultipart(
    String path, {
    required Map<String, String> fields,
    List<http.MultipartFile> files = const [],
    bool followRedirects = false,
  }) async {
    // Always fetch CSRF from the dedicated endpoint instead of the POST URL.
    await ensureCsrfToken();
    final req = http.MultipartRequest('POST', _uri(path));
    req.followRedirects = followRedirects;
    req.maxRedirects = 0;
    _attachHeaders(req);
    if (_csrfToken != null) {
      req.headers['X-CSRFToken'] = _csrfToken!;
      fields['csrfmiddlewaretoken'] = _csrfToken!;
    }
    req.fields.addAll(fields);
    req.files.addAll(files);

    final streamed = await _client.send(req).timeout(_defaultTimeout);
    _updateCookiesFromHeaders(streamed.headers);
    await saveCookies();
    return streamed;
  }

  bool get isAuthenticated =>
      _manualCookieHandling ? _cookies.containsKey('sessionid') : true;
  bool get isManualCookieHandling => _manualCookieHandling;

  void _attachHeaders(http.BaseRequest req) {
    if (_cookies.isNotEmpty) {
      req.headers['cookie'] = _cookieHeader;
    }
    req.headers['accept'] = 'text/html,application/json';
  }

  void _updateCookiesFrom(http.BaseResponse res) {
    _updateCookiesFromHeaders(res.headers);
  }

  void _updateCookiesFromHeaders(Map<String, String> headers) {
    if (!_manualCookieHandling) return;
    final raw = headers['set-cookie'];
    if (raw == null) return;
    // Split on comma only when followed by a key= pattern (avoids breaking on expires=)
    final cookieStrings = raw.split(RegExp(',(?=[^ ;]+=)'));
    for (final cookie in cookieStrings) {
      final firstPart = cookie.split(';').first;
      final idx = firstPart.indexOf('=');
      if (idx == -1) continue;
      final name = firstPart.substring(0, idx).trim();
      final value = firstPart.substring(idx + 1).trim();
      _cookies[name] = value;
    }
    _csrfToken = _cookies['csrftoken'] ?? _csrfToken;
  }

  void _extractCsrfFromHtml(String html) {
    final regex = RegExp(
      r'''name=["']csrfmiddlewaretoken["']\s+value=["']([^"']+)''',
      caseSensitive: false,
    );
    final match = regex.firstMatch(html);
    if (match != null) {
      _csrfToken = match.group(1);
    }
  }
}
