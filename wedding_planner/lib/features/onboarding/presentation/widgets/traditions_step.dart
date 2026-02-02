import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/onboarding_data.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

/// Traditions Step
/// Allows couples to select their cultural traditions
class TraditionsStep extends StatelessWidget {
  const TraditionsStep({super.key});

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
                    Icons.auto_awesome,
                    size: 40,
                    color: AppColors.roseGold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              // Title
              Center(
                child: Text(
                  'Cultural Traditions',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.deepCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Center(
                child: Text(
                  "Select traditions you'd like to incorporate",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warmGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              // Traditions List
              ...CulturalTradition.values.map((tradition) {
                final isSelected = state.data.traditions.contains(tradition);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.small),
                  child: _TraditionTile(
                    tradition: tradition,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<OnboardingBloc>().add(
                        OnboardingTraditionToggled(tradition: tradition),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.base),
              // Selection count
              if (state.data.traditions.isNotEmpty)
                Center(
                  child: Text(
                    '${state.data.traditions.length} tradition${state.data.traditions.length > 1 ? 's' : ''} selected',
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

class _TraditionTile extends StatelessWidget {
  final CulturalTradition tradition;
  final bool isSelected;
  final VoidCallback onTap;

  const _TraditionTile({
    required this.tradition,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (tradition) {
      case CulturalTradition.western:
        return Icons.church;
      case CulturalTradition.islamic:
        return Icons.mosque;
      case CulturalTradition.hindu:
        return Icons.temple_hindu;
      case CulturalTradition.jewish:
        return Icons.synagogue;
      case CulturalTradition.chinese:
        return Icons.temple_buddhist;
      case CulturalTradition.african:
        return Icons.landscape;
      case CulturalTradition.latinAmerican:
        return Icons.celebration;
      case CulturalTradition.custom:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roseGold.withOpacity(0.1) : AppColors.white,
          borderRadius: AppSpacing.borderRadiusMedium,
          border: Border.all(
            color: isSelected ? AppColors.roseGold : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.roseGold.withOpacity(0.2)
                    : AppColors.blushRose,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _icon,
                color: isSelected ? AppColors.roseGold : AppColors.warmGray,
              ),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Text(
                tradition.displayName,
                style: AppTypography.bodyLarge.copyWith(
                  color: isSelected ? AppColors.roseGold : AppColors.deepCharcoal,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.roseGold : AppColors.warmGray,
            ),
          ],
        ),
      ),
    );
  }
}
