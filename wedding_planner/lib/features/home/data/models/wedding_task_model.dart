import '../../domain/entities/wedding_task.dart';

/// Wedding Task Model for API serialization
class WeddingTaskModel extends WeddingTask {
  const WeddingTaskModel({
    required super.id,
    required super.weddingId,
    required super.title,
    super.description,
    super.dueDate,
    super.priority,
    super.status,
    super.category,
    super.assignedTo,
    required super.createdAt,
    super.completedAt,
  });

  /// Create from JSON
  factory WeddingTaskModel.fromJson(Map<String, dynamic> json) {
    return WeddingTaskModel(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      priority: _parsePriority(json['priority'] as String?),
      status: _parseStatus(json['status'] as String?),
      category: json['category'] as String?,
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wedding_id': weddingId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority.name,
      'status': _statusToString(status),
      'category': category,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  static TaskPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
      case TaskStatus.pending:
        return 'pending';
    }
  }
}
