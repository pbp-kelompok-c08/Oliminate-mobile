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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: Colors.white,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildImage(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${schedule.team1} vs ${schedule.team2}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${schedule.date} • ${schedule.time}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pacilBlueDarker2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  schedule.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral500,
                  ),
                ),
                if ((schedule.caption ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    schedule.caption!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildStatusPill(),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: AppColors.neutral700,
                    ),
                    onSelected: (String value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                        case 'completed':
                          if (canComplete) onCompleted();
                          break;
                        case 'reviewable':
                          if (canReviewable) onReviewable();
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem<String>(
                        value: 'completed',
                        enabled: canComplete,
                        child: const Text('Tandai Completed'),
                      ),
                      PopupMenuItem<String>(
                        value: 'reviewable',
                        enabled: canReviewable,
                        child: const Text('Tandai Reviewable'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: onDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pacilBlueDarker2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Detail'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final String? url = schedule.imageUrl;
    final Widget imageChild;

    if (url != null && url.isNotEmpty) {
      imageChild = Image.network(
        url,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      imageChild = _placeholder();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(18),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: imageChild,
      ),
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


