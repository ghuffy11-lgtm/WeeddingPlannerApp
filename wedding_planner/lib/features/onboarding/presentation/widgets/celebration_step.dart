import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

/// Celebration Step
/// Shows congratulations and next steps
class CelebrationStep extends StatefulWidget {
  const CelebrationStep({super.key});

  @override
  State<CelebrationStep> createState() => _CelebrationStepState();
}

class _CelebrationStepState extends State<CelebrationStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            // Celebration Icon with animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.roseGold.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 60,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Title
            Text(
              "You're all set!",
              style: AppTypography.h1.copyWith(
                color: AppColors.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.base),
            // Subtitle
            Text(
              "Your wedding planning journey begins now.\nLet's make your dream wedding a reality!",
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.warmGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Quick Action Cards
            _QuickActionCard(
              icon: Icons.checklist,
              title: 'Create Your Checklist',
              description: 'Get a personalized planning checklist',
              onTap: () => context.go(AppRoutes.tasks),
            ),
            const SizedBox(height: AppSpacing.base),
            _QuickActionCard(
              icon: Icons.store,
              title: 'Explore Vendors',
              description: 'Find the perfect vendors for your wedding',
              onTap: () => context.go(AppRoutes.vendors),
            ),
            const SizedBox(height: AppSpacing.base),
            _QuickActionCard(
              icon: Icons.home,
              title: 'Go to Dashboard',
              description: 'Start planning from your home screen',
              onTap: () => context.go(AppRoutes.home),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusMedium,
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.roseGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.roseGold,
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.warmGray,
            ),
          ],
        ),
      ),
    );
  }
}
