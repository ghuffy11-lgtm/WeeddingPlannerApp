import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/budget.dart';

/// Filter for expenses
class ExpenseFilter {
  final BudgetCategory? category;
  final PaymentStatus? paymentStatus;
  final bool? isOverdue;
  final String? searchQuery;
  final int page;
  final int limit;

  const ExpenseFilter({
    this.category,
    this.paymentStatus,
    this.isOverdue,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  ExpenseFilter copyWith({
    BudgetCategory? category,
    PaymentStatus? paymentStatus,
    bool? isOverdue,
    String? searchQuery,
    int? page,
    int? limit,
  }) {
    return ExpenseFilter(
      category: category ?? this.category,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isOverdue: isOverdue ?? this.isOverdue,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// Paginated expenses result
class PaginatedExpenses {
  final List<Expense> expenses;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedExpenses({
    required this.expenses,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
}

/// Budget Repository Interface
abstract class BudgetRepository {
  /// Get budget overview
  Future<Either<Failure, Budget>> getBudget();

  /// Update total budget amount
  Future<Either<Failure, Budget>> updateTotalBudget(double amount);

  /// Get budget statistics
  Future<Either<Failure, BudgetStats>> getBudgetStats();

  /// Get expenses with filtering and pagination
  Future<Either<Failure, PaginatedExpenses>> getExpenses(ExpenseFilter filter);

  /// Get expenses by category
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(BudgetCategory category);

  /// Get single expense
  Future<Either<Failure, Expense>> getExpense(String id);

  /// Create new expense
  Future<Either<Failure, Expense>> createExpense(ExpenseRequest request);

  /// Update expense
  Future<Either<Failure, Expense>> updateExpense(String id, ExpenseRequest request);

  /// Delete expense
  Future<Either<Failure, void>> deleteExpense(String id);

  /// Update payment status
  Future<Either<Failure, Expense>> updatePaymentStatus(
    String id,
    PaymentStatus status,
    double paidAmount,
  );

  /// Update category allocation
  Future<Either<Failure, CategoryBudget>> updateCategoryAllocation(
    CategoryAllocationRequest request,
  );

  /// Get upcoming payments (due within X days)
  Future<Either<Failure, List<Expense>>> getUpcomingPayments({int days = 30});

  /// Get overdue payments
  Future<Either<Failure, List<Expense>>> getOverduePayments();
}
