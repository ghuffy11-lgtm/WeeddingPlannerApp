import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';

/// Welcome Page
/// Introduces the app and provides login/register options
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blushRose,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Hero Section
              _buildHeroSection(context),
              const Spacer(flex: 2),
              // Features List
              _buildFeaturesList(),
              const Spacer(flex: 2),
              // Action Buttons
              _buildActionButtons(context),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.roseGold.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite,
            size: 50,
            color: AppColors.roseGold,
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        // Title
        Text(
          'Wedding Planner',
          style: AppTypography.h1.copyWith(
            color: AppColors.deepCharcoal,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.small),
        // Subtitle
        Text(
          'Your dream wedding, perfectly planned',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.warmGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      (Icons.check_circle_outline, 'Find trusted vendors'),
      (Icons.calendar_today_outlined, 'Plan every detail'),
      (Icons.people_outline, 'Manage your guest list'),
      (Icons.chat_bubble_outline, 'Chat with vendors'),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.roseGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature.$1,
                  color: AppColors.roseGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Text(
                feature.$2,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.deepCharcoal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Get Started',
          onPressed: () => context.push(AppRoutes.register),
        ),
        const SizedBox(height: AppSpacing.base),
        SecondaryButton(
          text: 'I already have an account',
          onPressed: () => context.push(AppRoutes.login),
        ),
      ],
    );
  }
}
