import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<BudgetModel> getBudget(String weddingId);
  Future<BudgetModel> updateTotalBudget(String weddingId, double amount);
  Future<BudgetStatsModel> getBudgetStats(String weddingId);
  Future<PaginatedExpenses> getExpenses(String weddingId, ExpenseFilter filter);
  Future<List<ExpenseModel>> getExpensesByCategory(
      String weddingId, BudgetCategory category);
  Future<ExpenseModel> getExpense(String weddingId, String id);
  Future<ExpenseModel> createExpense(String weddingId, ExpenseRequest request);
  Future<ExpenseModel> updateExpense(
      String weddingId, String id, ExpenseRequest request);
  Future<void> deleteExpense(String weddingId, String id);
  Future<ExpenseModel> updatePaymentStatus(
      String weddingId, String id, PaymentStatus status, double paidAmount);
  Future<CategoryBudgetModel> updateCategoryAllocation(
      String weddingId, CategoryAllocationRequest request);
  Future<List<ExpenseModel>> getUpcomingPayments(String weddingId,
      {int days = 30});
  Future<List<ExpenseModel>> getOverduePayments(String weddingId);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final Dio dio;

  BudgetRemoteDataSourceImpl({required this.dio});

  @override
  Future<BudgetModel> getBudget(String weddingId) async {
    try {
      final response = await dio.get('/weddings/$weddingId/budget');
      return BudgetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Return empty budget if none exists yet
        return BudgetModel.empty();
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load budget')
            as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<BudgetModel> updateTotalBudget(String weddingId, double amount) async {
    try {
      final response = await dio.patch(
        '/weddings/$weddingId/budget',
        data: {'totalBudget': amount},
      );
      return BudgetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update budget')
            as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<BudgetStatsModel> getBudgetStats(String weddingId) async {
    try {
      // Use the /me endpoint for budget summary
      final response = await dio.get('/weddings/me/budget/summary');
      return BudgetStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return BudgetStatsModel.empty();
      }
      throw ServerException(
        message:
            (e.response?.data?['message'] ?? 'Failed to load budget stats')
                as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PaginatedExpenses> getExpenses(
      String weddingId, ExpenseFilter filter) async {
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
        '/weddings/$weddingId/budget',
        queryParameters: queryParams,
      );

      final data = response.data['data'];
      final expenses = (data['expenses'] as List? ?? [])
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedExpenses(
        expenses: expenses,
        currentPage:
            (data['currentPage'] ?? data['current_page'] ?? 1) as int,
        totalPages: (data['totalPages'] ?? data['total_pages'] ?? 1) as int,
        totalItems: (data['totalItems'] ?? data['total_items'] ?? expenses.length)
            as int,
        hasMore: (data['hasMore'] ?? data['has_more'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw ServerException(
        message:
            (e.response?.data?['message'] ?? 'Failed to load expenses') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(
      String weddingId, BudgetCategory category) async {
    try {
      final response = await dio
          .get('/weddings/$weddingId/budget/category/${category.name}');
      final data = response.data['data'] as List;
      return data
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message:
            (e.response?.data?['message'] ?? 'Failed to load expenses') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> getExpense(String weddingId, String id) async {
    try {
      final response = await dio.get('/weddings/$weddingId/budget/$id');
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Expense not found');
      }
      throw ServerException(
        message:
            (e.response?.data?['message'] ?? 'Failed to load expense') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> createExpense(
      String weddingId, ExpenseRequest request) async {
    try {
      final response = await dio.post(
        '/weddings/$weddingId/budget',
        data: request.toJson(),
      );
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid expense data')
              as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to create expense')
            as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> updateExpense(
      String weddingId, String id, ExpenseRequest request) async {
    try {
      final response = await dio.put(
        '/weddings/$weddingId/budget/$id',
        data: request.toJson(),
      );
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Expense not found');
      }
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid expense data')
              as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update expense')
            as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteExpense(String weddingId, String id) async {
    try {
      await dio.delete('/weddings/$weddingId/budget/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Expense not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to delete expense')
            as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ExpenseModel> updatePaymentStatus(
    String weddingId,
    String id,
    PaymentStatus status,
    double paidAmount,
  ) async {
    try {
      final response = await dio.patch(
        '/weddings/$weddingId/budget/$id/payment',
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
        message: (e.response?.data?['message'] ??
            'Failed to update payment status') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<CategoryBudgetModel> updateCategoryAllocation(
      String weddingId, CategoryAllocationRequest request) async {
    try {
      final response = await dio.patch(
        '/weddings/$weddingId/budget/categories/${request.category.name}',
        data: request.toJson(),
      );
      return CategoryBudgetModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update allocation')
            as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getUpcomingPayments(String weddingId,
      {int days = 30}) async {
    try {
      final response = await dio.get(
        '/weddings/$weddingId/budget/upcoming',
        queryParameters: {'days': days},
      );
      final data = response.data['data'] as List? ?? [];
      return data
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ServerException(
        message: (e.response?.data?['message'] ??
            'Failed to load upcoming payments') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ExpenseModel>> getOverduePayments(String weddingId) async {
    try {
      final response =
          await dio.get('/weddings/$weddingId/budget/overdue');
      final data = response.data['data'] as List? ?? [];
      return data
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ServerException(
        message: (e.response?.data?['message'] ??
            'Failed to load overdue payments') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
