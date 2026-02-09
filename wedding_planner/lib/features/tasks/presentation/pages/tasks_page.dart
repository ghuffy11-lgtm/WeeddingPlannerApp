import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/feedback/error_state.dart' show GenericErrorState;
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_widgets.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  TaskStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>()
      ..add(const LoadTasks())
      ..add(const LoadTaskStats());

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskBloc>().add(const LoadMoreTasks());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state.status == TaskStateStatus.created) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state.status == TaskStateStatus.deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task deleted'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.backgroundDark,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Tasks',
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                ),
                actions: [
                  if (state.isSelectionMode) ...[
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () =>
                          context.read<TaskBloc>().add(const SelectAllTasks()),
                      tooltip: 'Select all',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          context.read<TaskBloc>().add(const ToggleSelectionMode()),
                      tooltip: 'Cancel',
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.checklist),
                      onPressed: () =>
                          context.read<TaskBloc>().add(const ToggleSelectionMode()),
                      tooltip: 'Select tasks',
                    ),
                  ],
                  const SizedBox(width: 8),
                ],
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<TaskBloc>().add(const SearchTasks(''));
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<TaskBloc>().add(SearchTasks(value));
                      },
                    ),
                  ),
                ),
              ),

              // Stats card
              if (state.stats != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TaskStatsCard(stats: state.stats!),
                  ),
                ),

              // Status filter tabs
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      StatusFilterTab(
                        status: null,
                        label: 'All',
                        count: state.totalItems,
                        isSelected: _selectedStatus == null,
                        onTap: () {
                          setState(() => _selectedStatus = null);
                          context.read<TaskBloc>().add(const FilterByStatus(null));
                        },
                      ),
                      const SizedBox(width: 8),
                      StatusFilterTab(
                        status: TaskStatus.pending,
                        label: 'To Do',
                        count: state.pendingCount,
                        isSelected: _selectedStatus == TaskStatus.pending,
                        onTap: () {
                          setState(() => _selectedStatus = TaskStatus.pending);
                          context
                              .read<TaskBloc>()
                              .add(const FilterByStatus(TaskStatus.pending));
                        },
                      ),
                      const SizedBox(width: 8),
                      StatusFilterTab(
                        status: TaskStatus.inProgress,
                        label: 'In Progress',
                        count: state.inProgressCount,
                        isSelected: _selectedStatus == TaskStatus.inProgress,
                        onTap: () {
                          setState(() => _selectedStatus = TaskStatus.inProgress);
                          context
                              .read<TaskBloc>()
                              .add(const FilterByStatus(TaskStatus.inProgress));
                        },
                      ),
                      const SizedBox(width: 8),
                      StatusFilterTab(
                        status: TaskStatus.completed,
                        label: 'Done',
                        count: state.completedCount,
                        isSelected: _selectedStatus == TaskStatus.completed,
                        onTap: () {
                          setState(() => _selectedStatus = TaskStatus.completed);
                          context
                              .read<TaskBloc>()
                              .add(const FilterByStatus(TaskStatus.completed));
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Selection actions bar
              if (state.isSelectionMode && state.selectedCount > 0)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${state.selectedCount} selected',
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            _showBulkStatusDialog(context);
                          },
                          icon: const Icon(Icons.update, size: 18),
                          label: const Text('Status'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            _showBulkDeleteDialog(context);
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content
              if (state.status == TaskStateStatus.loading && state.tasks.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (state.hasError && state.tasks.isEmpty)
                SliverFillRemaining(
                  child: GenericErrorState(
                    message: state.errorMessage ?? 'Failed to load tasks',
                    onRetry: () => context.read<TaskBloc>().add(const LoadTasks()),
                  ),
                )
              else if (state.tasks.isEmpty)
                SliverFillRemaining(
                  child: EmptyTasksState(
                    onAddTask: () => context.push('/tasks/add'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == state.tasks.length) {
                          // Loading indicator for pagination
                          if (state.hasMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }
                          return null;
                        }

                        final task = state.tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            isSelected: state.selectedTaskIds.contains(task.id),
                            showCheckbox: state.isSelectionMode,
                            onTap: state.isSelectionMode
                                ? () => context
                                    .read<TaskBloc>()
                                    .add(ToggleTaskSelection(task.id))
                                : () => context.push('/tasks/${task.id}'),
                            onCheckboxChanged: (value) => context
                                .read<TaskBloc>()
                                .add(ToggleTaskSelection(task.id)),
                            onStatusChange: () {
                              _showStatusChangeDialog(context, task);
                            },
                          ),
                        );
                      },
                      childCount: state.tasks.length + (state.hasMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tasks/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context, TaskSummary task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Status',
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...TaskStatus.values.map((status) {
                final isSelected = task.status == status;
                return ListTile(
                  leading: Text(
                    status.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    status.displayName,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    context
                        .read<TaskBloc>()
                        .add(UpdateTaskStatus(task.id, status));
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showBulkStatusDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Status',
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...TaskStatus.values.map((status) {
                return ListTile(
                  leading: Text(
                    status.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    status.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<TaskBloc>().add(BulkUpdateStatus(status));
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showBulkDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            'Delete Tasks',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete ${context.read<TaskBloc>().state.selectedCount} tasks?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<TaskBloc>().add(const BulkDeleteTasks());
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
