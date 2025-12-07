import 'package:flutter/material.dart';
import 'package:oliminate_mobile/features/user-profile/login.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22629E)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}