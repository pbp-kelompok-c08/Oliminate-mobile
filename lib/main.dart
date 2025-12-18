import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // [WAJIB ADA]
import 'package:provider/provider.dart'; // [WAJIB ADA]
import 'package:oliminate_mobile/features/user-profile/login.dart'; // Sesuaikan path login
import 'package:oliminate_mobile/core/django_client.dart'; 
import 'package:oliminate_mobile/core/app_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider ini adalah "gudang" data untuk seluruh halaman
    return MultiProvider(
      providers: [
        // INI YANG DICARI REVIEW PAGE TADI:
        Provider<CookieRequest>(
          create: (_) => CookieRequest(),
        ),
        // Tambahan DjangoClient buat jaga-jaga
        Provider<DjangoClient>(
          create: (_) => DjangoClient(baseUrl: AppConfig.backendBaseUrl),
        ),
      ],
      child: MaterialApp(
        title: 'Oliminate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22629E)),
          useMaterial3: true,
        ),
        // Tetap arahkan ke Login dulu
        home: const LoginPage(), 
      ),
    );
  }
}