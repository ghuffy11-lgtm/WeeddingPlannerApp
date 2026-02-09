import 'package:equatable/equatable.dart';

/// Task Priority
enum TaskPriority {
  low('Low', '🟢'),
  medium('Medium', '🟡'),
  high('High', '🔴');

  final String displayName;
  final String icon;

  const TaskPriority(this.displayName, this.icon);
}

/// Task Status
enum TaskStatus {
  pending('To Do', '📋'),
  inProgress('In Progress', '🔄'),
  completed('Completed', '✅'),
  cancelled('Cancelled', '❌');

  final String displayName;
  final String icon;

  const TaskStatus(this.displayName, this.icon);
}

/// Task Category - Common wedding planning categories
enum TaskCategory {
  venue('Venue', '🏛️'),
  catering('Catering', '🍽️'),
  photography('Photography', '📸'),
  music('Music & Entertainment', '🎵'),
  flowers('Flowers & Decor', '💐'),
  attire('Attire & Beauty', '👗'),
  invitations('Invitations', '✉️'),
  guests('Guest Management', '👥'),
  ceremony('Ceremony', '💒'),
  reception('Reception', '🎉'),
  honeymoon('Honeymoon', '✈️'),
  legal('Legal & Documents', '📄'),
  budget('Budget & Payments', '💰'),
  other('Other', '📦');

  final String displayName;
  final String icon;

  const TaskCategory(this.displayName, this.icon);
}

/// Task Entity
class Task extends Equatable {
  final String id;
  final String weddingId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final String? assignedTo;
  final String? notes;
  final List<String>? subtasks;
  final List<String>? completedSubtasks;
  final String? vendorId;
  final String? vendorName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.weddingId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.assignedTo,
    this.notes,
    this.subtasks,
    this.completedSubtasks,
    this.vendorId,
    this.vendorName,
    required this.createdAt,
    this.completedAt,
    this.updatedAt,
  });

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Check if task is due soon (within 3 days)
  bool get isDueSoon {
    if (dueDate == null || status == TaskStatus.completed) return false;
    final daysLeft = dueDate!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 3;
  }

  /// Days until due (negative if overdue)
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  /// Formatted due date
  String get dueDateFormatted {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final diff = dueDate!.difference(now).inDays;
    if (diff < -1) return '${-diff} days overdue';
    if (diff == -1) return 'Yesterday';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff <= 7) return 'In $diff days';
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  /// Check if task is completed
  bool get isCompleted => status == TaskStatus.completed;

  /// Subtask completion progress
  double get subtaskProgress {
    if (subtasks == null || subtasks!.isEmpty) return 0;
    final completed = completedSubtasks?.length ?? 0;
    return completed / subtasks!.length;
  }

  /// Number of subtasks completed
  String get subtaskProgressText {
    if (subtasks == null || subtasks!.isEmpty) return '';
    final completed = completedSubtasks?.length ?? 0;
    return '$completed/${subtasks!.length}';
  }

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
        notes,
        subtasks,
        completedSubtasks,
        vendorId,
        vendorName,
        createdAt,
        completedAt,
        updatedAt,
      ];
}

/// Task Summary for list view
class TaskSummary extends Equatable {
  final String id;
  final String title;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final bool hasSubtasks;
  final int subtaskCount;
  final int completedSubtaskCount;

  const TaskSummary({
    required this.id,
    required this.title,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.category,
    this.hasSubtasks = false,
    this.subtaskCount = 0,
    this.completedSubtaskCount = 0,
  });

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueSoon {
    if (dueDate == null || status == TaskStatus.completed) return false;
    final daysLeft = dueDate!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 3;
  }

  String get dueDateFormatted {
    if (dueDate == null) return '';
    final now = DateTime.now();
    final diff = dueDate!.difference(now).inDays;
    if (diff < 0) return '${-diff}d overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff <= 7) return 'In ${diff}d';
    return '${dueDate!.day}/${dueDate!.month}';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        dueDate,
        priority,
        status,
        category,
        hasSubtasks,
        subtaskCount,
        completedSubtaskCount,
      ];
}

/// Request to create/update task
class TaskRequest {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final String? assignedTo;
  final String? notes;
  final List<String>? subtasks;
  final String? vendorId;

  const TaskRequest({
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.assignedTo,
    this.notes,
    this.subtasks,
    this.vendorId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'category': category.name,
        if (assignedTo != null) 'assignedTo': assignedTo,
        if (notes != null) 'notes': notes,
        if (subtasks != null) 'subtasks': subtasks,
        if (vendorId != null) 'vendorId': vendorId,
      };
}

/// Task Statistics
class TaskStats extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final int dueSoonTasks;
  final Map<TaskCategory, int> byCategory;
  final Map<TaskPriority, int> byPriority;

  const TaskStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.overdueTasks,
    required this.dueSoonTasks,
    required this.byCategory,
    required this.byPriority,
  });

  double get completionPercentage =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  @override
  List<Object?> get props => [
        totalTasks,
        completedTasks,
        pendingTasks,
        inProgressTasks,
        overdueTasks,
        dueSoonTasks,
        byCategory,
        byPriority,
      ];
}
