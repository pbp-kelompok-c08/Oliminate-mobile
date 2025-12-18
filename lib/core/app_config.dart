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

    if (kIsWeb) {
      // Gunakan localhost supaya dianggap satu "site" dengan
      // dev server Flutter web (mis. http://localhost:5173),
      // sehingga cookie CSRF dari Django terkirim dengan benar.
      return 'https://adjie-m-oliminate.pbp.cs.ui.ac.id';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'http://localhost:8000';
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return 'http://127.0.0.1:8000';
      case TargetPlatform.fuchsia:
        return 'http://10.0.2.2:8000';
    }
  }
}
