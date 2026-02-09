import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc({required this.repository}) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadMoreTasks>(_onLoadMoreTasks);
    on<LoadTask>(_onLoadTask);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<ToggleSubtask>(_onToggleSubtask);
    on<LoadTaskStats>(_onLoadTaskStats);
    on<ApplyFilter>(_onApplyFilter);
    on<ClearFilter>(_onClearFilter);
    on<SearchTasks>(_onSearchTasks);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByCategory>(_onFilterByCategory);
    on<FilterByPriority>(_onFilterByPriority);
    on<ToggleSelectionMode>(_onToggleSelectionMode);
    on<ToggleTaskSelection>(_onToggleTaskSelection);
    on<SelectAllTasks>(_onSelectAllTasks);
    on<ClearSelection>(_onClearSelection);
    on<BulkUpdateStatus>(_onBulkUpdateStatus);
    on<BulkDeleteTasks>(_onBulkDeleteTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(
      status: TaskStateStatus.loading,
      filter: event.filter,
      clearError: true,
    ));

    final result = await repository.getTasks(event.filter);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final paginatedTasks = result.fold((_) => throw Error(), (r) => r);
      emit(state.copyWith(
        status: TaskStateStatus.loaded,
        tasks: paginatedTasks.tasks,
        currentPage: paginatedTasks.currentPage,
        totalPages: paginatedTasks.totalPages,
        totalItems: paginatedTasks.totalItems,
        hasMore: paginatedTasks.hasMore,
      ));
    }
  }

  Future<void> _onLoadMoreTasks(LoadMoreTasks event, Emitter<TaskState> emit) async {
    if (!state.hasMore || state.status == TaskStateStatus.loadingMore) return;

    emit(state.copyWith(status: TaskStateStatus.loadingMore));

    final nextFilter = state.filter.copyWith(page: state.currentPage + 1);
    final result = await repository.getTasks(nextFilter);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.loaded,
        errorMessage: failure.message,
      ));
    } else {
      final paginatedTasks = result.fold((_) => throw Error(), (r) => r);
      emit(state.copyWith(
        status: TaskStateStatus.loaded,
        tasks: [...state.tasks, ...paginatedTasks.tasks],
        currentPage: paginatedTasks.currentPage,
        totalPages: paginatedTasks.totalPages,
        totalItems: paginatedTasks.totalItems,
        hasMore: paginatedTasks.hasMore,
        filter: nextFilter,
      ));
    }
  }

  Future<void> _onLoadTask(LoadTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStateStatus.loading, clearError: true));

    final result = await repository.getTask(event.id);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final task = result.fold((_) => throw Error(), (r) => r);
      emit(state.copyWith(
        status: TaskStateStatus.loaded,
        selectedTask: task,
      ));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStateStatus.creating, clearError: true));

    final result = await repository.createTask(event.request);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final task = result.fold((_) => throw Error(), (r) => r);
      final summary = TaskSummary(
        id: task.id,
        title: task.title,
        dueDate: task.dueDate,
        priority: task.priority,
        status: task.status,
        category: task.category,
        hasSubtasks: task.subtasks?.isNotEmpty ?? false,
        subtaskCount: task.subtasks?.length ?? 0,
        completedSubtaskCount: task.completedSubtasks?.length ?? 0,
      );
      emit(state.copyWith(
        status: TaskStateStatus.created,
        tasks: [summary, ...state.tasks],
        totalItems: state.totalItems + 1,
      ));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStateStatus.updating, clearError: true));

    final result = await repository.updateTask(event.id, event.request);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final task = result.fold((_) => throw Error(), (r) => r);
      final updatedTasks = state.tasks.map((t) {
        if (t.id == task.id) {
          return TaskSummary(
            id: task.id,
            title: task.title,
            dueDate: task.dueDate,
            priority: task.priority,
            status: task.status,
            category: task.category,
            hasSubtasks: task.subtasks?.isNotEmpty ?? false,
            subtaskCount: task.subtasks?.length ?? 0,
            completedSubtaskCount: task.completedSubtasks?.length ?? 0,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(
        status: TaskStateStatus.updated,
        tasks: updatedTasks,
        selectedTask: task,
      ));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStateStatus.deleting, clearError: true));

    final result = await repository.deleteTask(event.id);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final updatedTasks = state.tasks.where((t) => t.id != event.id).toList();
      emit(state.copyWith(
        status: TaskStateStatus.deleted,
        tasks: updatedTasks,
        totalItems: state.totalItems - 1,
        clearSelectedTask: true,
      ));
    }
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStateStatus.updating, clearError: true));

    final result = await repository.updateTaskStatus(event.id, event.status);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final task = result.fold((_) => throw Error(), (r) => r);
      final updatedTasks = state.tasks.map((t) {
        if (t.id == task.id) {
          return TaskSummary(
            id: task.id,
            title: task.title,
            dueDate: task.dueDate,
            priority: task.priority,
            status: task.status,
            category: task.category,
            hasSubtasks: task.subtasks?.isNotEmpty ?? false,
            subtaskCount: task.subtasks?.length ?? 0,
            completedSubtaskCount: task.completedSubtasks?.length ?? 0,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(
        status: TaskStateStatus.updated,
        tasks: updatedTasks,
        selectedTask: task,
      ));
    }
  }

  Future<void> _onToggleSubtask(ToggleSubtask event, Emitter<TaskState> emit) async {
    final result = await repository.toggleSubtask(event.taskId, event.subtaskIndex);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final task = result.fold((_) => throw Error(), (r) => r);
      final updatedTasks = state.tasks.map((t) {
        if (t.id == task.id) {
          return TaskSummary(
            id: task.id,
            title: task.title,
            dueDate: task.dueDate,
            priority: task.priority,
            status: task.status,
            category: task.category,
            hasSubtasks: task.subtasks?.isNotEmpty ?? false,
            subtaskCount: task.subtasks?.length ?? 0,
            completedSubtaskCount: task.completedSubtasks?.length ?? 0,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(
        status: TaskStateStatus.loaded,
        tasks: updatedTasks,
        selectedTask: task,
      ));
    }
  }

  Future<void> _onLoadTaskStats(LoadTaskStats event, Emitter<TaskState> emit) async {
    final result = await repository.getTaskStats();

    if (result.isRight()) {
      final stats = result.fold((_) => throw Error(), (r) => r);
      emit(state.copyWith(stats: stats));
    }
  }

  void _onApplyFilter(ApplyFilter event, Emitter<TaskState> emit) {
    add(LoadTasks(filter: event.filter));
  }

  void _onClearFilter(ClearFilter event, Emitter<TaskState> emit) {
    add(const LoadTasks(filter: TaskFilter()));
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    final newFilter = state.filter.copyWith(
      searchQuery: event.query.isEmpty ? null : event.query,
      page: 1,
    );
    add(LoadTasks(filter: newFilter));
  }

  void _onFilterByStatus(FilterByStatus event, Emitter<TaskState> emit) {
    final newFilter = state.filter.copyWith(
      status: event.status,
      page: 1,
    );
    add(LoadTasks(filter: newFilter));
  }

  void _onFilterByCategory(FilterByCategory event, Emitter<TaskState> emit) {
    final newFilter = state.filter.copyWith(
      category: event.category,
      page: 1,
    );
    add(LoadTasks(filter: newFilter));
  }

  void _onFilterByPriority(FilterByPriority event, Emitter<TaskState> emit) {
    final newFilter = state.filter.copyWith(
      priority: event.priority,
      page: 1,
    );
    add(LoadTasks(filter: newFilter));
  }

  void _onToggleSelectionMode(ToggleSelectionMode event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedTaskIds: {},
    ));
  }

  void _onToggleTaskSelection(ToggleTaskSelection event, Emitter<TaskState> emit) {
    final newSelection = Set<String>.from(state.selectedTaskIds);
    if (newSelection.contains(event.taskId)) {
      newSelection.remove(event.taskId);
    } else {
      newSelection.add(event.taskId);
    }
    emit(state.copyWith(selectedTaskIds: newSelection));
  }

  void _onSelectAllTasks(SelectAllTasks event, Emitter<TaskState> emit) {
    final allIds = state.tasks.map((t) => t.id).toSet();
    emit(state.copyWith(selectedTaskIds: allIds));
  }

  void _onClearSelection(ClearSelection event, Emitter<TaskState> emit) {
    emit(state.copyWith(selectedTaskIds: {}));
  }

  Future<void> _onBulkUpdateStatus(
    BulkUpdateStatus event,
    Emitter<TaskState> emit,
  ) async {
    if (state.selectedTaskIds.isEmpty) return;

    emit(state.copyWith(status: TaskStateStatus.updating, clearError: true));

    final result = await repository.bulkUpdateStatus(
      state.selectedTaskIds.toList(),
      event.status,
    );

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw Error());
      emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.message,
      ));
    } else {
      final updatedTasks = state.tasks.map((t) {
        if (state.selectedTaskIds.contains(t.id)) {
          return TaskSummary(
            id: t.id,
            title: t.title,
            dueDate: t.dueDate,
            priority: t.priority,
            status: event.status,
            category: t.category,
            hasSubtasks: t.hasSubtasks,
            subtaskCount: t.subtaskCount,
            completedSubtaskCount: t.completedSubtaskCount,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(
        status: TaskStateStatus.updated,
        tasks: updatedTasks,
        isSelectionMode: false,
        selectedTaskIds: {},
      ));
    }
  }

  Future<void> _onBulkDeleteTasks(
    BulkDeleteTasks event,
    Emitter<TaskState> emit,
  ) async {
    if (state.selectedTaskIds.isEmpty) return;

    emit(state.copyWith(status: TaskStateStatus.deleting, clearError: true));

    // Delete one by one (API might not support bulk delete)
    for (final id in state.selectedTaskIds) {
      await repository.deleteTask(id);
    }

    final updatedTasks = state.tasks
        .where((t) => !state.selectedTaskIds.contains(t.id))
        .toList();

    emit(state.copyWith(
      status: TaskStateStatus.deleted,
      tasks: updatedTasks,
      totalItems: state.totalItems - state.selectedTaskIds.length,
      isSelectionMode: false,
      selectedTaskIds: {},
    ));
  }
}
