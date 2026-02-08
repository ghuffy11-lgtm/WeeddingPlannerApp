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
import '../widgets/budget_widgets.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<BudgetBloc>()
      ..add(const LoadBudget())
      ..add(const LoadExpenses())
      ..add(const LoadUpcomingPayments())
      ..add(const LoadOverduePayments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == BudgetActionStatus.success &&
              state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccessMessage!),
                backgroundColor: Colors.green,
              ),
            );
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
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(innerBoxIsScrolled),
                if (state.budgetStatus == BudgetLoadStatus.loaded &&
                    state.budget != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BudgetSummaryCard(
                        budget: state.budget!,
                        onEditBudget: () => _showEditBudgetDialog(state.budget!),
                      ),
                    ),
                  ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    tabController: _tabController,
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(state),
                _buildExpensesTab(state),
                _buildPaymentsTab(state),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/budget/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: AppColors.textPrimary,
      ),
      title: Text(
        'Budget',
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCategoriesTab(BudgetState state) {
    if (state.budgetStatus == BudgetLoadStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.budget == null || state.budget!.categories.isEmpty) {
      return _buildEmptyState(
        icon: Icons.category_outlined,
        title: 'No categories yet',
        subtitle: 'Add expenses to see category breakdown',
      );
    }

    final categories = state.budget!.categories
      ..sort((a, b) => b.spent.compareTo(a.spent));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryBudgetCard(
          category: category,
          onTap: () => context.push(
            '/budget/category/${category.category.name}',
            extra: category,
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(BudgetState state) {
    if (state.expensesStatus == ExpenseListStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.expenses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses yet',
        subtitle: 'Tap + to add your first expense',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          context.read<BudgetBloc>().add(const LoadMoreExpenses());
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.expenses.length +
            (state.expensesStatus == ExpenseListStatus.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.expenses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final expense = state.expenses[index];
          return ExpenseCard(
            expense: expense,
            onTap: () => context.push('/budget/expense/${expense.id}'),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsTab(BudgetState state) {
    final hasOverdue = state.overduePayments.isNotEmpty;
    final hasUpcoming = state.upcomingPayments.isNotEmpty;

    if (!hasOverdue && !hasUpcoming) {
      return _buildEmptyState(
        icon: Icons.payments_outlined,
        title: 'No pending payments',
        subtitle: 'All caught up!',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overdue section
        if (hasOverdue) ...[
          _buildSectionHeader('Overdue', Colors.red, state.overduePayments.length),
          const SizedBox(height: 12),
          ...state.overduePayments.map((expense) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UpcomingPaymentCard(
                  expense: expense,
                  onTap: () => context.push('/budget/expense/${expense.id}'),
                  onPayNow: () => _showPaymentDialog(expense),
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Upcoming section
        if (hasUpcoming) ...[
          _buildSectionHeader(
              'Upcoming', AppColors.accent, state.upcomingPayments.length),
          const SizedBox(height: 12),
          ...state.upcomingPayments.map((expense) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UpcomingPaymentCard(
                  expense: expense,
                  onTap: () => context.push('/budget/expense/${expense.id}'),
                  onPayNow: () => _showPaymentDialog(expense),
                ),
              )),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(Budget budget) {
    final controller = TextEditingController(
      text: budget.totalBudget.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit Total Budget',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
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
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                context.read<BudgetBloc>().add(UpdateTotalBudget(amount));
                Navigator.pop(ctx);
              }
            },
            child: Text(
              'Save',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Mark as Paid?',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Mark "${expense.title}" as fully paid?',
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
              context.read<BudgetBloc>().add(UpdatePaymentStatus(
                    expenseId: expense.id,
                    status: PaymentStatus.paid,
                    paidAmount: expense.actualCost,
                  ));
              Navigator.pop(ctx);
            },
            child: Text(
              'Mark Paid',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab bar delegate for pinned tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate({required this.tabController});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.backgroundDark,
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelLarge,
        tabs: const [
          Tab(text: 'Categories'),
          Tab(text: 'Expenses'),
          Tab(text: 'Payments'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
