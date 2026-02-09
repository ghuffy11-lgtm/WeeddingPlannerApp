import '../../domain/entities/task.dart';

/// Task Model for API serialization
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.weddingId,
    required super.title,
    super.description,
    super.dueDate,
    super.priority,
    super.status,
    super.category,
    super.assignedTo,
    super.notes,
    super.subtasks,
    super.completedSubtasks,
    super.vendorId,
    super.vendorName,
    required super.createdAt,
    super.completedAt,
    super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      weddingId: (json['weddingId'] ?? json['wedding_id'] ?? '') as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : json['due_date'] != null
              ? DateTime.parse(json['due_date'] as String)
              : null,
      priority: _parsePriority(json['priority']),
      status: _parseStatus(json['status']),
      category: _parseCategory(json['category']),
      assignedTo: (json['assignedTo'] ?? json['assigned_to']) as String?,
      notes: json['notes'] as String?,
      subtasks: json['subtasks'] != null
          ? List<String>.from(json['subtasks'] as List)
          : null,
      completedSubtasks: json['completedSubtasks'] != null
          ? List<String>.from(json['completedSubtasks'] as List)
          : json['completed_subtasks'] != null
              ? List<String>.from(json['completed_subtasks'] as List)
              : null,
      vendorId: (json['vendorId'] ?? json['vendor_id']) as String?,
      vendorName: (json['vendorName'] ?? json['vendor_name']) as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : json['completed_at'] != null
              ? DateTime.parse(json['completed_at'] as String)
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'weddingId': weddingId,
        'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'category': category.name,
        if (assignedTo != null) 'assignedTo': assignedTo,
        if (notes != null) 'notes': notes,
        if (subtasks != null) 'subtasks': subtasks,
        if (completedSubtasks != null) 'completedSubtasks': completedSubtasks,
        if (vendorId != null) 'vendorId': vendorId,
        if (vendorName != null) 'vendorName': vendorName,
        'createdAt': createdAt.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  static TaskPriority _parsePriority(dynamic value) {
    if (value == null) return TaskPriority.medium;
    final str = value.toString().toLowerCase();
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => TaskPriority.medium,
    );
  }

  static TaskStatus _parseStatus(dynamic value) {
    if (value == null) return TaskStatus.pending;
    final str = value.toString().toLowerCase();
    // Handle snake_case from API
    if (str == 'in_progress') return TaskStatus.inProgress;
    return TaskStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => TaskStatus.pending,
    );
  }

  static TaskCategory _parseCategory(dynamic value) {
    if (value == null) return TaskCategory.other;
    final str = value.toString().toLowerCase();
    return TaskCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => TaskCategory.other,
    );
  }
}

/// Task Summary Model for list views
class TaskSummaryModel extends TaskSummary {
  const TaskSummaryModel({
    required super.id,
    required super.title,
    super.dueDate,
    required super.priority,
    required super.status,
    required super.category,
    super.hasSubtasks,
    super.subtaskCount,
    super.completedSubtaskCount,
  });

  factory TaskSummaryModel.fromJson(Map<String, dynamic> json) {
    final subtasks = json['subtasks'] as List?;
    final completedSubtasks =
        (json['completedSubtasks'] ?? json['completed_subtasks']) as List?;

    return TaskSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : json['due_date'] != null
              ? DateTime.parse(json['due_date'] as String)
              : null,
      priority: TaskModel._parsePriority(json['priority']),
      status: TaskModel._parseStatus(json['status']),
      category: TaskModel._parseCategory(json['category']),
      hasSubtasks: subtasks != null && subtasks.isNotEmpty,
      subtaskCount: subtasks?.length ?? 0,
      completedSubtaskCount: completedSubtasks?.length ?? 0,
    );
  }

  factory TaskSummaryModel.fromTask(Task task) {
    return TaskSummaryModel(
      id: task.id,
      title: task.title,
      dueDate: task.dueDate,
      priority: task.priority,
      status: task.status,
      category: task.category,
      hasSubtasks: task.subtasks != null && task.subtasks!.isNotEmpty,
      subtaskCount: task.subtasks?.length ?? 0,
      completedSubtaskCount: task.completedSubtasks?.length ?? 0,
    );
  }
}

/// Task Stats Model
class TaskStatsModel extends TaskStats {
  const TaskStatsModel({
    required super.totalTasks,
    required super.completedTasks,
    required super.pendingTasks,
    required super.inProgressTasks,
    required super.overdueTasks,
    required super.dueSoonTasks,
    required super.byCategory,
    required super.byPriority,
  });

  factory TaskStatsModel.fromJson(Map<String, dynamic> json) {
    // Parse category counts
    final byCategoryJson =
        (json['byCategory'] ?? json['by_category']) as Map<String, dynamic>?;
    final byCategory = <TaskCategory, int>{};
    if (byCategoryJson != null) {
      for (final entry in byCategoryJson.entries) {
        final category = TaskModel._parseCategory(entry.key);
        byCategory[category] = (entry.value as num).toInt();
      }
    }

    // Parse priority counts
    final byPriorityJson =
        (json['byPriority'] ?? json['by_priority']) as Map<String, dynamic>?;
    final byPriority = <TaskPriority, int>{};
    if (byPriorityJson != null) {
      for (final entry in byPriorityJson.entries) {
        final priority = TaskModel._parsePriority(entry.key);
        byPriority[priority] = (entry.value as num).toInt();
      }
    }

    return TaskStatsModel(
      totalTasks: ((json['totalTasks'] ?? json['total_tasks'] ?? 0) as num).toInt(),
      completedTasks:
          ((json['completedTasks'] ?? json['completed_tasks'] ?? 0) as num).toInt(),
      pendingTasks:
          ((json['pendingTasks'] ?? json['pending_tasks'] ?? 0) as num).toInt(),
      inProgressTasks:
          ((json['inProgressTasks'] ?? json['in_progress_tasks'] ?? 0) as num).toInt(),
      overdueTasks:
          ((json['overdueTasks'] ?? json['overdue_tasks'] ?? 0) as num).toInt(),
      dueSoonTasks:
          ((json['dueSoonTasks'] ?? json['due_soon_tasks'] ?? 0) as num).toInt(),
      byCategory: byCategory,
      byPriority: byPriority,
    );
  }
}
