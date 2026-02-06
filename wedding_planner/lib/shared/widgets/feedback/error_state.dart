import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Error State Widget
/// Displayed when an error occurs
class ErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonTap;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonTap;

  const ErrorState({
    super.key,
    this.icon = Icons.error_outline,
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
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.error,
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
                  color: AppColors.textSecondary,
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

/// Pre-built Error States for common scenarios
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.wifi_off,
      title: 'Connection lost',
      description: 'Check your internet and try again',
      primaryButtonText: 'Retry',
      onPrimaryButtonTap: onRetry,
    );
  }
}

class PaymentFailedErrorState extends StatelessWidget {
  final VoidCallback? onTryAgain;
  final VoidCallback? onChangePayment;

  const PaymentFailedErrorState({
    super.key,
    this.onTryAgain,
    this.onChangePayment,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.warning_amber,
      title: 'Payment unsuccessful',
      description: 'Your card was declined.\nPlease try a different payment.',
      primaryButtonText: 'Try Again',
      onPrimaryButtonTap: onTryAgain,
      secondaryButtonText: 'Change Payment',
      onSecondaryButtonTap: onChangePayment,
    );
  }
}

class DateUnavailableErrorState extends StatelessWidget {
  final VoidCallback? onViewSimilarVendors;
  final VoidCallback? onChooseDifferentDate;

  const DateUnavailableErrorState({
    super.key,
    this.onViewSimilarVendors,
    this.onChooseDifferentDate,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.calendar_today,
      title: 'Date unavailable',
      description: 'This vendor is booked for your wedding date. Try these instead:',
      primaryButtonText: 'Similar Vendors',
      onPrimaryButtonTap: onViewSimilarVendors,
      secondaryButtonText: 'Choose Different Date',
      onSecondaryButtonTap: onChooseDifferentDate,
    );
  }
}

class GenericErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const GenericErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      description: message ?? 'Please try again later',
      primaryButtonText: 'Retry',
      onPrimaryButtonTap: onRetry,
    );
  }
}
