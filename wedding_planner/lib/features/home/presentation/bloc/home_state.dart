import 'package:equatable/equatable.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/budget_item.dart';
import '../../domain/entities/wedding.dart';
import '../../domain/entities/wedding_task.dart';
import '../../domain/repositories/home_repository.dart';

/// Home Status
enum HomeStatus { initial, loading, loaded, error }

/// Home State
class HomeState extends Equatable {
  final HomeStatus status;
  final Wedding? wedding;
  final List<WeddingTask> upcomingTasks;
  final List<BudgetCategorySummary> budgetSummary;
  final List<Booking> recentBookings;
  final TaskStats? taskStats;
  final String? errorMessage;
  final bool isRefreshing;

  const HomeState({
    this.status = HomeStatus.initial,
    this.wedding,
    this.upcomingTasks = const [],
    this.budgetSummary = const [],
    this.recentBookings = const [],
    this.taskStats,
    this.errorMessage,
    this.isRefreshing = false,
  });

  /// Initial state
  factory HomeState.initial() => const HomeState();

  /// Loading state
  HomeState loading() => copyWith(status: HomeStatus.loading);

  /// Loaded state
  HomeState loaded() => copyWith(status: HomeStatus.loaded, isRefreshing: false);

  /// Error state
  HomeState error(String message) => copyWith(
        status: HomeStatus.error,
        errorMessage: message,
        isRefreshing: false,
      );

  /// Is loading
  bool get isLoading => status == HomeStatus.loading;

  /// Is loaded
  bool get isLoaded => status == HomeStatus.loaded;

  /// Has error
  bool get hasError => status == HomeStatus.error;

  /// Has wedding
  bool get hasWedding => wedding != null;

  /// Days until wedding
  int? get daysUntilWedding => wedding?.daysUntilWedding;

  /// Total budget
  double get totalBudget => wedding?.totalBudget ?? 0;

  /// Spent amount
  double get spentAmount => wedding?.spentAmount ?? 0;

  /// Budget remaining
  double get budgetRemaining => wedding?.budgetRemaining ?? 0;

  /// Pending bookings count
  int get pendingBookingsCount =>
      recentBookings.where((b) => b.isPending).length;

  /// Confirmed bookings count
  int get confirmedBookingsCount =>
      recentBookings.where((b) => b.isConfirmed).length;

  /// Copy with
  HomeState copyWith({
    HomeStatus? status,
    Wedding? wedding,
    List<WeddingTask>? upcomingTasks,
    List<BudgetCategorySummary>? budgetSummary,
    List<Booking>? recentBookings,
    TaskStats? taskStats,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return HomeState(
      status: status ?? this.status,
      wedding: wedding ?? this.wedding,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      budgetSummary: budgetSummary ?? this.budgetSummary,
      recentBookings: recentBookings ?? this.recentBookings,
      taskStats: taskStats ?? this.taskStats,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        wedding,
        upcomingTasks,
        budgetSummary,
        recentBookings,
        taskStats,
        errorMessage,
        isRefreshing,
      ];
}
