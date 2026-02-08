import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<BudgetModel> getBudget();
  Future<BudgetModel> updateTotalBudget(double amount);
  Future<BudgetStatsModel> getBudgetStats();
  Future<PaginatedExpenses> getExpenses(ExpenseFilter filter);
  Future<List<ExpenseModel>> getExpensesByCategory(BudgetCategory category);
  Future<ExpenseModel> getExpense(String id);
  Future<ExpenseModel> createExpense(ExpenseRequest request);
  Future<ExpenseModel> updateExpense(String id, ExpenseRequest request);
  Future<void> deleteExpense(String id);
  Future<ExpenseModel> updatePaymentStatus(String id, PaymentStatus status, double paidAmount);
  Future<CategoryBudgetModel> updateCategoryAllocation(CategoryAllocationRequest request);
  Future<List<ExpenseModel>> getUpcomingPayments({int days = 30});
  Future<List<ExpenseModel>> getOverduePayments();
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final Dio dio;

  BudgetRemoteDataSourceImpl({required this.dio});

  @override
  Future<BudgetModel> getBudget() async {
    try {
      final response = await dio.get('/budget');
      return BudgetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load budget') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<BudgetModel> updateTotalBudget(double amount) async {
    try {
      final response = await dio.patch(
        '/budget',
        data: {'totalBudget': amount},
      );
      return BudgetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update budget') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<BudgetStatsModel> getBudgetStats() async {
    try {
      final response = await dio.get('/budget/stats');
      return BudgetStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load budget stats') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PaginatedExpenses> getExpenses(ExpenseFilter filter) async {
    try {
      final queryParams = <String, dynamic>{
        'page': filter.page,
        'limit': filter.limit,
      };

      if (filter.category != null) {
        queryParams['category'] = filter.category!.name;
      }
      if (filter.paymentStatus != null) {
        queryParams['paymentStatus'] = filter.paymentStatus!.name;
      }
      if (filter.isOverdue != null) {
        queryParams['isOverdue'] = filter.isOverdue;
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryParams['search'] = filter.searchQuery;
      }

      final response = await dio.get(
        '/budget/expenses',
        queryParameters: queryParams,
      );

      final data = response.data['data'];
      final expenses = (data['expenses'] as List)
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedExpenses(
        expenses: expenses,
        currentPage: (data['currentPage'] ?? data['current_page'] ?? 1) as int,
        totalPages: (data['totalPages'] ?? data['total_pages'] ?? 1) as int,
        totalItems: (data['totalItems'] ?? data['total_items'] ?? expenses.length) as int,
        hasMore: (data['hasMore'] ?? data['has_more'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load expenses') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(BudgetCategory category) async {
    try {
      final response = await dio.get('/budget/expenses/category/${category.name}');
      final data = response.data['data'] as List;
      return data.map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load expenses') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> getExpense(String id) async {
    try {
      final response = await dio.get('/budget/expenses/$id');
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Expense not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load expense') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseRequest request) async {
    try {
      final response = await dio.post(
        '/budget/expenses',
        data: request.toJson(),
      );
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid expense data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to create expense') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> updateExpense(String id, ExpenseRequest request) async {
    try {
      final response = await dio.put(
        '/budget/expenses/$id',
        data: request.toJson(),
      );
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Expense not found');
      }
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid expense data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update expense') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await dio.delete('/budget/expenses/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Expense not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to delete expense') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> updatePaymentStatus(
    String id,
    PaymentStatus status,
    double paidAmount,
  ) async {
    try {
      final response = await dio.patch(
        '/budget/expenses/$id/payment',
        data: {
          'paymentStatus': status.name,
          'paidAmount': paidAmount,
        },
      );
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Expense not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update payment status') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<CategoryBudgetModel> updateCategoryAllocation(CategoryAllocationRequest request) async {
    try {
      final response = await dio.patch(
        '/budget/categories/${request.category.name}',
        data: request.toJson(),
      );
      return CategoryBudgetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update allocation') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getUpcomingPayments({int days = 30}) async {
    try {
      final response = await dio.get(
        '/budget/expenses/upcoming',
        queryParameters: {'days': days},
      );
      final data = response.data['data'] as List;
      return data.map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load upcoming payments') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getOverduePayments() async {
    try {
      final response = await dio.get('/budget/expenses/overdue');
      final data = response.data['data'] as List;
      return data.map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load overdue payments') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
