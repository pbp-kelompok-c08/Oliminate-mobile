import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
        backgroundColor: AppColors.pacilBlueDarker1,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline_rounded,
              size: 80,
              color: AppColors.pacilBlueDarker1,
            ),
            SizedBox(height: 16),
            Text(
              'Review',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.pacilBlueDarker1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

