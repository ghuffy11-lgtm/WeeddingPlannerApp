import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/booking_model.dart';
import '../models/wedding_model.dart';
import '../models/wedding_task_model.dart';

/// Home Remote Data Source Interface
abstract class HomeRemoteDataSource {
  /// Get current user's wedding
  Future<WeddingModel?> getWedding();

  /// Create a new wedding (during onboarding)
  Future<WeddingModel> createWedding(Map<String, dynamic> data);

  /// Get upcoming tasks
  Future<List<WeddingTaskModel>> getUpcomingTasks({int limit = 5});

  /// Get budget summary by category
  Future<List<Map<String, dynamic>>> getBudgetSummary();

  /// Get recent bookings
  Future<List<BookingModel>> getRecentBookings({int limit = 3});

  /// Get task statistics
  Future<TaskStats> getTaskStats();

  /// Update wedding
  Future<WeddingModel> updateWedding(Map<String, dynamic> data);

  /// Mark task as complete
  Future<WeddingTaskModel> completeTask(String taskId);
}

/// Home Remote Data Source Implementation
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<WeddingModel> createWedding(Map<String, dynamic> data) async {
    try {
      final response = await dio.post<Map<String, dynamic>>('/weddings', data: data);

      if (response.statusCode == 201 && response.data != null) {
        return WeddingModel.fromJson(response.data!['data'] as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to create wedding',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to create wedding',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<WeddingModel?> getWedding() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/weddings/me');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['data'] != null) {
          return WeddingModel.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No wedding found
      }
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to get wedding',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<WeddingTaskModel>> getUpcomingTasks({int limit = 5}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/weddings/me/tasks',
        queryParameters: {
          'limit': limit,
          'status': 'pending',
          'sort': 'due_date',
          'order': 'asc',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!['data'] as List<dynamic>? ?? [];
        return data
            .map((json) =>
                WeddingTaskModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      // Handle 400/403/404 as "no data" - user may not have wedding or proper access yet
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 404) {
        return [];
      }
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to get tasks',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBudgetSummary() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/weddings/me/budget/summary');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!['data'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      // Handle 400/403/404 as "no data" - user may not have wedding or proper access yet
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 404) {
        return [];
      }
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to get budget summary',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<BookingModel>> getRecentBookings({int limit = 3}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/bookings',
        queryParameters: {
          'limit': limit,
          'sort': 'created_at',
          'order': 'desc',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data!['data'] as List<dynamic>? ?? [];
        return data
            .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      // Handle 400/403/404 as "no data" - user may not have wedding or proper access yet
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 404) {
        return [];
      }
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to get bookings',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TaskStats> getTaskStats() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/weddings/me/tasks/stats');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        return TaskStats(
          total: data?['total'] as int? ?? 0,
          completed: data?['completed'] as int? ?? 0,
          pending: data?['pending'] as int? ?? 0,
          overdue: data?['overdue'] as int? ?? 0,
        );
      }
      return const TaskStats(total: 0, completed: 0, pending: 0, overdue: 0);
    } on DioException catch (e) {
      // Handle 400/403/404 as "no data" - user may not have wedding or proper access yet
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 404) {
        return const TaskStats(total: 0, completed: 0, pending: 0, overdue: 0);
      }
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to get task stats',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<WeddingModel> updateWedding(Map<String, dynamic> data) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>('/weddings/me', data: data);

      if (response.statusCode == 200 && response.data != null) {
        return WeddingModel.fromJson(
            response.data!['data'] as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to update wedding',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to update wedding',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<WeddingTaskModel> completeTask(String taskId) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '/weddings/me/tasks/$taskId',
        data: {'status': 'completed'},
      );

      if (response.statusCode == 200 && response.data != null) {
        return WeddingTaskModel.fromJson(
            response.data!['data'] as Map<String, dynamic>);
      }
      throw ServerException(
        message: 'Failed to complete task',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final errorData = e.response?.data as Map<String, dynamic>?;
      throw ServerException(
        message: errorData?['message'] as String? ?? 'Failed to complete task',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
