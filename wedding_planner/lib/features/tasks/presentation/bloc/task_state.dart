import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskStateStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  creating,
  created,
  updating,
  updated,
  deleting,
  deleted,
}

class TaskState extends Equatable {
  final TaskStateStatus status;
  final List<TaskSummary> tasks;
  final Task? selectedTask;
  final TaskStats? stats;
  final TaskFilter filter;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final String? errorMessage;
  final bool isSelectionMode;
  final Set<String> selectedTaskIds;

  const TaskState({
    this.status = TaskStateStatus.initial,
    this.tasks = const [],
    this.selectedTask,
    this.stats,
    this.filter = const TaskFilter(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = false,
    this.errorMessage,
    this.isSelectionMode = false,
    this.selectedTaskIds = const {},
  });

  /// Check if currently loading
  bool get isLoading =>
      status == TaskStateStatus.loading || status == TaskStateStatus.loadingMore;

  /// Check if there's an error
  bool get hasError => status == TaskStateStatus.error;

  /// Check if tasks are loaded
  bool get isLoaded => status == TaskStateStatus.loaded;

  /// Number of selected tasks
  int get selectedCount => selectedTaskIds.length;

  /// Check if all tasks are selected
  bool get allSelected =>
      tasks.isNotEmpty && selectedTaskIds.length == tasks.length;

  /// Get filtered task counts
  int get pendingCount =>
      tasks.where((t) => t.status == TaskStatus.pending).length;

  int get inProgressCount =>
      tasks.where((t) => t.status == TaskStatus.inProgress).length;

  int get completedCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  int get overdueCount => tasks.where((t) => t.isOverdue).length;

  TaskState copyWith({
    TaskStateStatus? status,
    List<TaskSummary>? tasks,
    Task? selectedTask,
    TaskStats? stats,
    TaskFilter? filter,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    String? errorMessage,
    bool? isSelectionMode,
    Set<String>? selectedTaskIds,
    bool clearSelectedTask = false,
    bool clearError = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      selectedTask: clearSelectedTask ? null : selectedTask ?? this.selectedTask,
      stats: stats ?? this.stats,
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        selectedTask,
        stats,
        filter,
        currentPage,
        totalPages,
        totalItems,
        hasMore,
        errorMessage,
        isSelectionMode,
        selectedTaskIds,
      ];
}
