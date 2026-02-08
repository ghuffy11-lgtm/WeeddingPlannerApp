import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository repository;

  BudgetBloc({required this.repository}) : super(const BudgetState()) {
    on<LoadBudget>(_onLoadBudget);
    on<RefreshBudget>(_onRefreshBudget);
    on<UpdateTotalBudget>(_onUpdateTotalBudget);
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
    on<UpdateExpenseFilter>(_onUpdateExpenseFilter);
    on<LoadExpensesByCategory>(_onLoadExpensesByCategory);
    on<LoadExpenseDetail>(_onLoadExpenseDetail);
    on<CreateExpense>(_onCreateExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<UpdatePaymentStatus>(_onUpdatePaymentStatus);
    on<UpdateCategoryAllocation>(_onUpdateCategoryAllocation);
    on<LoadUpcomingPayments>(_onLoadUpcomingPayments);
    on<LoadOverduePayments>(_onLoadOverduePayments);
    on<ClearBudgetError>(_onClearBudgetError);
  }

  Future<void> _onLoadBudget(
    LoadBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(budgetStatus: BudgetLoadStatus.loading));

    final result = await repository.getBudget();

    result.fold(
      (failure) => emit(state.copyWith(
        budgetStatus: BudgetLoadStatus.error,
        budgetError: failure.message,
      )),
      (budget) => emit(state.copyWith(
        budgetStatus: BudgetLoadStatus.loaded,
        budget: budget,
      )),
    );
  }

  Future<void> _onRefreshBudget(
    RefreshBudget event,
    Emitter<BudgetState> emit,
  ) async {
    final result = await repository.getBudget();

    result.fold(
      (failure) => emit(state.copyWith(
        budgetError: failure.message,
      )),
      (budget) => emit(state.copyWith(
        budget: budget,
      )),
    );
  }

  Future<void> _onUpdateTotalBudget(
    UpdateTotalBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BudgetActionStatus.loading));

    final result = await repository.updateTotalBudget(event.amount);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BudgetActionStatus.error,
        actionError: failure.message,
      )),
      (budget) => emit(state.copyWith(
        actionStatus: BudgetActionStatus.success,
        budget: budget,
        actionSuccessMessage: 'Budget updated',
      )),
    );
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(
      expensesStatus: ExpenseListStatus.loading,
      currentFilter: event.filter,
      currentPage: 1,
    ));

    final result = await repository.getExpenses(event.filter);

    result.fold(
      (failure) => emit(state.copyWith(
        expensesStatus: ExpenseListStatus.error,
        expensesError: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        expensesStatus: ExpenseListStatus.loaded,
        expenses: paginated.expenses,
        currentPage: paginated.currentPage,
        hasMoreExpenses: paginated.hasMore,
      )),
    );
  }

  Future<void> _onLoadMoreExpenses(
    LoadMoreExpenses event,
    Emitter<BudgetState> emit,
  ) async {
    if (!state.hasMoreExpenses ||
        state.expensesStatus == ExpenseListStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(expensesStatus: ExpenseListStatus.loadingMore));

    final nextFilter = state.currentFilter.copyWith(page: state.currentPage + 1);
    final result = await repository.getExpenses(nextFilter);

    result.fold(
      (failure) => emit(state.copyWith(
        expensesStatus: ExpenseListStatus.loaded,
      )),
      (paginated) => emit(state.copyWith(
        expensesStatus: ExpenseListStatus.loaded,
        expenses: [...state.expenses, ...paginated.expenses],
        currentPage: paginated.currentPage,
        hasMoreExpenses: paginated.hasMore,
      )),
    );
  }

  Future<void> _onUpdateExpenseFilter(
    UpdateExpenseFilter event,
    Emitter<BudgetState> emit,
  ) async {
    add(LoadExpenses(filter: event.filter));
  }

  Future<void> _onLoadExpensesByCategory(
    LoadExpensesByCategory event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategory: event.category,
      expensesStatus: ExpenseListStatus.loading,
    ));

    final result = await repository.getExpensesByCategory(event.category);

    result.fold(
      (failure) => emit(state.copyWith(
        expensesStatus: ExpenseListStatus.error,
        expensesError: failure.message,
      )),
      (expenses) => emit(state.copyWith(
        expensesStatus: ExpenseListStatus.loaded,
        categoryExpenses: expenses,
      )),
    );
  }

  Future<void> _onLoadExpenseDetail(
    LoadExpenseDetail event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(detailStatus: ExpenseDetailStatus.loading));

    final result = await repository.getExpense(event.expenseId);

    result.fold(
      (failure) => emit(state.copyWith(
        detailStatus: ExpenseDetailStatus.error,
        detailError: failure.message,
      )),
      (expense) => emit(state.copyWith(
        detailStatus: ExpenseDetailStatus.loaded,
        selectedExpense: expense,
      )),
    );
  }

  Future<void> _onCreateExpense(
    CreateExpense event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BudgetActionStatus.loading));

    final result = await repository.createExpense(event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BudgetActionStatus.error,
        actionError: failure.message,
      )),
      (expense) {
        final updatedExpenses = [expense, ...state.expenses];
        emit(state.copyWith(
          actionStatus: BudgetActionStatus.success,
          expenses: updatedExpenses,
          actionSuccessMessage: 'Expense added',
        ));
        // Refresh budget to update totals
        add(const RefreshBudget());
      },
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BudgetActionStatus.loading));

    final result = await repository.updateExpense(event.expenseId, event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BudgetActionStatus.error,
        actionError: failure.message,
      )),
      (expense) {
        final updatedExpenses = state.expenses.map((e) {
          return e.id == expense.id ? expense : e;
        }).toList();
        emit(state.copyWith(
          actionStatus: BudgetActionStatus.success,
          expenses: updatedExpenses,
          selectedExpense: expense,
          actionSuccessMessage: 'Expense updated',
        ));
        // Refresh budget to update totals
        add(const RefreshBudget());
      },
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BudgetActionStatus.loading));

    final result = await repository.deleteExpense(event.expenseId);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BudgetActionStatus.error,
        actionError: failure.message,
      )),
      (_) {
        final updatedExpenses =
            state.expenses.where((e) => e.id != event.expenseId).toList();
        emit(state.copyWith(
          actionStatus: BudgetActionStatus.success,
          expenses: updatedExpenses,
          actionSuccessMessage: 'Expense deleted',
        ));
        // Refresh budget to update totals
        add(const RefreshBudget());
      },
    );
  }

  Future<void> _onUpdatePaymentStatus(
    UpdatePaymentStatus event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BudgetActionStatus.loading));

    final result = await repository.updatePaymentStatus(
      event.expenseId,
      event.status,
      event.paidAmount,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BudgetActionStatus.error,
        actionError: failure.message,
      )),
      (expense) {
        final updatedExpenses = state.expenses.map((e) {
          return e.id == expense.id ? expense : e;
        }).toList();
        emit(state.copyWith(
          actionStatus: BudgetActionStatus.success,
          expenses: updatedExpenses,
          selectedExpense: expense,
          actionSuccessMessage: 'Payment updated',
        ));
        // Refresh budget to update totals
        add(const RefreshBudget());
      },
    );
  }

  Future<void> _onUpdateCategoryAllocation(
    UpdateCategoryAllocation event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BudgetActionStatus.loading));

    final request = CategoryAllocationRequest(
      category: event.category,
      allocated: event.amount,
    );
    final result = await repository.updateCategoryAllocation(request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BudgetActionStatus.error,
        actionError: failure.message,
      )),
      (category) {
        emit(state.copyWith(
          actionStatus: BudgetActionStatus.success,
          actionSuccessMessage: 'Allocation updated',
        ));
        // Refresh budget to update categories
        add(const RefreshBudget());
      },
    );
  }

  Future<void> _onLoadUpcomingPayments(
    LoadUpcomingPayments event,
    Emitter<BudgetState> emit,
  ) async {
    final result = await repository.getUpcomingPayments(days: event.days);

    result.fold(
      (failure) => null,
      (expenses) => emit(state.copyWith(upcomingPayments: expenses)),
    );
  }

  Future<void> _onLoadOverduePayments(
    LoadOverduePayments event,
    Emitter<BudgetState> emit,
  ) async {
    final result = await repository.getOverduePayments();

    result.fold(
      (failure) => null,
      (expenses) => emit(state.copyWith(overduePayments: expenses)),
    );
  }

  void _onClearBudgetError(
    ClearBudgetError event,
    Emitter<BudgetState> emit,
  ) {
    emit(state.copyWith(
      actionStatus: BudgetActionStatus.initial,
      actionError: null,
      actionSuccessMessage: null,
    ));
  }
}
