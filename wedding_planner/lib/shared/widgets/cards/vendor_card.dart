import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_typography.dart';

/// Vendor Card Widget
/// Displays vendor info in list/grid views
class VendorCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String? location;
  final String? priceRange;
  final bool isFeatured;
  final bool isFavorite;
  final String? availabilityText;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const VendorCard({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.location,
    this.priceRange,
    this.isFeatured = false,
    this.isFavorite = false,
    this.availabilityText,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMedium,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Badge
            if (isFeatured)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                  vertical: AppSpacing.micro,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.champagne,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: AppColors.deepCharcoal,
                    ),
                    const SizedBox(width: AppSpacing.micro),
                    Text(
                      'Featured',
                      style: AppTypography.tiny.copyWith(
                        color: AppColors.deepCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Image
                  ClipRRect(
                    borderRadius: AppSpacing.borderRadiusSmall,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.blushRose,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.blushRose,
                                child: const Icon(
                                  Icons.image,
                                  color: AppColors.warmGray,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.blushRose,
                              child: const Icon(
                                Icons.store,
                                color: AppColors.warmGray,
                                size: 32,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.base),

                  // Vendor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Favorite
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: AppTypography.h3.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: onFavoriteTap,
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? AppColors.roseGold
                                    : AppColors.warmGray,
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.micro),

                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' ($reviewCount reviews)',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.micro),

                        // Location and Price
                        Row(
                          children: [
                            if (location != null) ...[
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.warmGray,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  location!,
                                  style: AppTypography.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (location != null && priceRange != null)
                              const SizedBox(width: AppSpacing.small),
                            if (priceRange != null) ...[
                              const Icon(
                                Icons.attach_money,
                                size: 14,
                                color: AppColors.warmGray,
                              ),
                              Text(
                                priceRange!,
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Availability
                        if (availabilityText != null) ...[
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            availabilityText!,
                            style: AppTypography.tiny.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
