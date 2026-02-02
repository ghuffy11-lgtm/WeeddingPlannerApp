import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/category.dart';

/// Card widget for displaying a vendor category
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.blushRose.withAlpha(128),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  _getIconData(category.displayIcon),
                  size: 28,
                  color: AppColors.roseGold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
              child: Text(
                category.name,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Vendor count
            if (category.vendorCount != null) ...[
              const SizedBox(height: AppSpacing.micro),
              Text(
                '${category.vendorCount} vendors',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warmGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'camera_alt':
        return Icons.camera_alt;
      case 'videocam':
        return Icons.videocam;
      case 'restaurant':
        return Icons.restaurant;
      case 'cake':
        return Icons.cake;
      case 'music_note':
        return Icons.music_note;
      case 'local_florist':
        return Icons.local_florist;
      case 'celebration':
        return Icons.celebration;
      case 'location_on':
        return Icons.location_on;
      case 'face':
        return Icons.face;
      case 'checkroom':
        return Icons.checkroom;
      case 'mail':
        return Icons.mail;
      case 'directions_car':
        return Icons.directions_car;
      case 'store':
      default:
        return Icons.store;
    }
  }
}
