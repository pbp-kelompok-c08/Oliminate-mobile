import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import '../../data/models/schedule.dart';

class ScheduleDetailPage extends StatelessWidget {
  const ScheduleDetailPage({
    super.key,
    required this.schedule,
    required this.isOwner,
    this.onEdit,
    this.onDelete,
  });

  final Schedule schedule;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${schedule.team1} vs ${schedule.team2}'),
        backgroundColor: AppColors.pacilBlueDarker2,
      ),
      backgroundColor: AppColors.neutral50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeroImage(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            if ((schedule.caption ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _buildCaptionCard(),
            ],
            if (isOwner && (onEdit != null || onDelete != null)) ...<Widget>[
              const SizedBox(height: 16),
              _buildOwnerActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final String? url = schedule.imageUrl;

    final Widget child = (url != null && url.isNotEmpty)
        ? Image.network(
            url,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : _placeholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: child,
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${schedule.team1} vs ${schedule.team2}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              schedule.category,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.calendar_today, '${schedule.date} • ${schedule.time}'),
            const SizedBox(height: 8),
            _infoRow(Icons.place, schedule.location),
            const SizedBox(height: 8),
            _infoRow(
              Icons.person,
              'Penyelenggara: ${schedule.organizer ?? '-'}',
            ),
            const SizedBox(height: 16),
            _statusChip(),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.neutral500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.neutral700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip() {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCaptionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Catatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              schedule.caption ?? '-',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerActions(BuildContext context) {
    return Row(
      children: <Widget>[
        if (onEdit != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.pacilBlueDarker2,
                side: const BorderSide(color: AppColors.pacilBlueDarker2),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Edit Jadwal'),
            ),
          ),
        if (onDelete != null) const SizedBox(width: 12),
        if (onDelete != null)
          Expanded(
            child: ElevatedButton(
              onPressed: onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pacilRedBase,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Hapus'),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      height: 220,
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

