import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/booking.dart';

/// Booking card widget with glass effect
class BookingCard extends StatelessWidget {
  final BookingSummary booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Vendor icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.accentPurple.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(booking.vendor?.categoryIcon),
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.base),
                    // Vendor info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.vendor?.businessName ?? 'Unknown Vendor',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (booking.vendor?.categoryName != null)
                            Text(
                              booking.vendor!.categoryName!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Status badge
                    _buildStatusBadge(booking.status),
                  ],
                ),

                const SizedBox(height: AppSpacing.base),
                const Divider(color: AppColors.glassBorder),
                const SizedBox(height: AppSpacing.base),

                // Details row
                Row(
                  children: [
                    // Date
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: booking.bookingDateFormatted,
                      ),
                    ),
                    // Package/Amount
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.attach_money,
                        label: 'Amount',
                        value: booking.totalAmountFormatted,
                      ),
                    ),
                  ],
                ),

                if (booking.package != null) ...[
                  const SizedBox(height: AppSpacing.small),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.package!.name,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case BookingStatus.pending:
        bgColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      case BookingStatus.accepted:
      case BookingStatus.confirmed:
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        break;
      case BookingStatus.completed:
        bgColor = AppColors.accent.withOpacity(0.2);
        textColor = AppColors.accent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: AppTypography.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'camera':
        return Icons.camera_alt;
      case 'restaurant':
        return Icons.restaurant;
      case 'music_note':
        return Icons.music_note;
      case 'local_florist':
        return Icons.local_florist;
      case 'cake':
        return Icons.cake;
      case 'videocam':
        return Icons.videocam;
      case 'brush':
        return Icons.brush;
      case 'checkroom':
        return Icons.checkroom;
      case 'location_on':
        return Icons.location_on;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.storefront;
    }
  }
}
