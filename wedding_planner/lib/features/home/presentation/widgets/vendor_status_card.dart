import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/booking.dart';

/// Vendor Status Card Widget
/// Shows recent vendor bookings and their status
class VendorStatusCard extends StatelessWidget {
  final List<Booking> bookings;
  final VoidCallback? onViewAll;
  final Function(Booking)? onBookingTap;

  const VendorStatusCard({
    super.key,
    required this.bookings,
    this.onViewAll,
    this.onBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = bookings.where((b) => b.isPending).length;
    final confirmedCount = bookings.where((b) => b.isConfirmed).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusMedium,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vendors',
                style: AppTypography.h3.copyWith(
                  color: AppColors.deepCharcoal,
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.roseGold,
                    ),
                  ),
                ),
            ],
          ),

          // Status summary
          if (bookings.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Row(
              children: [
                _StatusChip(
                  icon: Icons.hourglass_empty,
                  label: '$pendingCount Pending',
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.small),
                _StatusChip(
                  icon: Icons.check_circle_outline,
                  label: '$confirmedCount Confirmed',
                  color: AppColors.success,
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.base),

          // Booking list
          if (bookings.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 48,
                      color: AppColors.warmGray.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      'No vendors booked yet',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.warmGray,
                      ),
                    ),
                    Text(
                      'Start exploring vendors',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...bookings.take(3).map((booking) => _BookingItem(
                  booking: booking,
                  onTap: onBookingTap != null ? () => onBookingTap!(booking) : null,
                )),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.tiny.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const _BookingItem({
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.small),
        child: Row(
          children: [
            // Vendor image/icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blushRose,
                borderRadius: BorderRadius.circular(10),
                image: booking.vendorImage != null
                    ? DecorationImage(
                        image: NetworkImage(booking.vendorImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: booking.vendorImage == null
                  ? Icon(
                      _getCategoryIcon(booking.vendorCategory),
                      color: AppColors.roseGold,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.small),

            // Vendor details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.vendorName,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    booking.vendorCategory,
                    style: AppTypography.tiny.copyWith(
                      color: AppColors.warmGray,
                    ),
                  ),
                ],
              ),
            ),

            // Status badge
            _BookingStatusBadge(status: booking.status),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Photography': Icons.camera_alt,
      'Videography': Icons.videocam,
      'Venue': Icons.location_on,
      'Catering': Icons.restaurant,
      'Music': Icons.music_note,
      'DJ': Icons.headphones,
      'Florist': Icons.local_florist,
      'Decoration': Icons.celebration,
      'Cake': Icons.cake,
      'Wedding Planner': Icons.event_note,
      'Makeup': Icons.face,
      'Hair': Icons.content_cut,
      'Dress': Icons.checkroom,
      'Jewelry': Icons.diamond,
      'Transportation': Icons.directions_car,
    };
    return icons[category] ?? Icons.store;
  }
}

class _BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _BookingStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case BookingStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        color = AppColors.success;
        label = 'Confirmed';
        break;
      case BookingStatus.declined:
        color = AppColors.error;
        label = 'Declined';
        break;
      case BookingStatus.completed:
        color = AppColors.roseGold;
        label = 'Completed';
        break;
      case BookingStatus.cancelled:
        color = AppColors.warmGray;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.tiny.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
