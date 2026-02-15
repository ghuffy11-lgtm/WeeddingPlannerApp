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

/// Expense request for creating/updating expenses
class ExpenseRequest {
  final BudgetCategory category;
  final String title;
  final String? description;
  final double estimatedCost;
  final double? actualCost;
  final PaymentStatus? paymentStatus;
  final double? paidAmount;
  final DateTime? dueDate;
  final String? vendorId;
  final String? notes;

  const ExpenseRequest({
    required this.category,
    required this.title,
    this.description,
    required this.estimatedCost,
    this.actualCost,
    this.paymentStatus,
    this.paidAmount,
    this.dueDate,
    this.vendorId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'title': title,
        if (description != null) 'description': description,
        'estimatedCost': estimatedCost,
        if (actualCost != null) 'actualCost': actualCost,
        if (paymentStatus != null) 'paymentStatus': paymentStatus!.name,
        if (paidAmount != null) 'paidAmount': paidAmount,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (vendorId != null) 'vendorId': vendorId,
        if (notes != null) 'notes': notes,
      };
}

/// Category allocation request
class CategoryAllocationRequest {
  final BudgetCategory category;
  final double allocated;

  const CategoryAllocationRequest({
    required this.category,
    required this.allocated,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'allocated': allocated,
      };
}

/// Budget Repository Interface
/// All methods require [weddingId] - get from HomeRepository.getWedding()
abstract class BudgetRepository {
  /// Get budget overview
  Future<Either<Failure, Budget>> getBudget(String weddingId);

  /// Update total budget amount
  Future<Either<Failure, Budget>> updateTotalBudget(
      String weddingId, double amount);

  /// Get budget statistics
  Future<Either<Failure, BudgetStats>> getBudgetStats(String weddingId);

  /// Get expenses with filtering and pagination
  Future<Either<Failure, PaginatedExpenses>> getExpenses(
      String weddingId, ExpenseFilter filter);

  /// Get expenses by category
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(
      String weddingId, BudgetCategory category);

  /// Get single expense
  Future<Either<Failure, Expense>> getExpense(String weddingId, String id);

  /// Create new expense
  Future<Either<Failure, Expense>> createExpense(
      String weddingId, ExpenseRequest request);

  /// Update expense
  Future<Either<Failure, Expense>> updateExpense(
      String weddingId, String id, ExpenseRequest request);

  /// Delete expense
  Future<Either<Failure, void>> deleteExpense(String weddingId, String id);

  /// Update payment status
  Future<Either<Failure, Expense>> updatePaymentStatus(
    String weddingId,
    String id,
    PaymentStatus status,
    double paidAmount,
  );

  /// Update category allocation
  Future<Either<Failure, CategoryBudget>> updateCategoryAllocation(
    String weddingId,
    CategoryAllocationRequest request,
  );

  /// Get upcoming payments (due within X days)
  Future<Either<Failure, List<Expense>>> getUpcomingPayments(String weddingId,
      {int days = 30});

  /// Get overdue payments
  Future<Either<Failure, List<Expense>>> getOverduePayments(String weddingId);
}
