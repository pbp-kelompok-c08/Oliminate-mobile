import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/review/presentation/pages/review_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi otentikasi (gunakan mock data jika belum ada sistem login)
    const String baseUrl = 'https://adjie-m-oliminate.pbp.cs.ui.ac.id';
    const String? currentUsername = 'contoh_user'; // Ganti dengan null atau username user yang login
    const Map<String, String> authHeaders = <String, String>{
      // Tambahkan headers otentikasi di sini jika diperlukan, misal Cookie/CSRF
      // 'Cookie': 'sessionid=...',
    };
    
    return MaterialApp(
      title: 'Oliminate',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: AppColors.pacilBlueDarker2),
        scaffoldBackgroundColor: AppColors.neutral50,
        useMaterial3: true,
      ),
      // Set halaman ReviewListPage sebagai halaman utama (home)
      home: ReviewListPage(
        baseUrl: baseUrl,
        currentUsername: currentUsername, 
        authHeaders: authHeaders,
      ),
    );
  }
}