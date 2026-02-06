import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Welcome Page
/// Dark theme with glassmorphism design
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background glows
          const BackgroundGlow(
            color: AppColors.accentPurple,
            alignment: Alignment(-1, -0.5),
            size: 400,
          ),
          const BackgroundGlow(
            color: AppColors.primary,
            alignment: Alignment(1, 0.5),
            size: 350,
          ),
          const BackgroundGlow(
            color: AppColors.accentCyan,
            alignment: Alignment(0, 1),
            size: 300,
          ),

          // Content
          SafeArea(
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
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        // Logo with gradient
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite,
            size: 50,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        // Title
        Text(
          'Wedding Planner',
          style: AppTypography.hero.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.small),
        // Subtitle
        Text(
          'Your dream wedding, perfectly planned',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      (Icons.check_circle_outline, 'Find trusted vendors', AppColors.accent),
      (Icons.calendar_today_outlined, 'Plan every detail', AppColors.accentPurple),
      (Icons.people_outline, 'Manage your guest list', AppColors.primary),
      (Icons.chat_bubble_outline, 'Chat with vendors', AppColors.accent),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
          child: Row(
            children: [
              GlassCard(
                width: 44,
                height: 44,
                padding: EdgeInsets.zero,
                borderRadius: 12,
                child: Icon(
                  feature.$1,
                  color: feature.$3,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Text(
                  feature.$2,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
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
