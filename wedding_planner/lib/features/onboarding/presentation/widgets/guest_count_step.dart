import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

/// Guest Count Step
/// Allows couples to estimate their guest count
class GuestCountStep extends StatefulWidget {
  const GuestCountStep({super.key});

  @override
  State<GuestCountStep> createState() => _GuestCountStepState();
}

class _GuestCountStepState extends State<GuestCountStep> {
  final TextEditingController _controller = TextEditingController();
  String _selectedRegion = 'western';

  final Map<String, Map<String, dynamic>> _regionInfo = {
    'western': {
      'name': 'Western',
      'average': '100-150 guests',
      'default': 125,
    },
    'middleEast': {
      'name': 'Middle East',
      'average': '300-500 guests',
      'default': 400,
    },
    'southAsian': {
      'name': 'South Asian',
      'average': '200-400 guests',
      'default': 300,
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<OnboardingBloc>().state;
      if (state.data.guestCount != null) {
        _controller.text = state.data.guestCount.toString();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setDefaultForRegion(String region) {
    final defaultCount = _regionInfo[region]!['default'] as int;
    _controller.text = defaultCount.toString();
    context.read<OnboardingBloc>().add(
      OnboardingGuestCountChanged(count: defaultCount),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.roseGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.groups,
                size: 40,
                color: AppColors.roseGold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          // Title
          Center(
            child: Text(
              'How many guests?',
              style: AppTypography.h2.copyWith(
                color: AppColors.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Center(
            child: Text(
              "An estimate helps with venue and catering planning",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.warmGray,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Guest Count Input
          Center(
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(
                  color: AppColors.roseGold,
                  fontSize: 48,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: AppTypography.h1.copyWith(
                    color: AppColors.warmGray.withOpacity(0.5),
                    fontSize: 48,
                  ),
                  border: InputBorder.none,
                  suffixText: 'guests',
                  suffixStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warmGray,
                  ),
                ),
                onChanged: (value) {
                  final count = int.tryParse(value);
                  if (count != null) {
                    context.read<OnboardingBloc>().add(
                      OnboardingGuestCountChanged(count: count),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Region-based suggestions
          Text(
            'Quick select by region',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.deepCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Average wedding sizes vary by culture',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warmGray,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // Region Options
          ..._regionInfo.entries.map((entry) {
            final isSelected = _selectedRegion == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRegion = entry.key;
                  });
                  _setDefaultForRegion(entry.key);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.roseGold.withOpacity(0.1)
                        : AppColors.white,
                    borderRadius: AppSpacing.borderRadiusMedium,
                    border: Border.all(
                      color: isSelected ? AppColors.roseGold : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppColors.roseGold : AppColors.warmGray,
                      ),
                      const SizedBox(width: AppSpacing.base),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value['name'] as String,
                              style: AppTypography.bodyLarge.copyWith(
                                color: isSelected
                                    ? AppColors.roseGold
                                    : AppColors.deepCharcoal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Average: ${entry.value['average']}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warmGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
