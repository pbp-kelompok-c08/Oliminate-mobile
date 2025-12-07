import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/core/django_client.dart';

class AuthResult {
  AuthResult.success([this.message]) : success = true;
  AuthResult.failure([this.message]) : success = false;

  final bool success;
  final String? message;
}

class ProfileData {
  ProfileData({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fakultas,
    required this.role,
    required this.profilePictureUrl,
  });

  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String fakultas;
  final String role;
  final String profilePictureUrl;
}

class ProfileUpdate {
  ProfileUpdate({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fakultas,
    required this.password,
    this.profilePicturePath,
    this.profilePictureBytes,
    this.profilePictureName,
  });

  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String fakultas;
  final String password;
  final String? profilePicturePath;
  final Uint8List? profilePictureBytes;
  final String? profilePictureName;
}

class AuthRepository {
  AuthRepository._internal()
    : _client = DjangoClient(baseUrl: AppConfig.backendBaseUrl);

  static final AuthRepository instance = AuthRepository._internal();

  final DjangoClient _client;

  ProfileData? _cachedProfile;

  Future<void> init() async {
    await _client.restoreCookies();
  }

  bool get isAuthenticated => _client.isAuthenticated;
  ProfileData? get cachedProfile => _cachedProfile;

  Future<bool> validateSession() async {
    try {
      final res = await _client.get('/users/profile/', followRedirects: false);
      final authed = res.statusCode == 200;
      if (!authed) {
        await _client.clearCookies();
        _cachedProfile = null;
      } else {
        _cachedProfile = _parseProfile(res.body);
      }
      return authed;
    } catch (_) {
      _cachedProfile = null;
      await _client.clearCookies();
      return false;
    }
  }

  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _client.postForm(
        '/authentication/api/login/',
        body: {'username': username, 'password': password},
        followRedirects: !_client.isManualCookieHandling,
      );

      if (res.statusCode == 302 || res.statusCode == 200) {
        await _client.saveCookies();
        await fetchProfile();
        return AuthResult.success();
      }

