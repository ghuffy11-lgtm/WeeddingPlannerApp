import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class ExpenseDetailPage extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailPage({super.key, required this.expenseId});

  @override
  State<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(LoadExpenseDetail(widget.expenseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == BudgetActionStatus.success) {
            if (state.actionSuccessMessage == 'Expense deleted') {
              context.pop();
            } else if (state.actionSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccessMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
            context.read<BudgetBloc>().add(const ClearBudgetError());
          } else if (state.actionStatus == BudgetActionStatus.error &&
              state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<BudgetBloc>().add(const ClearBudgetError());
          }
        },
        builder: (context, state) {
          if (state.detailStatus == ExpenseDetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.detailStatus == ExpenseDetailStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.detailError ?? 'Failed to load expense',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassButton(
                    onTap: () => context.pop(),
                    child: Text(
                      'Go Back',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final expense = state.selectedExpense;
          if (expense == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(expense, state),
              SliverToBoxAdapter(
                child: _buildContent(expense),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Expense expense, BudgetState state) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      expandedHeight: 160,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: AppColors.textPrimary,
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.push('/budget/expense/${widget.expenseId}/edit');
          },
          icon: const Icon(Icons.edit_outlined),
          color: AppColors.textSecondary,
        ),
        IconButton(
          onPressed: () => _showDeleteConfirmation(context),
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getCategoryColor(expense.category).withValues(alpha: 0.3),
                AppColors.backgroundDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Category icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      expense.category.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    expense.title,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(BudgetCategory category) {
    switch (category) {
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
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildContent(Expense expense) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cost Card
          _buildCostCard(expense),
          const SizedBox(height: 16),

          // Payment Status Card
          _buildPaymentCard(expense),
          const SizedBox(height: 16),

          // Details Card
          _buildDetailsCard(expense),

          // Notes
          if (expense.notes != null) ...[
            const SizedBox(height: 16),
            _buildNotesCard(expense),
          ],

          // Vendor
          if (expense.vendorName != null) ...[
            const SizedBox(height: 16),
            _buildVendorCard(expense),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCostCard(Expense expense) {
    final difference = expense.difference;
    final isOverBudget = expense.isOverBudget;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${expense.estimatedCost.toStringAsFixed(0)}',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.glassBorder,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actual',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${expense.actualCost.toStringAsFixed(0)}',
                        style: AppTypography.h3.copyWith(
                          color: isOverBudget ? Colors.red : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (difference != 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isOverBudget ? Colors.red : Colors.green)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOverBudget
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 16,
                    color: isOverBudget ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOverBudget
                        ? '\$${(-difference).toStringAsFixed(0)} over budget'
                        : '\$${difference.toStringAsFixed(0)} under budget',
                    style: AppTypography.labelMedium.copyWith(
                      color: isOverBudget ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Expense expense) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusBadge(expense.paymentStatus),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${expense.paidAmount.toStringAsFixed(0)}',
                      style: AppTypography.h4.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              if (expense.remainingPayment > 0) ...[
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.glassBorder,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remaining',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${expense.remainingPayment.toStringAsFixed(0)}',
                          style: AppTypography.h4.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Update Status',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentStatus.values.map((status) {
              final isSelected = expense.paymentStatus == status;
              return GlassChip(
                label: '${status.icon} ${status.displayName}',
                isSelected: isSelected,
                onTap: isSelected
                    ? null
                    : () {
                        double paidAmount = 0;
                        if (status == PaymentStatus.paid) {
                          paidAmount = expense.actualCost;
                        } else if (status == PaymentStatus.partiallyPaid) {
                          paidAmount = expense.actualCost * 0.5;
                        }
                        context.read<BudgetBloc>().add(UpdatePaymentStatus(
                              expenseId: expense.id,
                              status: status,
                              paidAmount: paidAmount,
                            ));
                      },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    switch (status) {
      case PaymentStatus.paid:
        color = Colors.green;
        break;
      case PaymentStatus.partiallyPaid:
        color = Colors.orange;
        break;
      case PaymentStatus.pending:
        color = AppColors.textSecondary;
        break;
      case PaymentStatus.refunded:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Expense expense) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: expense.category.displayName,
          ),
          if (expense.dueDate != null)
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Due Date',
              value: expense.dueDateFormatted,
              valueColor: expense.isOverdue
                  ? Colors.red
                  : expense.isDueSoon
                      ? Colors.orange
                      : null,
            ),
          if (expense.description != null)
            _buildDetailRow(
              icon: Icons.description_outlined,
              label: 'Description',
              value: expense.description!,
            ),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Created',
            value:
                '${expense.createdAt.day}/${expense.createdAt.month}/${expense.createdAt.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Expense expense) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            expense.notes!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Expense expense) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendor',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.vendorName!,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (expense.vendorId != null)
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Expense?',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently remove this expense from your budget.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BudgetBloc>().add(DeleteExpense(widget.expenseId));
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
