import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/budget_item.dart';

/// Budget Overview Card Widget
/// Shows budget summary with progress bar and category breakdown
class BudgetOverviewCard extends StatelessWidget {
  final double totalBudget;
  final double spentAmount;
  final String currency;
  final List<BudgetCategorySummary> categories;
  final VoidCallback? onTap;

  const BudgetOverviewCard({
    super.key,
    required this.totalBudget,
    required this.spentAmount,
    this.currency = 'USD',
    this.categories = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - spentAmount;
    final percentageSpent = totalBudget > 0 ? (spentAmount / totalBudget) : 0.0;
    final isOverBudget = spentAmount > totalBudget;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.deepCharcoal,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.warmGray,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Total budget display
            if (totalBudget > 0) ...[
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentageSpent.clamp(0.0, 1.0),
                  backgroundColor: AppColors.blushRose,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? AppColors.error : AppColors.roseGold,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Amount summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AmountColumn(
                    label: 'Spent',
                    amount: spentAmount,
                    currency: currency,
                    color: isOverBudget ? AppColors.error : AppColors.deepCharcoal,
                  ),
                  _AmountColumn(
                    label: 'Remaining',
                    amount: remaining,
                    currency: currency,
                    color: isOverBudget ? AppColors.error : AppColors.success,
                    alignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.micro),

              // Total budget text
              Center(
                child: Text(
                  'of ${_formatCurrency(totalBudget, currency)} budget',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warmGray,
                  ),
                ),
              ),

              // Category breakdown (top 3)
              if (categories.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.base),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.small),
                ...categories.take(3).map((cat) => _CategoryRow(
                      category: cat,
                      currency: currency,
                    )),
              ],
            ] else ...[
              // No budget set
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: AppColors.warmGray,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      'Set your budget',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.warmGray,
                      ),
                    ),
                    Text(
                      'Track your wedding expenses',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount, String currency) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'AED': 'AED ',
      'KWD': 'KWD ',
    };
    final symbol = symbols[currency] ?? '\$';
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

class _AmountColumn extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;
  final CrossAxisAlignment alignment;

  const _AmountColumn({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'AED': 'AED ',
      'KWD': 'KWD ',
    };
    final symbol = symbols[currency] ?? '\$';

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.warmGray,
          ),
        ),
        Text(
          '$symbol${amount.toStringAsFixed(0)}',
          style: AppTypography.h3.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final BudgetCategorySummary category;
  final String currency;

  const _CategoryRow({
    required this.category,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'AED': 'AED ',
      'KWD': 'KWD ',
    };
    final symbol = symbols[currency] ?? '\$';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.micro),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category.category,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '$symbol${category.spent.toStringAsFixed(0)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.deepCharcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
