import 'package:flutter/material.dart';
import 'package:oliminate_mobile/features/main-page/main_page.dart';
import 'package:oliminate_mobile/features/user-profile/edit_profile.dart';
import 'package:oliminate_mobile/features/user-profile/login.dart';
import 'package:oliminate_mobile/features/user-profile/main_profile.dart';
import 'package:oliminate_mobile/features/user-profile/register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
