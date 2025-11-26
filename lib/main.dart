import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/scheduling/scheduling_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oliminate',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: AppColors.pacilBlueDarker2),
        scaffoldBackgroundColor: AppColors.neutral50,
        useMaterial3: true,
      ),
      home: const _RootHome(),
    );
  }
}

class _RootHome extends StatelessWidget {
  const _RootHome();

  @override
  Widget build(BuildContext context) {
    return const SchedulingPage(
      baseUrl: 'https://adjie-m-oliminate.pbp.cs.ui.ac.id',
      // Sesuaikan jika kamu sudah punya informasi user login di sisi Flutter.
      currentUsername: null,
      isOrganizer: false,
      authHeaders: <String, String>{},
    );
  }
}


