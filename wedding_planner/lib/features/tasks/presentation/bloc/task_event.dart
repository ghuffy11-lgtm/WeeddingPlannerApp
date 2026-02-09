import 'package:equatable/equatable.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Load tasks with filter
class LoadTasks extends TaskEvent {
  final TaskFilter filter;

  const LoadTasks({this.filter = const TaskFilter()});

  @override
  List<Object?> get props => [filter];
}

/// Load more tasks (pagination)
class LoadMoreTasks extends TaskEvent {
  const LoadMoreTasks();
}

/// Load single task
class LoadTask extends TaskEvent {
  final String id;

  const LoadTask(this.id);

  @override
  List<Object?> get props => [id];
}

/// Create new task
class CreateTask extends TaskEvent {
  final TaskRequest request;

  const CreateTask(this.request);

  @override
  List<Object?> get props => [request];
}

/// Update task
class UpdateTask extends TaskEvent {
  final String id;
  final TaskRequest request;

  const UpdateTask(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}

/// Delete task
class DeleteTask extends TaskEvent {
  final String id;

  const DeleteTask(this.id);

  @override
  List<Object?> get props => [id];
}

/// Update task status
class UpdateTaskStatus extends TaskEvent {
  final String id;
  final TaskStatus status;

  const UpdateTaskStatus(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

/// Toggle subtask completion
class ToggleSubtask extends TaskEvent {
  final String taskId;
  final int subtaskIndex;

  const ToggleSubtask(this.taskId, this.subtaskIndex);

  @override
  List<Object?> get props => [taskId, subtaskIndex];
}

/// Load task stats
class LoadTaskStats extends TaskEvent {
  const LoadTaskStats();
}

/// Apply filter
class ApplyFilter extends TaskEvent {
  final TaskFilter filter;

  const ApplyFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Clear filter
class ClearFilter extends TaskEvent {
  const ClearFilter();
}

/// Search tasks
class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by status
class FilterByStatus extends TaskEvent {
  final TaskStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter by category
class FilterByCategory extends TaskEvent {
  final TaskCategory? category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filter by priority
class FilterByPriority extends TaskEvent {
  final TaskPriority? priority;

  const FilterByPriority(this.priority);

  @override
  List<Object?> get props => [priority];
}

/// Toggle selection mode
class ToggleSelectionMode extends TaskEvent {
  const ToggleSelectionMode();
}

/// Toggle task selection
class ToggleTaskSelection extends TaskEvent {
  final String taskId;

  const ToggleTaskSelection(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Select all tasks
class SelectAllTasks extends TaskEvent {
  const SelectAllTasks();
}

/// Clear selection
class ClearSelection extends TaskEvent {
  const ClearSelection();
}

/// Bulk update status
class BulkUpdateStatus extends TaskEvent {
  final TaskStatus status;

  const BulkUpdateStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Bulk delete tasks
class BulkDeleteTasks extends TaskEvent {
  const BulkDeleteTasks();
}
