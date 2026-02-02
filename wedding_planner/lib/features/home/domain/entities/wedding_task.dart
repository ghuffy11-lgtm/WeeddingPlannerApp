import 'package:equatable/equatable.dart';

/// Task Priority
enum TaskPriority { low, medium, high }

/// Task Status
enum TaskStatus { pending, inProgress, completed, cancelled }

/// Wedding Task Entity
class WeddingTask extends Equatable {
  final String id;
  final String weddingId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? category;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? completedAt;

  const WeddingTask({
    required this.id,
    required this.weddingId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category,
    this.assignedTo,
    required this.createdAt,
    this.completedAt,
  });

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Check if task is completed
  bool get isCompleted => status == TaskStatus.completed;

  @override
  List<Object?> get props => [
        id,
        weddingId,
        title,
        description,
        dueDate,
        priority,
        status,
        category,
        assignedTo,
        createdAt,
        completedAt,
      ];
}
