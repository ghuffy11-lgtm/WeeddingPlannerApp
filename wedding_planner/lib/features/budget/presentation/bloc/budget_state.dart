import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

enum BudgetLoadStatus { initial, loading, loaded, error }
enum ExpenseListStatus { initial, loading, loaded, loadingMore, error }
enum ExpenseDetailStatus { initial, loading, loaded, error }
enum BudgetActionStatus { initial, loading, success, error }

class BudgetState extends Equatable {
  // Budget overview
  final BudgetLoadStatus budgetStatus;
  final Budget? budget;
  final String? budgetError;

  // Expenses list
  final ExpenseListStatus expensesStatus;
  final List<Expense> expenses;
  final ExpenseFilter currentFilter;
  final int currentPage;
  final bool hasMoreExpenses;
  final String? expensesError;

  // Category expenses
  final List<Expense> categoryExpenses;
  final BudgetCategory? selectedCategory;

  // Expense detail
  final ExpenseDetailStatus detailStatus;
  final Expense? selectedExpense;
  final String? detailError;

  // Upcoming and overdue
  final List<Expense> upcomingPayments;
  final List<Expense> overduePayments;

  // Action status (create, update, delete)
  final BudgetActionStatus actionStatus;
  final String? actionError;
  final String? actionSuccessMessage;

  const BudgetState({
    this.budgetStatus = BudgetLoadStatus.initial,
    this.budget,
    this.budgetError,
    this.expensesStatus = ExpenseListStatus.initial,
    this.expenses = const [],
    this.currentFilter = const ExpenseFilter(),
    this.currentPage = 1,
    this.hasMoreExpenses = false,
    this.expensesError,
    this.categoryExpenses = const [],
    this.selectedCategory,
    this.detailStatus = ExpenseDetailStatus.initial,
    this.selectedExpense,
    this.detailError,
    this.upcomingPayments = const [],
    this.overduePayments = const [],
    this.actionStatus = BudgetActionStatus.initial,
    this.actionError,
    this.actionSuccessMessage,
  });

  BudgetState copyWith({
    BudgetLoadStatus? budgetStatus,
    Budget? budget,
    String? budgetError,
    ExpenseListStatus? expensesStatus,
    List<Expense>? expenses,
    ExpenseFilter? currentFilter,
    int? currentPage,
    bool? hasMoreExpenses,
    String? expensesError,
    List<Expense>? categoryExpenses,
    BudgetCategory? selectedCategory,
    ExpenseDetailStatus? detailStatus,
    Expense? selectedExpense,
    String? detailError,
    List<Expense>? upcomingPayments,
    List<Expense>? overduePayments,
    BudgetActionStatus? actionStatus,
    String? actionError,
    String? actionSuccessMessage,
  }) {
    return BudgetState(
      budgetStatus: budgetStatus ?? this.budgetStatus,
      budget: budget ?? this.budget,
      budgetError: budgetError,
      expensesStatus: expensesStatus ?? this.expensesStatus,
      expenses: expenses ?? this.expenses,
      currentFilter: currentFilter ?? this.currentFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMoreExpenses: hasMoreExpenses ?? this.hasMoreExpenses,
      expensesError: expensesError,
      categoryExpenses: categoryExpenses ?? this.categoryExpenses,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedExpense: selectedExpense ?? this.selectedExpense,
      detailError: detailError,
      upcomingPayments: upcomingPayments ?? this.upcomingPayments,
      overduePayments: overduePayments ?? this.overduePayments,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        budgetStatus,
        budget,
        budgetError,
        expensesStatus,
        expenses,
        currentFilter,
        currentPage,
        hasMoreExpenses,
        expensesError,
        categoryExpenses,
        selectedCategory,
        detailStatus,
        selectedExpense,
        detailError,
        upcomingPayments,
        overduePayments,
        actionStatus,
        actionError,
        actionSuccessMessage,
      ];
}
