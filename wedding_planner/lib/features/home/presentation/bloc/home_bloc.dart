import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/budget_item.dart';
import '../../domain/entities/wedding.dart';
import '../../domain/entities/wedding_task.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Home BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeState.initial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeTaskCompleted>(_onTaskCompleted);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.loading());

    // Load all data in parallel
    final results = await Future.wait([
      homeRepository.getWedding(),
      homeRepository.getUpcomingTasks(),
      homeRepository.getBudgetSummary(),
      homeRepository.getRecentBookings(),
      homeRepository.getTaskStats(),
    ]);

    final weddingResult = results[0];
    final tasksResult = results[1];
    final budgetResult = results[2];
    final bookingsResult = results[3];
    final statsResult = results[4];

    // Check for errors
    String? errorMessage;

    final wedding = weddingResult.fold(
      (failure) {
        errorMessage = failure.message;
        return null;
      },
      (data) => data as Wedding?,
    );

    final tasks = tasksResult.fold(
      (failure) => <WeddingTask>[],
      (data) => data as List<WeddingTask>,
    );

    final budget = budgetResult.fold(
      (failure) => <BudgetCategorySummary>[],
      (data) => data as List<BudgetCategorySummary>,
    );

    final bookings = bookingsResult.fold(
      (failure) => <Booking>[],
      (data) => data as List<Booking>,
    );

    final stats = statsResult.fold(
      (failure) => null,
      (data) => data as TaskStats?,
    );

    if (errorMessage != null && wedding == null) {
      emit(state.error(errorMessage!));
    } else {
      emit(state.copyWith(
        status: HomeStatus.loaded,
        wedding: wedding,
        upcomingTasks: tasks,
        budgetSummary: budget,
        recentBookings: bookings,
        taskStats: stats,
      ));
    }
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));

    // Reload all data
    final results = await Future.wait([
      homeRepository.getWedding(),
      homeRepository.getUpcomingTasks(),
      homeRepository.getBudgetSummary(),
      homeRepository.getRecentBookings(),
      homeRepository.getTaskStats(),
    ]);

    final wedding = results[0].fold(
      (f) => state.wedding,
      (d) => d as Wedding?,
    );
    final tasks = results[1].fold(
      (f) => state.upcomingTasks,
      (d) => d as List<WeddingTask>,
    );
    final budget = results[2].fold(
      (f) => state.budgetSummary,
      (d) => d as List<BudgetCategorySummary>,
    );
    final bookings = results[3].fold(
      (f) => state.recentBookings,
      (d) => d as List<Booking>,
    );
    final stats = results[4].fold(
      (f) => state.taskStats,
      (d) => d as TaskStats?,
    );

    emit(state.copyWith(
      status: HomeStatus.loaded,
      wedding: wedding,
      upcomingTasks: tasks,
      budgetSummary: budget,
      recentBookings: bookings,
      taskStats: stats,
      isRefreshing: false,
    ));
  }

  Future<void> _onTaskCompleted(
    HomeTaskCompleted event,
    Emitter<HomeState> emit,
  ) async {
    final result = await homeRepository.completeTask(event.taskId);

    result.fold(
      (failure) {
        // Could emit an error or show snackbar
      },
      (completedTask) {
        // Remove the completed task from upcoming tasks
        final updatedTasks = state.upcomingTasks
            .where((task) => task.id != event.taskId)
            .toList();

        // Update task stats
        final currentStats = state.taskStats;
        final updatedStats = currentStats != null
            ? TaskStats(
                total: currentStats.total,
                completed: currentStats.completed + 1,
                pending: currentStats.pending - 1,
                overdue: completedTask.isOverdue
                    ? currentStats.overdue - 1
                    : currentStats.overdue,
              )
            : null;

        emit(state.copyWith(
          upcomingTasks: updatedTasks,
          taskStats: updatedStats,
        ));
      },
    );
  }
}
