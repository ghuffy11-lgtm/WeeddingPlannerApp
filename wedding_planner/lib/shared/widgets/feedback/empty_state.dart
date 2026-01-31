import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Empty State Widget
/// Displayed when there's no data to show
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonTap;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.primaryButtonText,
    this.onPrimaryButtonTap,
    this.secondaryButtonText,
    this.onSecondaryButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.blushRose,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.roseGold,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.warmGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryButtonText != null) ...[
              const SizedBox(height: AppSpacing.medium),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  text: primaryButtonText!,
                  onPressed: onPrimaryButtonTap,
                  isFullWidth: false,
                ),
              ),
            ],
            if (secondaryButtonText != null) ...[
              const SizedBox(height: AppSpacing.small),
              SizedBox(
                width: 200,
                child: SecondaryButton(
                  text: secondaryButtonText!,
                  onPressed: onSecondaryButtonTap,
                  isFullWidth: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-built Empty States for common scenarios
class NoVendorsSavedEmptyState extends StatelessWidget {
  final VoidCallback? onExploreVendors;

  const NoVendorsSavedEmptyState({
    super.key,
    this.onExploreVendors,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'No saved vendors yet',
      description: 'Heart your favorite vendors to keep track of them here',
      primaryButtonText: 'Explore Vendors',
      onPrimaryButtonTap: onExploreVendors,
    );
  }
}

class NoTasksEmptyState extends StatelessWidget {
  final VoidCallback? onAddTask;

  const NoTasksEmptyState({
    super.key,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.auto_awesome,
      title: 'All caught up!',
      description: "You've completed all your tasks. Enjoy this moment of calm.",
      primaryButtonText: 'Add Custom Task',
      onPrimaryButtonTap: onAddTask,
    );
  }
}

class NoRsvpsEmptyState extends StatelessWidget {
  final int sentCount;
  final VoidCallback? onSendReminder;

  const NoRsvpsEmptyState({
    super.key,
    required this.sentCount,
    this.onSendReminder,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.mail_outline,
      title: 'Waiting for responses...',
      description: "Invitations sent to $sentCount guests\nWe'll notify you as RSVPs arrive",
      primaryButtonText: 'Send Reminder',
      onPrimaryButtonTap: onSendReminder,
    );
  }
}

class NoGuestsEmptyState extends StatelessWidget {
  final VoidCallback? onImportGuests;
  final VoidCallback? onAddManually;

  const NoGuestsEmptyState({
    super.key,
    this.onImportGuests,
    this.onAddManually,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'No guests added yet',
      description: 'Add guests to start planning your seating arrangement',
      primaryButtonText: 'Import Guest List',
      onPrimaryButtonTap: onImportGuests,
      secondaryButtonText: 'Add Manually',
      onSecondaryButtonTap: onAddManually,
    );
  }
}
