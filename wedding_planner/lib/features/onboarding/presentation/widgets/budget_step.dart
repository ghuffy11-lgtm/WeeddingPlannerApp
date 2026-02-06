import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

/// Budget Step
/// Dark theme with glassmorphism design
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
                Icons.account_balance_wallet,
                size: 40,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          // Title
          Center(
            child: Text(
              "What's your budget?",
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Center(
            child: Text(
              "This helps us recommend vendors within your range",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Budget Display
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ).createShader(bounds),
              child: Text(
                _formatBudget(_currentBudget),
                style: AppTypography.hero.copyWith(
                  color: AppColors.white,
                  fontSize: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          // Budget Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.glassBackground,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
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
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
                Text(
                  '\$100,000+',
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Currency Selector
          Text(
            'Currency',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.small,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.glassBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.glassBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '${currency['symbol']} ${currency['code']}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
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
