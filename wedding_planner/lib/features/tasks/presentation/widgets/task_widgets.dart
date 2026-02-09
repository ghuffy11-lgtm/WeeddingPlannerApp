import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/task.dart';

/// Task Stats Card - Shows overall task statistics
class TaskStatsCard extends StatelessWidget {
  final TaskStats stats;

  const TaskStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task Progress',
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${stats.completionPercentage.toStringAsFixed(0)}%',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.completionPercentage / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${stats.completedTasks}',
                'Done',
                Colors.green,
              ),
              _buildStatItem(
                '${stats.inProgressTasks}',
                'In Progress',
                AppColors.accent,
              ),
              _buildStatItem(
                '${stats.pendingTasks}',
                'To Do',
                Colors.grey,
              ),
              _buildStatItem(
                '${stats.overdueTasks}',
                'Overdue',
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: AppTypography.h4.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

/// Task Card - For displaying task in list
class TaskCard extends StatelessWidget {
  final TaskSummary task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusChange;
  final bool isSelected;
  final bool showCheckbox;
  final ValueChanged<bool?>? onCheckboxChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChange,
    this.isSelected = false,
    this.showCheckbox = false,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : null,
      child: Row(
        children: [
          if (showCheckbox) ...[
            Checkbox(
              value: isSelected,
              onChanged: onCheckboxChanged,
              activeColor: AppColors.primary,
              checkColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            const SizedBox(width: 8),
          ],
          // Status indicator
          GestureDetector(
            onTap: onStatusChange,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getStatusColor(task.status),
                  width: 2,
                ),
              ),
              child: task.status == TaskStatus.completed
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: _getStatusColor(task.status),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      task.category.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.title,
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                          decoration: task.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.displayName,
                        style: AppTypography.caption.copyWith(
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Due date
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: task.isOverdue ? Colors.red : Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.dueDateFormatted,
                        style: AppTypography.bodySmall.copyWith(
                          color: task.isOverdue ? Colors.red : Colors.white54,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Subtask progress
                    if (task.hasSubtasks) ...[
                      Icon(
                        Icons.checklist,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.completedSubtaskCount}/${task.subtaskCount}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
        ],
      ),
    );
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

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}

/// Category Filter Chip
class CategoryFilterChip extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status Filter Tab
class StatusFilterTab extends StatelessWidget {
  final TaskStatus? status;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusFilterTab({
    super.key,
    required this.status,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? AppColors.primary : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTypography.caption.copyWith(
                  color: isSelected ? AppColors.primary : Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty Tasks State
class EmptyTasksState extends StatelessWidget {
  final String? message;
  final VoidCallback? onAddTask;

  const EmptyTasksState({
    super.key,
    this.message,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'No tasks yet',
              style: AppTypography.h3.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task to get started',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddTask != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Subtask Item Widget
class SubtaskItem extends StatelessWidget {
  final String subtask;
  final bool isCompleted;
  final VoidCallback? onToggle;

  const SubtaskItem({
    super.key,
    required this.subtask,
    required this.isCompleted,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.white54,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.green)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtask,
                style: AppTypography.bodyMedium.copyWith(
                  color: isCompleted ? Colors.white54 : Colors.white,
                  decoration:
                      isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
