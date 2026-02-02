import 'package:equatable/equatable.dart';

/// Home Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load all home data
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

/// Refresh home data
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Complete a task
class HomeTaskCompleted extends HomeEvent {
  final String taskId;

  const HomeTaskCompleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Update wedding details
class HomeWeddingUpdated extends HomeEvent {
  final DateTime? weddingDate;
  final String? partnerOneName;
  final String? partnerTwoName;

  const HomeWeddingUpdated({
    this.weddingDate,
    this.partnerOneName,
    this.partnerTwoName,
  });

  @override
  List<Object?> get props => [weddingDate, partnerOneName, partnerTwoName];
}
