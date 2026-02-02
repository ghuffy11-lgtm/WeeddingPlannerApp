import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

/// Budget Step
/// Allows couples to set their wedding budget
class BudgetStep extends StatefulWidget {
  const BudgetStep({super.key});

  @override
  State<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends State<BudgetStep> {
  double _currentBudget = 25000;
  String _selectedCurrency = 'USD';

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'KWD', 'symbol': 'KD', 'name': 'Kuwaiti Dinar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize from bloc state if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<OnboardingBloc>().state;
      if (state.data.budget != null) {
        setState(() {
          _currentBudget = state.data.budget!;
          _selectedCurrency = state.data.currency;
        });
      }
    });
  }

  void _updateBudget() {
    context.read<OnboardingBloc>().add(
      OnboardingBudgetChanged(
        budget: _currentBudget,
        currency: _selectedCurrency,
      ),
    );
  }

  String _formatBudget(double value) {
    final currency = _currencies.firstWhere((c) => c['code'] == _selectedCurrency);
    if (value >= 100000) {
      return '${currency['symbol']}100,000+';
    }
    return '${currency['symbol']}${value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    )}';
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
                Icons.account_balance_wallet,
                size: 40,
                color: AppColors.roseGold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          // Title
          Center(
            child: Text(
              "What's your budget?",
              style: AppTypography.h2.copyWith(
                color: AppColors.deepCharcoal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Center(
            child: Text(
              "This helps us recommend vendors within your range",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.warmGray,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Budget Display
          Center(
            child: Text(
              _formatBudget(_currentBudget),
              style: AppTypography.h1.copyWith(
                color: AppColors.roseGold,
                fontSize: 48,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          // Budget Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.roseGold,
              inactiveTrackColor: AppColors.champagne.withOpacity(0.3),
              thumbColor: AppColors.roseGold,
              overlayColor: AppColors.roseGold.withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _currentBudget,
              min: 5000,
              max: 100000,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  _currentBudget = value;
                });
              },
              onChangeEnd: (_) => _updateBudget(),
            ),
          ),
          // Min/Max labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$5,000',
                  style: AppTypography.caption.copyWith(color: AppColors.warmGray),
                ),
                Text(
                  '\$100,000+',
                  style: AppTypography.caption.copyWith(color: AppColors.warmGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Currency Selector
          Text(
            'Currency',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.deepCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: _currencies.map((currency) {
              final isSelected = _selectedCurrency == currency['code'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCurrency = currency['code']!;
                  });
                  _updateBudget();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.small,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.roseGold.withOpacity(0.1)
                        : AppColors.white,
                    borderRadius: AppSpacing.borderRadiusSmall,
                    border: Border.all(
                      color: isSelected ? AppColors.roseGold : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '${currency['symbol']} ${currency['code']}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? AppColors.roseGold : AppColors.warmGray,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
