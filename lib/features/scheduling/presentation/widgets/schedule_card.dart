import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import '../../data/models/schedule.dart';

/// Mapping kategori ke path asset lokal
const Map<String, String> _assetByCategory = {
  'FUTSAL': 'assets/images/futsal.png',
  'BASKET': 'assets/images/basket.png',
  'BASKETBALL': 'assets/images/basket.png',
  'SEPAK BOLA': 'assets/images/sepak_bola.png',
  'VALORANT': 'assets/images/valorant.png',
  'TENIS LAPANGAN': 'assets/images/tenis_lapangan.png',
  'VOLI': 'assets/images/voli.png',
  'VOLLY': 'assets/images/voli.png',
  'HOCKEY': 'assets/images/hockey.png',
  'TENIS MEJA': 'assets/images/tenis_meja.png',
  'BADMINTON': 'assets/images/badminton.png',
  'MLBB': 'assets/images/mlbb.jpg',
  'DEFAULT': 'assets/images/default.png',
};

/// Normalize category string to uppercase for lookup
String _normCat(String s) => s.trim().toUpperCase();

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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onDetail,
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildHeroImage(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '${schedule.team1} vs ${schedule.team2}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutral900,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              _buildStatusBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 14,
                                color: AppColors.neutral500,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  schedule.category,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.neutral700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.neutral500,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  schedule.location,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.neutral700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (schedule.organizer != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 14,
                                  color: AppColors.neutral500,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    schedule.organizer!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.neutral700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.pacilBlueDarker1,
                                  AppColors.pacilBlueBase,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${schedule.date} | ${schedule.time}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          if (isOwner) ...[
                            _ActionButton(
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                              onPressed: onEdit,
                              isPrimary: false,
                              isDelete: false,
                            ),
                            const SizedBox(width: 8),
                            _ActionButton(
                              icon: Icons.delete_outline_rounded,
                              label: 'Delete',
                              onPressed: onDelete,
                              isPrimary: false,
                              isDelete: true,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _ActionButton(
                            icon: Icons.arrow_forward_rounded,
                            label: 'Detail',
                            onPressed: onDetail,
                            isPrimary: true,
                            isDelete: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Edit icon button di pojok kanan atas
                if (isOwner)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        onTap: onEdit,
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.pacilBlueDarker1,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final String key = _normCat(schedule.category);
    final bool hasAsset = _assetByCategory.containsKey(key) && key != 'DEFAULT';

    final Widget imageChild;
    if (hasAsset) {
      imageChild = Image.asset(
        _assetByCategory[key]!,
        width: double.infinity,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          _assetByCategory['DEFAULT']!,
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
        ),
      );
    } else {
      final String? url = schedule.imageUrl;
      if (url != null && url.isNotEmpty) {
        final String encoded = Uri.encodeComponent(url);
        final String proxyUrl =
            '${AppConfig.backendBaseUrl}/merchandise/proxy-image/?url=$encoded';

        imageChild = Image.network(
          proxyUrl,
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            _assetByCategory['DEFAULT']!,
            width: double.infinity,
            height: 140,
            fit: BoxFit.cover,
          ),
        );
      } else {
        imageChild = Image.asset(
          _assetByCategory['DEFAULT']!,
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
        );
      }
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 140,
          child: imageChild,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }


  Widget _placeholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pacilBlueDarker1.withOpacity(0.1),
            AppColors.pacilRedBase.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.neutral500,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
    this.isDelete = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDelete;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.pacilBlueDarker1,
              AppColors.pacilBlueBase,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.pacilBlueDarker1.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (isDelete) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(
            color: AppColors.pacilRedBase,
            width: 2,
          ),
          foregroundColor: AppColors.pacilRedBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(
            color: AppColors.pacilBlueDarker1,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }
}


