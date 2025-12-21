import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/app_config.dart';
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

  // Color palette matching ticketing design
  static const Color _primaryDark = Color(0xFF113352);
  static const Color _primaryBlue = Color(0xFF3293EC);
  static const Color _primaryRed = Color(0xFFEA3C43);
  static const Color _neutralBg = Color(0xFFF5F5F5);
  static const Color _textDark = Color(0xFF113352);
  static const Color _textGrey = Color(0xFF3D3D3D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${schedule.team1} vs ${schedule.team2}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
      ),
      backgroundColor: _neutralBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeroImage(),
            const SizedBox(height: 16),
            _buildInfoCard(),
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
    final Widget child;

    if (url != null && url.isNotEmpty) {
      final String encoded = Uri.encodeComponent(url);
      final String proxyUrl = '${AppConfig.backendBaseUrl}/merchandise/proxy-image/?url=$encoded';

      child = Image.network(
        proxyUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: child,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${schedule.team1} vs ${schedule.team2}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF113352),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              schedule.category,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3D3D3D),
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.calendar_today, '${schedule.date} • ${schedule.time}'),
            const SizedBox(height: 8),
            if ((schedule.caption ?? '').isNotEmpty) ...<Widget>[
              const Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                schedule.caption ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
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
        Icon(icon, size: 16, color: const Color(0xFF3D3D3D)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3D3D3D),
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


