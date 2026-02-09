import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<PaginatedTasks> getTasks(TaskFilter filter);
  Future<TaskModel> getTask(String id);
  Future<TaskModel> createTask(TaskRequest request);
  Future<TaskModel> updateTask(String id, TaskRequest request);
  Future<void> deleteTask(String id);
  Future<TaskModel> updateTaskStatus(String id, TaskStatus status);
  Future<TaskModel> toggleSubtask(String taskId, int subtaskIndex);
  Future<TaskStatsModel> getTaskStats();
  Future<List<TaskSummaryModel>> getTasksByCategory(TaskCategory category);
  Future<List<TaskSummaryModel>> getOverdueTasks();
  Future<List<TaskSummaryModel>> getTasksDueSoon({int days = 7});
  Future<void> bulkUpdateStatus(List<String> taskIds, TaskStatus status);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedTasks> getTasks(TaskFilter filter) async {
    try {
      final queryParams = <String, dynamic>{
        'page': filter.page,
        'limit': filter.limit,
      };

      if (filter.status != null) {
        queryParams['status'] = filter.status!.name;
      }
      if (filter.category != null) {
        queryParams['category'] = filter.category!.name;
      }
      if (filter.priority != null) {
        queryParams['priority'] = filter.priority!.name;
      }
      if (filter.isOverdue != null) {
        queryParams['isOverdue'] = filter.isOverdue;
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryParams['search'] = filter.searchQuery;
      }

      final response = await dio.get(
        '/api/v1/tasks',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final tasksData = (data['tasks'] ?? data['data'] ?? []) as List;
      final tasks = tasksData
          .map((json) => TaskSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedTasks(
        tasks: tasks,
        currentPage: (data['currentPage'] ?? data['current_page'] ?? filter.page) as int,
        totalPages: (data['totalPages'] ?? data['total_pages'] ?? 1) as int,
        totalItems: (data['totalItems'] ?? data['total_items'] ?? tasks.length) as int,
        hasMore: (data['hasMore'] ?? data['has_more'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load tasks') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TaskModel> getTask(String id) async {
    try {
      final response = await dio.get('/api/v1/tasks/$id');
      final data = (response.data['task'] ?? response.data) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Task not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load task') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TaskModel> createTask(TaskRequest request) async {
    try {
      final response = await dio.post(
        '/api/v1/tasks',
        data: request.toJson(),
      );
      final data = (response.data['task'] ?? response.data) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Validation failed') as String,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to create task') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TaskModel> updateTask(String id, TaskRequest request) async {
    try {
      final response = await dio.put(
        '/api/v1/tasks/$id',
        data: request.toJson(),
      );
      final data = (response.data['task'] ?? response.data) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Task not found');
      }
      if (e.response?.statusCode == 422) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Validation failed') as String,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update task') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await dio.delete('/api/v1/tasks/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Task not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to delete task') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TaskModel> updateTaskStatus(String id, TaskStatus status) async {
    try {
      final response = await dio.patch(
        '/api/v1/tasks/$id/status',
        data: {'status': status.name},
      );
      final data = (response.data['task'] ?? response.data) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Task not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update task status') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TaskModel> toggleSubtask(String taskId, int subtaskIndex) async {
    try {
      final response = await dio.patch(
        '/api/v1/tasks/$taskId/subtasks/$subtaskIndex/toggle',
      );
      final data = (response.data['task'] ?? response.data) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Task or subtask not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to toggle subtask') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TaskStatsModel> getTaskStats() async {
    try {
      final response = await dio.get('/api/v1/tasks/stats');
      final data = (response.data['stats'] ?? response.data) as Map<String, dynamic>;
      return TaskStatsModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load task stats') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<TaskSummaryModel>> getTasksByCategory(TaskCategory category) async {
    try {
      final response = await dio.get(
        '/api/v1/tasks',
        queryParameters: {'category': category.name},
      );
      final data = response.data as Map<String, dynamic>;
      final tasksData = (data['tasks'] ?? data['data'] ?? []) as List;
      return tasksData
          .map((json) => TaskSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load tasks') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<TaskSummaryModel>> getOverdueTasks() async {
    try {
      final response = await dio.get(
        '/api/v1/tasks',
        queryParameters: {'isOverdue': true},
      );
      final data = response.data as Map<String, dynamic>;
      final tasksData = (data['tasks'] ?? data['data'] ?? []) as List;
      return tasksData
          .map((json) => TaskSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load overdue tasks') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<TaskSummaryModel>> getTasksDueSoon({int days = 7}) async {
    try {
      final response = await dio.get(
        '/api/v1/tasks',
        queryParameters: {'dueSoon': days},
      );
      final data = response.data as Map<String, dynamic>;
      final tasksData = (data['tasks'] ?? data['data'] ?? []) as List;
      return tasksData
          .map((json) => TaskSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load tasks') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> bulkUpdateStatus(List<String> taskIds, TaskStatus status) async {
    try {
      await dio.patch(
        '/api/v1/tasks/bulk-status',
        data: {
          'taskIds': taskIds,
          'status': status.name,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update tasks') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
