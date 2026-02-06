import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

/// Wedding Date Step
/// Dark theme with glassmorphism design
class WeddingDateStep extends StatelessWidget {
  const WeddingDateStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accentPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              // Title
              Center(
                child: Text(
                  "When's the big day?",
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Center(
                child: Text(
                  "We'll help you plan everything on time",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Date Picker Button
              _DatePickerButton(
                selectedDate: state.data.weddingDate,
                hasDate: state.data.hasWeddingDate,
                onDateSelected: (date) {
                  context.read<OnboardingBloc>().add(
                    OnboardingDateChanged(date: date, hasDate: true),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.base),
              // No date yet option
              _NoDateOption(
                isSelected: !state.data.hasWeddingDate,
                onTap: () {
                  context.read<OnboardingBloc>().add(
                    const OnboardingDateChanged(date: null, hasDate: false),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final DateTime? selectedDate;
  final bool hasDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerButton({
    required this.selectedDate,
    required this.hasDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? now.add(const Duration(days: 180)),
          firstDate: now,
          lastDate: now.add(const Duration(days: 365 * 3)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: AppColors.white,
                  surface: AppColors.surfaceDark,
                  onSurface: AppColors.textPrimary,
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: AppColors.surfaceDark,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: hasDate && selectedDate != null
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasDate && selectedDate != null
                    ? AppColors.primary
                    : AppColors.glassBorder,
                width: hasDate && selectedDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: hasDate && selectedDate != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Select your wedding date',
                    style: AppTypography.bodyLarge.copyWith(
                      color: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _NoDateOption extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _NoDateOption({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.base),
                Text(
                  "We haven't set a date yet",
                  style: AppTypography.bodyLarge.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
