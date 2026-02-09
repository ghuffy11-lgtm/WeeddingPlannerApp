import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';

/// Filter for tasks
class TaskFilter {
  final TaskStatus? status;
  final TaskCategory? category;
  final TaskPriority? priority;
  final bool? isOverdue;
  final String? searchQuery;
  final int page;
  final int limit;

  const TaskFilter({
    this.status,
    this.category,
    this.priority,
    this.isOverdue,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  TaskFilter copyWith({
    TaskStatus? status,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isOverdue,
    String? searchQuery,
    int? page,
    int? limit,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isOverdue: isOverdue ?? this.isOverdue,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// Paginated tasks result
class PaginatedTasks {
  final List<TaskSummary> tasks;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedTasks({
    required this.tasks,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
}

/// Task Repository Interface
abstract class TaskRepository {
  /// Get tasks with filtering and pagination
  Future<Either<Failure, PaginatedTasks>> getTasks(TaskFilter filter);

  /// Get single task
  Future<Either<Failure, Task>> getTask(String id);

  /// Create new task
  Future<Either<Failure, Task>> createTask(TaskRequest request);

  /// Update task
  Future<Either<Failure, Task>> updateTask(String id, TaskRequest request);

  /// Delete task
  Future<Either<Failure, void>> deleteTask(String id);

  /// Update task status
  Future<Either<Failure, Task>> updateTaskStatus(String id, TaskStatus status);

  /// Toggle subtask completion
  Future<Either<Failure, Task>> toggleSubtask(String taskId, int subtaskIndex);

  /// Get task statistics
  Future<Either<Failure, TaskStats>> getTaskStats();

  /// Get tasks by category
  Future<Either<Failure, List<TaskSummary>>> getTasksByCategory(TaskCategory category);

  /// Get overdue tasks
  Future<Either<Failure, List<TaskSummary>>> getOverdueTasks();

  /// Get tasks due soon (within X days)
  Future<Either<Failure, List<TaskSummary>>> getTasksDueSoon({int days = 7});

  /// Bulk update task status
  Future<Either<Failure, void>> bulkUpdateStatus(List<String> taskIds, TaskStatus status);
}
