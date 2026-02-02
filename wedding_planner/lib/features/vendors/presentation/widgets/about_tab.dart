import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/vendor.dart';

/// About tab showing vendor's business information
class AboutTab extends StatelessWidget {
  final Vendor vendor;

  const AboutTab({
    super.key,
    required this.vendor,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (vendor.description != null) ...[
            Text(
              'About',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              vendor.description!,
              style: AppTypography.bodyMedium.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
          ],

          // Contact Information
          if (vendor.hasContactInfo) ...[
            Text(
              'Contact Information',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.medium),
            Container(
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
                children: [
                  // Phone
                  if (vendor.phone != null)
                    _ContactTile(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: vendor.phone!,
                      onTap: () => _launchPhone(vendor.phone!),
                    ),

                  if (vendor.phone != null && vendor.email != null)
                    const Divider(height: 1),

                  // Email
                  if (vendor.email != null)
                    _ContactTile(
                      icon: Icons.email,
                      title: 'Email',
                      value: vendor.email!,
                      onTap: () => _launchEmail(vendor.email!),
                    ),

                  if ((vendor.phone != null || vendor.email != null) &&
                      vendor.website != null)
                    const Divider(height: 1),

                  // Website
                  if (vendor.website != null)
                    _ContactTile(
                      icon: Icons.language,
                      title: 'Website',
                      value: vendor.website!,
                      onTap: () => _launchUrl(vendor.website!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.large),
          ],

          // Location
          if (vendor.locationDisplay.isNotEmpty) ...[
            Text(
              'Location',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.medium),
            Container(
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
                children: [
                  _ContactTile(
                    icon: Icons.location_on,
                    title: 'Address',
                    value: vendor.locationDisplay,
                    onTap: vendor.hasCoordinates
                        ? () {
                            // TODO: Open maps
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.large),
          ],

          // Business Details
          Text(
            'Business Details',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.medium),
          Container(
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
              children: [
                // Category
                if (vendor.category != null)
                  _InfoTile(
                    icon: Icons.category,
                    title: 'Category',
                    value: vendor.category!.name,
                  ),

                if (vendor.category != null) const Divider(height: 1),

                // Price Range
                if (vendor.priceDisplay.isNotEmpty)
                  _InfoTile(
                    icon: Icons.attach_money,
                    title: 'Price Range',
                    value: vendor.priceDisplay,
                  ),

                if (vendor.priceDisplay.isNotEmpty) const Divider(height: 1),

                // Rating
                _InfoTile(
                  icon: Icons.star,
                  title: 'Rating',
                  value: '${vendor.ratingAvg.toStringAsFixed(1)} (${vendor.reviewCount} reviews)',
                ),

                const Divider(height: 1),

                // Response Time
                if (vendor.responseTimeHours != null)
                  _InfoTile(
                    icon: Icons.schedule,
                    title: 'Response Time',
                    value: 'Usually within ${vendor.responseTimeHours} hours',
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.small),
        decoration: BoxDecoration(
          color: AppColors.blushRose.withAlpha(128),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        child: Icon(
          icon,
          color: AppColors.roseGold,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.warmGray,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.deepCharcoal,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.warmGray,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.warmGray,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.small),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.warmGray,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
