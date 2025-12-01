// lib/features/review/presentation/widgets/review_card.dart
import 'package:flutter/material.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import '../../data/models/review.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
  });

  final Review review;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Generate star icons based on rating
    final List<Widget> stars = List<Widget>.generate(5, (int index) {
      final bool isFilled = index < review.rating;
      return Icon(
        isFilled ? Icons.star : Icons.star_border,
        color: isFilled ? Colors.amber : AppColors.neutral300,
        size: 18,
      );
    });

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Placeholder Avatar
              const CircleAvatar(
                backgroundColor: AppColors.neutral500,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      review.reviewerUsername,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        ...stars,
                        const SizedBox(width: 8),
                        Text(
                          review.createdAt.substring(0, 10),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.neutral100),
          Text(
            review.comment ?? 'Tidak ada komentar.',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.neutral700,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: onEdit,
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: AppColors.pacilBlueBase, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onDelete,
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: AppColors.pacilRedBase, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}