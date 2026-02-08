import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

/// Load budget overview
class LoadBudget extends BudgetEvent {
  const LoadBudget();
}

/// Refresh budget data
class RefreshBudget extends BudgetEvent {
  const RefreshBudget();
}

/// Update total budget amount
class UpdateTotalBudget extends BudgetEvent {
  final double amount;

  const UpdateTotalBudget(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Load expenses with filter
class LoadExpenses extends BudgetEvent {
  final ExpenseFilter filter;

  const LoadExpenses({this.filter = const ExpenseFilter()});

  @override
  List<Object?> get props => [filter];
}

/// Load more expenses (pagination)
class LoadMoreExpenses extends BudgetEvent {
  const LoadMoreExpenses();
}

/// Update expense filter
class UpdateExpenseFilter extends BudgetEvent {
  final ExpenseFilter filter;

  const UpdateExpenseFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Load expenses by category
class LoadExpensesByCategory extends BudgetEvent {
  final BudgetCategory category;

  const LoadExpensesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Load single expense detail
class LoadExpenseDetail extends BudgetEvent {
  final String expenseId;

  const LoadExpenseDetail(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

/// Create new expense
class CreateExpense extends BudgetEvent {
  final ExpenseRequest request;

  const CreateExpense(this.request);

  @override
  List<Object?> get props => [request];
}

/// Update expense
class UpdateExpense extends BudgetEvent {
  final String expenseId;
  final ExpenseRequest request;

  const UpdateExpense({
    required this.expenseId,
    required this.request,
  });

  @override
  List<Object?> get props => [expenseId, request];
}

/// Delete expense
class DeleteExpense extends BudgetEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

/// Update payment status
class UpdatePaymentStatus extends BudgetEvent {
  final String expenseId;
  final PaymentStatus status;
  final double paidAmount;

  const UpdatePaymentStatus({
    required this.expenseId,
    required this.status,
    required this.paidAmount,
  });

  @override
  List<Object?> get props => [expenseId, status, paidAmount];
}

/// Update category allocation
class UpdateCategoryAllocation extends BudgetEvent {
  final BudgetCategory category;
  final double amount;

  const UpdateCategoryAllocation({
    required this.category,
    required this.amount,
  });

  @override
  List<Object?> get props => [category, amount];
}

/// Load upcoming payments
class LoadUpcomingPayments extends BudgetEvent {
  final int days;

  const LoadUpcomingPayments({this.days = 30});

  @override
  List<Object?> get props => [days];
}

/// Load overdue payments
class LoadOverduePayments extends BudgetEvent {
  const LoadOverduePayments();
}

/// Clear error
class ClearBudgetError extends BudgetEvent {
  const ClearBudgetError();
}
