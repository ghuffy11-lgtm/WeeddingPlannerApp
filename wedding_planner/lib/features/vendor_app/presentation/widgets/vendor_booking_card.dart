import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/vendor_booking.dart';

/// Card for displaying a vendor booking
class VendorBookingCard extends StatelessWidget {
  final VendorBookingSummary booking;
  final VoidCallback? onTap;

  const VendorBookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  Color get _statusColor {
    switch (booking.status) {
      case VendorBookingStatus.pending:
        return AppColors.warning;
      case VendorBookingStatus.accepted:
        return AppColors.accent;
      case VendorBookingStatus.confirmed:
        return AppColors.primary;
      case VendorBookingStatus.completed:
        return AppColors.success;
      case VendorBookingStatus.declined:
      case VendorBookingStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case VendorBookingStatus.pending:
        return Icons.schedule;
      case VendorBookingStatus.accepted:
        return Icons.check_circle_outline;
      case VendorBookingStatus.confirmed:
        return Icons.verified;
      case VendorBookingStatus.completed:
        return Icons.task_alt;
      case VendorBookingStatus.declined:
        return Icons.cancel_outlined;
      case VendorBookingStatus.cancelled:
        return Icons.block;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _statusIcon,
                color: _statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.coupleNames,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.status.displayName,
                          style: AppTypography.labelSmall.copyWith(
                            color: _statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.bookingDateFormatted,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (booking.packageName != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.packageName!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (booking.totalAmount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.totalAmountFormatted,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
