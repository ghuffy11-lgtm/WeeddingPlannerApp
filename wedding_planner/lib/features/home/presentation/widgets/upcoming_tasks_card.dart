import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/wedding_task.dart';
import '../../domain/repositories/home_repository.dart';

/// Upcoming Tasks Card Widget
/// Shows list of upcoming tasks with completion option
class UpcomingTasksCard extends StatelessWidget {
  final List<WeddingTask> tasks;
  final TaskStats? stats;
  final Function(String taskId)? onTaskComplete;
  final VoidCallback? onViewAll;

  const UpcomingTasksCard({
    super.key,
    required this.tasks,
    this.stats,
    this.onTaskComplete,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusMedium,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Tasks',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  if (stats != null) ...[
                    const SizedBox(width: AppSpacing.small),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.small,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.roseGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${stats!.completed}/${stats!.total}',
                        style: AppTypography.tiny.copyWith(
                          color: AppColors.roseGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.roseGold,
                    ),
                  ),
                ),
            ],
          ),

          // Progress bar
          if (stats != null && stats!.total > 0) ...[
            const SizedBox(height: AppSpacing.small),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stats!.completionPercentage / 100,
                backgroundColor: AppColors.blushRose,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.roseGold,
                ),
                minHeight: 6,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.base),

          // Task list
          if (tasks.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppColors.success.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      'All caught up!',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.warmGray,
                      ),
                    ),
                    Text(
                      'No pending tasks',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...tasks.take(5).map((task) => _TaskItem(
                  task: task,
                  onComplete: onTaskComplete != null
                      ? () => onTaskComplete!(task.id)
                      : null,
                )),
          ],

          // Overdue warning
          if (stats != null && stats!.overdue > 0) ...[
            const SizedBox(height: AppSpacing.small),
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSmall,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    '${stats!.overdue} overdue ${stats!.overdue == 1 ? 'task' : 'tasks'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final WeddingTask task;
  final VoidCallback? onComplete;

  const _TaskItem({
    required this.task,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: onComplete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isOverdue ? AppColors.error : AppColors.roseGold,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: task.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.roseGold,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.small),

          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.deepCharcoal,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.dueDate != null)
                  Text(
                    _formatDueDate(task.dueDate!, task.daysUntilDue),
                    style: AppTypography.tiny.copyWith(
                      color: isOverdue ? AppColors.error : AppColors.warmGray,
                    ),
                  ),
              ],
            ),
          ),

          // Priority indicator
          _PriorityBadge(priority: task.priority),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime date, int? daysUntilDue) {
    if (daysUntilDue == null) return '';
    if (daysUntilDue == 0) return 'Due today';
    if (daysUntilDue == 1) return 'Due tomorrow';
    if (daysUntilDue < 0) return '${daysUntilDue.abs()} days overdue';
    if (daysUntilDue <= 7) return 'Due in $daysUntilDue days';
    return 'Due ${date.month}/${date.day}';
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = AppColors.error;
        break;
      case TaskPriority.medium:
        color = AppColors.warning;
        break;
      case TaskPriority.low:
        color = AppColors.success;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