      final message =
          _extractErrorMessage(res.body) ??
          'Login gagal, cek username/password.';
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure(_friendlyError(e));
    }
  }

  Future<AuthResult> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String phoneNumber = '',
  }) async {
    try {
      final res = await _client.postForm(
        '/authentication/api/register/',
        body: {
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'role': role,
        },
        followRedirects: !_client.isManualCookieHandling,
      );

      if (res.statusCode == 302 || res.statusCode == 200) {
        await _client.saveCookies();
        String? successMessage;
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map && decoded['message'] is String) {
            successMessage = decoded['message'] as String;
          }
        } catch (_) {
          // ignore non-json response
        }
        return AuthResult.success(
          successMessage ?? 'Registrasi berhasil. Silakan login.',
        );
      }

      final message =
          _extractErrorMessage(res.body) ?? 'Registrasi gagal, periksa data.';
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure(_friendlyError(e));
    }
  }

  Future<ProfileData?> fetchProfile() async {
    try {
      final res = await _client.get('/users/profile/', followRedirects: false);
      if (res.statusCode == 302) {
        await _client.clearCookies();
        _cachedProfile = null;
        return null;
      }
      if (res.statusCode != 200) {
        _cachedProfile = null;
        return null;
      }
      final parsed = _parseProfile(res.body);
      _cachedProfile = parsed;
      return parsed;
    } catch (_) {
      _cachedProfile = null;
      return null;
    }
  }

  Future<ProfileData?> fetchProfileFromEdit() async {
    try {
      final res = await _client.get('/users/edit/', followRedirects: false);
      if (res.statusCode == 302) {
        await _client.clearCookies();
        _cachedProfile = null;
        return null;
      }
      if (res.statusCode != 200) {
        return null;
      }

      final doc = html_parser.parse(res.body);
      String _value(String name) =>
          doc.querySelector('input[name="$name"]')?.attributes['value'] ?? '';
      String _selectedFaculty() {
        final opt =
            doc.querySelector('select[name="fakultas"] option[selected]') ??
            doc.querySelector('select[name="fakultas"] option:checked');
        return opt?.attributes['value'] ?? '';
      }

      final data = ProfileData(
        username: _value('username'),
        firstName: _value('first_name'),
        lastName: _value('last_name'),
        email: _value('email'),
        fakultas: _selectedFaculty(),
        role: '', // not present on edit form
        profilePictureUrl: '',
      );
      _cachedProfile = data;
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<AuthResult> updateProfile(ProfileUpdate payload) async {
    try {
      final fields = {
        'username': payload.username,
        'first_name': payload.firstName,
        'last_name': payload.lastName,
        'email': payload.email,
        'fakultas': payload.fakultas,
        'password': payload.password,
      };

      final files = <http.MultipartFile>[];
      if (payload.profilePictureBytes != null &&
          payload.profilePictureBytes!.isNotEmpty) {
        final fileName =
            (payload.profilePictureName?.isNotEmpty ?? false) ? payload.profilePictureName! : 'profile.jpg';
        files.add(
          http.MultipartFile.fromBytes(
            'profile_picture',
            payload.profilePictureBytes!,
            filename: fileName,
          ),
        );
      } else if (payload.profilePicturePath != null &&
          payload.profilePicturePath!.isNotEmpty) {
        files.add(
          await http.MultipartFile.fromPath(
            'profile_picture',
            payload.profilePicturePath!,
          ),
        );
      }

      final streamed = await _client.postMultipart(
        '/authentication/api/profile/update/',
        fields: fields,
        files: files,
        followRedirects: false,
      );
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200 || res.statusCode == 302) {
        await fetchProfile();
        return AuthResult.success();
      }

      final message =
          _extractErrorMessage(res.body) ?? 'Update profil gagal, coba lagi.';
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure(_friendlyError(e));
    }
  }

  Future<void> logout() async {
    try {
      await _client.postForm(
        '/authentication/api/logout/',
        body: <String, String>{},
        followRedirects: false,
      );
    } finally {
      await _client.clearCookies();
      _cachedProfile = null;
    }
  }

  String _friendlyError(Object error) {
    if (error is TimeoutException) {
      return 'Permintaan ke server melebihi batas waktu, coba lagi.';
    }
    if (error is SocketException) {
      return 'Tidak bisa terhubung ke server. Periksa koneksi atau URL backend.';
    }
    if (error is http.ClientException) {
      return 'Gagal terhubung ke server. Pastikan koneksi internet aktif dan server dapat diakses.\n'
          'URL: ${AppConfig.backendBaseUrl}\n'
          'Error: ${error.message}';
    }
    return 'Terjadi kesalahan tak terduga: $error';
  }

  ProfileData _parseProfile(String html) {
    final doc = html_parser.parse(html);
    String _fromRows(String label) {
      for (final row in doc.querySelectorAll('.data-row')) {
        final lbl = row.querySelector('label')?.text.trim();
        if (lbl == label) {
          return row.querySelector('.data-display')?.text.trim() ?? '';
        }
      }
      return '';
    }

    final nameText =
        doc.querySelector('.profile-sidebar h2')?.text.trim() ?? '';
    final role = doc.querySelector('.profile-sidebar p')?.text.trim() ?? '';
    final parts = nameText.split(' ');

    return ProfileData(
      username: _fromRows('Username'),
      firstName: parts.isNotEmpty ? parts.first : '',
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      email: _fromRows('Email'),
      fakultas: _fromRows('Faculty'),
      role: role,
      profilePictureUrl:
          doc.querySelector('.profile-sidebar img')?.attributes['src'] ?? '',
    );
  }

  String? _extractErrorMessage(String html) {
    try {
      final decoded = jsonDecode(html);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
      if (decoded is Map && decoded['errors'] is Map) {
        final errors = decoded['errors'] as Map;
        return errors.values
            .expand((value) => value is Iterable ? value : [value])
            .join('\n');
      }
    } catch (_) {
      // not json
    }
    final doc = html_parser.parse(html);
    final errors = doc.querySelectorAll('.errorlist li');
    if (errors.isNotEmpty) {
      return errors.map((e) => e.text.trim()).join('\n');
    }
    return null;
  }
}
