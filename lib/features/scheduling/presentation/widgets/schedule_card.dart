import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import '../../data/models/schedule.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
    required this.onCompleted,
    required this.onReviewable,
    required this.onDetail,
  });

  final Schedule schedule;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCompleted;
  final VoidCallback onReviewable;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final bool canComplete = isOwner && schedule.status == 'upcoming';
    final bool canReviewable = isOwner && schedule.status == 'completed';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${schedule.team1} vs ${schedule.team2}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${schedule.category} — ${schedule.location}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${schedule.date} | ${schedule.time}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pacilBlueBase,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Penyelenggara: ${schedule.organizer ?? '-'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      const Text(
                        'Status: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                        ),
                      ),
                      Text(
                        schedule.status,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    side: const BorderSide(
                      color: AppColors.pacilBlueBase,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Detail',
                    style: TextStyle(
                      color: AppColors.pacilBlueBase,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final String? url = schedule.imageUrl;
    final Widget imageChild;

    if (url != null && url.isNotEmpty) {
      imageChild = Image.network(
        url,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      imageChild = _placeholder();
    }

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: imageChild,
    );
  }

  Widget _buildStatusPill() {
    Color bg;
    Color textColor;
    String label = schedule.status.toUpperCase();

    switch (schedule.status) {
      case 'completed':
        bg = AppColors.pacilBlueLight2;
        textColor = AppColors.pacilBlueDarker2;
        break;
      case 'reviewable':
        bg = AppColors.pacilRedLight3;
        textColor = AppColors.pacilRedDarker1;
        break;
      default:
        bg = AppColors.neutral100;
        textColor = AppColors.neutral700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.neutral100,
      alignment: Alignment.center,
      child: const Text(
        'No Image',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.neutral500,
        ),
      ),
    );
  }
}


