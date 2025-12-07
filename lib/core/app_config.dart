import 'package:flutter/foundation.dart';

class AppConfig {
  // URL backend bisa dioverride lewat --dart-define saat build/run.
  static const String _envBackendUrl =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');

  /// Tentukan base URL default berdasarkan platform yang dipakai saat run.
  static String get backendBaseUrl {
    if (_envBackendUrl.isNotEmpty) {
      return _envBackendUrl;
    }

    // Default ke production URL
    return 'https://adjie-m-oliminate.pbp.cs.ui.ac.id';
  }
}
