import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';
import '../entities/budget_item.dart';
import '../entities/wedding.dart';
import '../entities/wedding_task.dart';

/// Home Repository Interface
abstract class HomeRepository {
  /// Get current user's wedding
  Future<Either<Failure, Wedding?>> getWedding();

  /// Create a new wedding (during onboarding)
  Future<Either<Failure, Wedding>> createWedding({
    DateTime? weddingDate,
    double? budget,
    String? currency,
    int? guestCount,
    List<String>? styles,
    List<String>? traditions,
  });

  /// Get upcoming tasks (limited count)
  Future<Either<Failure, List<WeddingTask>>> getUpcomingTasks({int limit = 5});

  /// Get budget summary
  Future<Either<Failure, List<BudgetCategorySummary>>> getBudgetSummary();

  /// Get recent bookings
  Future<Either<Failure, List<Booking>>> getRecentBookings({int limit = 3});

  /// Get task statistics
  Future<Either<Failure, TaskStats>> getTaskStats();

  /// Update wedding details
  Future<Either<Failure, Wedding>> updateWedding(Wedding wedding);

  /// Mark task as complete
  Future<Either<Failure, WeddingTask>> completeTask(String taskId);
}

/// Task Statistics
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final int overdue;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  double get completionPercentage {
    if (total == 0) return 0;
    return (completed / total) * 100;
  }
}
