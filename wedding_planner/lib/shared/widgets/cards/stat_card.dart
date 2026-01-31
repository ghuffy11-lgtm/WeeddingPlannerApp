import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_typography.dart';

/// Stat Card Widget
/// Used for displaying statistics (RSVP counts, etc.)
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.roseGold;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMedium,
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.h1.copyWith(
                color: AppColors.deepCharcoal,
                fontSize: 28,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(height: AppSpacing.micro),
              Icon(
                icon,
                color: color,
                size: 20,
              ),
            ],
            const SizedBox(height: AppSpacing.micro),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.warmGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat Card Variants for common use cases
class AcceptedStatCard extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const AcceptedStatCard({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      value: count.toString(),
      label: 'Accepted',
      icon: Icons.check_circle,
      accentColor: AppColors.success,
      onTap: onTap,
    );
  }
}

class DeclinedStatCard extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const DeclinedStatCard({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      value: count.toString(),
      label: 'Declined',
      icon: Icons.cancel,
      accentColor: AppColors.error,
      onTap: onTap,
    );
  }
}

class PendingStatCard extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const PendingStatCard({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      value: count.toString(),
      label: 'Pending',
      icon: Icons.schedule,
      accentColor: AppColors.pending,
      onTap: onTap,
    );
  }
}
