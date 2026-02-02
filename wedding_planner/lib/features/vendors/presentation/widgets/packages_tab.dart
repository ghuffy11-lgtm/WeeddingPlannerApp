import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/vendor_package.dart';

/// Packages tab showing vendor's service packages
class PackagesTab extends StatelessWidget {
  final List<VendorPackage> packages;

  const PackagesTab({
    super.key,
    required this.packages,
  });

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.warmGray,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'No packages available',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'This vendor hasn\'t set up any packages yet',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.warmGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return _PackageCard(package: package);
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  final VendorPackage package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
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
        border: package.isPopular
            ? Border.all(color: AppColors.roseGold, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular badge
          if (package.isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: AppSpacing.small,
              ),
              decoration: const BoxDecoration(
                color: AppColors.roseGold,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMedium - 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Most Popular',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        package.name,
                        style: AppTypography.h3,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Text(
                      package.formatPrice(),
                      style: AppTypography.h2.copyWith(
                        color: AppColors.roseGold,
                      ),
                    ),
                  ],
                ),

                // Duration
                if (package.durationDisplay != null) ...[
                  const SizedBox(height: AppSpacing.small),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.warmGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        package.durationDisplay!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warmGray,
                        ),
                      ),
                    ],
                  ),
                ],

                // Description
                if (package.description != null) ...[
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    package.description!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.warmGray,
                    ),
                  ),
                ],

                // Features
                if (package.features.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.medium),
                  const Divider(),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'What\'s included',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  ...package.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.micro),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                // Select Button
                const SizedBox(height: AppSpacing.medium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Select package for booking
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: package.isPopular
                          ? AppColors.roseGold
                          : AppColors.white,
                      foregroundColor: package.isPopular
                          ? AppColors.white
                          : AppColors.roseGold,
                      side: package.isPopular
                          ? null
                          : const BorderSide(color: AppColors.roseGold),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.base,
                      ),
                    ),
                    child: const Text('Select Package'),
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
