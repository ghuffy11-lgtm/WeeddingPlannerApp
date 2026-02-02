import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/onboarding_data.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

/// Styles Step
/// Allows couples to select their wedding style preferences
class StylesStep extends StatelessWidget {
  const StylesStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.large),
              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.roseGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.palette,
                    size: 40,
                    color: AppColors.roseGold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              // Title
              Center(
                child: Text(
                  "What's your style?",
                  style: AppTypography.h2.copyWith(
                    color: AppColors.deepCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Center(
                child: Text(
                  "Select all that inspire you (you can choose multiple)",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warmGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              // Style Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.base,
                  mainAxisSpacing: AppSpacing.base,
                  childAspectRatio: 1.2,
                ),
                itemCount: WeddingStyle.values.length,
                itemBuilder: (context, index) {
                  final style = WeddingStyle.values[index];
                  final isSelected = state.data.styles.contains(style);
                  return _StyleCard(
                    style: style,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<OnboardingBloc>().add(
                        OnboardingStyleToggled(style: style),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.base),
              // Selection count
              if (state.data.styles.isNotEmpty)
                Center(
                  child: Text(
                    '${state.data.styles.length} style${state.data.styles.length > 1 ? 's' : ''} selected',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.roseGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StyleCard extends StatelessWidget {
  final WeddingStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roseGold.withOpacity(0.1) : AppColors.white,
          borderRadius: AppSpacing.borderRadiusMedium,
          border: Border.all(
            color: isSelected ? AppColors.roseGold : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.roseGold.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    style.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    style.displayName,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? AppColors.roseGold : AppColors.deepCharcoal,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.roseGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
