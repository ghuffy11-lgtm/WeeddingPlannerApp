import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/budget.dart';

/// Budget Summary Card
class BudgetSummaryCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onEditBudget;

  const BudgetSummaryCard({
    super.key,
    required this.budget,
    this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Overview',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (onEditBudget != null)
                GlassIconButton(
                  icon: Icons.edit_outlined,
                  onTap: onEditBudget,
                  size: 32,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Total budget display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                budget.formattedTotalBudget,
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'total budget',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          _buildProgressBar(),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Spent',
                  budget.formattedTotalSpent,
                  budget.isOverBudget ? Colors.red : AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Remaining',
                  budget.formattedRemaining,
                  budget.remaining >= 0 ? Colors.green : Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Unpaid',
                  budget.formattedUnpaid,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final percentage = budget.percentageSpent.clamp(0.0, 100.0);
    final isOverBudget = budget.isOverBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(0)}% spent',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (isOverBudget)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Over Budget!',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.glassBorder,
            valueColor: AlwaysStoppedAnimation(
              isOverBudget ? Colors.red : AppColors.primary,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.h4.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Category Budget Card
class CategoryBudgetCard extends StatelessWidget {
  final CategoryBudget category;
  final VoidCallback? onTap;

  const CategoryBudgetCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = category.percentageSpent.clamp(0.0, 100.0);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getCategoryColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                category.category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.category.displayName,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.itemCount} expense${category.itemCount != 1 ? 's' : ''}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Progress and amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${category.spent.toStringAsFixed(0)}',
                style: AppTypography.labelLarge.copyWith(
                  color: category.isOverBudget ? Colors.red : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'of \$${category.allocated.toStringAsFixed(0)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Mini progress
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.glassBorder,
                  valueColor: AlwaysStoppedAnimation(
                    category.isOverBudget ? Colors.red : _getCategoryColor(),
                  ),
                  strokeWidth: 4,
                ),
                Center(
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    // Assign colors based on category
    switch (category.category) {
      case BudgetCategory.venue:
        return AppColors.primary;
      case BudgetCategory.catering:
        return Colors.orange;
      case BudgetCategory.photography:
        return AppColors.accent;
      case BudgetCategory.videography:
        return Colors.purple;
      case BudgetCategory.music:
        return Colors.pink;
      case BudgetCategory.flowers:
        return Colors.green;
      case BudgetCategory.attire:
        return AppColors.accentPurple;
      case BudgetCategory.beauty:
        return Colors.red;
      case BudgetCategory.transportation:
        return Colors.blue;
      case BudgetCategory.stationery:
        return Colors.teal;
      case BudgetCategory.gifts:
        return Colors.amber;
      case BudgetCategory.rings:
        return Colors.yellow;
      case BudgetCategory.officiant:
        return Colors.indigo;
      case BudgetCategory.cake:
        return Colors.brown;
      case BudgetCategory.rentals:
        return Colors.grey;
      case BudgetCategory.other:
        return AppColors.textSecondary;
    }
  }
}

/// Expense Card
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onPaymentTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onPaymentTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                expense.category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      expense.category.displayName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (expense.vendorName != null) ...[
                      Text(
                        ' • ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          expense.vendorName!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (expense.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    expense.dueDateFormatted,
                    style: AppTypography.bodySmall.copyWith(
                      color: expense.isOverdue
                          ? Colors.red
                          : expense.isDueSoon
                              ? Colors.orange
                              : AppColors.textTertiary,
                      fontWeight: expense.isOverdue || expense.isDueSoon
                          ? FontWeight.w600
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.actualCost.toStringAsFixed(0)}',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusBadge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            expense.paymentStatus.icon,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            expense.paymentStatus.displayName,
            style: AppTypography.labelMedium.copyWith(
              color: _getStatusColor(),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (expense.paymentStatus) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partiallyPaid:
        return Colors.orange;
      case PaymentStatus.pending:
        return AppColors.textSecondary;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }
}

/// Upcoming Payment Card
class UpcomingPaymentCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onPayNow;

  const UpcomingPaymentCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      backgroundColor: expense.isOverdue
          ? Colors.red.withValues(alpha: 0.1)
          : expense.isDueSoon
              ? Colors.orange.withValues(alpha: 0.1)
              : null,
      child: Row(
        children: [
          // Due indicator
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: expense.isOverdue
                  ? Colors.red
                  : expense.isDueSoon
                      ? Colors.orange
                      : AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.dueDateFormatted,
                  style: AppTypography.bodySmall.copyWith(
                    color: expense.isOverdue
                        ? Colors.red
                        : expense.isDueSoon
                            ? Colors.orange
                            : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.remainingPayment.toStringAsFixed(0)}',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onPayNow != null)
                GestureDetector(
                  onTap: onPayNow,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Mark Paid',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
