import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/feedback/error_state.dart' show GenericErrorState;
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_widgets.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTask(widget.taskId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state.status == TaskStateStatus.deleted) {
            context.pop();
          } else if (state.status == TaskStateStatus.updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == TaskStateStatus.loading &&
              state.selectedTask == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.hasError && state.selectedTask == null) {
            return GenericErrorState(
              message: state.errorMessage ?? 'Failed to load task',
              onRetry: () =>
                  context.read<TaskBloc>().add(LoadTask(widget.taskId)),
            );
          }

          final task = state.selectedTask;
          if (task == null) {
            return GenericErrorState(message: 'Task not found');
          }

          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.backgroundDark,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    onPressed: () => context.push('/tasks/edit/${task.id}'),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    onPressed: () => _showDeleteDialog(context, task),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getCategoryColor(task.category).withOpacity(0.6),
                          AppColors.backgroundDark,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  task.category.icon,
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              task.category.displayName,
                              style: AppTypography.h4.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title and status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: AppTypography.h3.copyWith(
                              color: Colors.white,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusBadge(task.status),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick info row
                    GlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            task.priority.icon,
                            task.priority.displayName,
                            'Priority',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          _buildInfoItem(
                            '📅',
                            task.dueDateFormatted,
                            'Due Date',
                            isOverdue: task.isOverdue,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          _buildInfoItem(
                            '📊',
                            '${(task.subtaskProgress * 100).toInt()}%',
                            'Progress',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status change buttons
                    Text(
                      'Update Status',
                      style: AppTypography.h4.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TaskStatus.values.map((status) {
                        final isSelected = task.status == status;
                        return GestureDetector(
                          onTap: isSelected
                              ? null
                              : () {
                                  context.read<TaskBloc>().add(
                                        UpdateTaskStatus(task.id, status),
                                      );
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _getStatusColor(status).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? _getStatusColor(status)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(status.icon),
                                const SizedBox(width: 6),
                                Text(
                                  status.displayName,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isSelected
                                        ? _getStatusColor(status)
                                        : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        child: Text(
                          task.description!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Subtasks
                    if (task.subtasks != null && task.subtasks!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtasks',
                            style: AppTypography.h4.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            task.subtaskProgressText,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        child: Column(
                          children: task.subtasks!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final subtask = entry.value;
                            final isCompleted =
                                task.completedSubtasks?.contains(subtask) ??
                                    false;
                            return SubtaskItem(
                              subtask: subtask,
                              isCompleted: isCompleted,
                              onToggle: () {
                                context.read<TaskBloc>().add(
                                      ToggleSubtask(task.id, index),
                                    );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Vendor link
                    if (task.vendorId != null) ...[
                      Text(
                        'Linked Vendor',
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        onTap: () => context.push('/vendors/${task.vendorId}'),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.store,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.vendorName ?? 'View Vendor',
                                    style: AppTypography.h4.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Tap to view vendor details',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Notes
                    if (task.notes != null && task.notes!.isNotEmpty) ...[
                      Text(
                        'Notes',
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        child: Text(
                          task.notes!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Timestamps
                    GlassCard(
                      child: Column(
                        children: [
                          _buildTimestampRow(
                            'Created',
                            _formatDateTime(task.createdAt),
                          ),
                          if (task.updatedAt != null) ...[
                            const Divider(color: Colors.white12),
                            _buildTimestampRow(
                              'Updated',
                              _formatDateTime(task.updatedAt!),
                            ),
                          ],
                          if (task.completedAt != null) ...[
                            const Divider(color: Colors.white12),
                            _buildTimestampRow(
                              'Completed',
                              _formatDateTime(task.completedAt!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(TaskStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.icon),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: AppTypography.labelMedium.copyWith(
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String icon, String value, String label,
      {bool isOverdue = false}) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: isOverdue ? Colors.red : Colors.white,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white54),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return AppColors.accent;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.venue:
        return Colors.purple;
      case TaskCategory.catering:
        return Colors.orange;
      case TaskCategory.photography:
        return Colors.blue;
      case TaskCategory.music:
        return Colors.pink;
      case TaskCategory.flowers:
        return Colors.green;
      case TaskCategory.attire:
        return Colors.indigo;
      case TaskCategory.invitations:
        return Colors.teal;
      case TaskCategory.guests:
        return Colors.cyan;
      case TaskCategory.ceremony:
        return Colors.amber;
      case TaskCategory.reception:
        return Colors.deepOrange;
      case TaskCategory.honeymoon:
        return Colors.lightBlue;
      case TaskCategory.legal:
        return Colors.blueGrey;
      case TaskCategory.budget:
        return Colors.lime;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            'Delete Task',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
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
                context.read<TaskBloc>().add(DeleteTask(task.id));
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
