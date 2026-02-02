import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_data.dart';

/// Base class for Onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Go to next step
class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

/// Go to previous step
class OnboardingBackPressed extends OnboardingEvent {
  const OnboardingBackPressed();
}

/// Skip current step
class OnboardingSkipPressed extends OnboardingEvent {
  const OnboardingSkipPressed();
}

/// Set wedding date
class OnboardingDateChanged extends OnboardingEvent {
  final DateTime? date;
  final bool hasDate;

  const OnboardingDateChanged({this.date, this.hasDate = true});

  @override
  List<Object?> get props => [date, hasDate];
}

/// Set budget
class OnboardingBudgetChanged extends OnboardingEvent {
  final double budget;
  final String currency;

  const OnboardingBudgetChanged({required this.budget, required this.currency});

  @override
  List<Object?> get props => [budget, currency];
}

/// Set guest count
class OnboardingGuestCountChanged extends OnboardingEvent {
  final int count;

  const OnboardingGuestCountChanged({required this.count});

  @override
  List<Object?> get props => [count];
}

/// Toggle wedding style
class OnboardingStyleToggled extends OnboardingEvent {
  final WeddingStyle style;

  const OnboardingStyleToggled({required this.style});

  @override
  List<Object?> get props => [style];
}

/// Toggle cultural tradition
class OnboardingTraditionToggled extends OnboardingEvent {
  final CulturalTradition tradition;

  const OnboardingTraditionToggled({required this.tradition});

  @override
  List<Object?> get props => [tradition];
}

/// Submit onboarding data
class OnboardingSubmitted extends OnboardingEvent {
  const OnboardingSubmitted();
}
