import 'package:flutter/material.dart';
import 'status_badge.dart';

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final ValueChanged<bool?>? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
    this.onDelete,
  });

  bool get isCompleted => task['status'] == 'completed';

  bool get isOverdue {
    if (task['dueDate'] == null || isCompleted) return false;
    final dueDate = DateTime.tryParse(task['dueDate']);
    return dueDate != null && dueDate.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isOverdue ? Colors.red[50] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: onToggle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task['title'] ?? 'Untitled Task',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted ? Colors.grey : null,
                            ),
                          ),
                        ),
                        if (task['priority'] != null)
                          StatusBadge.priority(task['priority']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (task['category'] != null) ...[
                          Icon(Icons.folder_outlined,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            task['category'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (task['dueDate'] != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task['dueDate']),
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                              fontWeight:
                                  isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day}/${date.month}/${date.year}';
  }
}
