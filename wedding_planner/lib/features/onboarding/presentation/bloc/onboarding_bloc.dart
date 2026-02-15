import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../domain/entities/onboarding_data.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// Onboarding BLoC
/// Manages the couple onboarding flow state
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final HomeRepository _homeRepository;

  OnboardingBloc({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(const OnboardingState()) {
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingBackPressed>(_onBackPressed);
    on<OnboardingSkipPressed>(_onSkipPressed);
    on<OnboardingDateChanged>(_onDateChanged);
    on<OnboardingBudgetChanged>(_onBudgetChanged);
    on<OnboardingGuestCountChanged>(_onGuestCountChanged);
    on<OnboardingStyleToggled>(_onStyleToggled);
    on<OnboardingTraditionToggled>(_onTraditionToggled);
    on<OnboardingSubmitted>(_onSubmitted);
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    final currentIndex = state.stepIndex;
    if (currentIndex < OnboardingStep.values.length - 1) {
      emit(state.copyWith(
        currentStep: OnboardingStep.values[currentIndex + 1],
      ));
    }
  }

  void _onBackPressed(
    OnboardingBackPressed event,
    Emitter<OnboardingState> emit,
  ) {
    final currentIndex = state.stepIndex;
    if (currentIndex > 0) {
      emit(state.copyWith(
        currentStep: OnboardingStep.values[currentIndex - 1],
      ));
    }
  }

  void _onSkipPressed(
    OnboardingSkipPressed event,
    Emitter<OnboardingState> emit,
  ) {
    // Skip acts like next
    add(const OnboardingNextPressed());
  }

  void _onDateChanged(
    OnboardingDateChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      data: state.data.copyWith(
        weddingDate: event.date,
        hasWeddingDate: event.hasDate,
      ),
    ));
  }

  void _onBudgetChanged(
    OnboardingBudgetChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      data: state.data.copyWith(
        budget: event.budget,
        currency: event.currency,
      ),
    ));
  }

  void _onGuestCountChanged(
    OnboardingGuestCountChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(
      data: state.data.copyWith(guestCount: event.count),
    ));
  }

  void _onStyleToggled(
    OnboardingStyleToggled event,
    Emitter<OnboardingState> emit,
  ) {
    final currentStyles = List<WeddingStyle>.from(state.data.styles);
    if (currentStyles.contains(event.style)) {
      currentStyles.remove(event.style);
    } else {
      currentStyles.add(event.style);
    }
    emit(state.copyWith(
      data: state.data.copyWith(styles: currentStyles),
    ));
  }

  void _onTraditionToggled(
    OnboardingTraditionToggled event,
    Emitter<OnboardingState> emit,
  ) {
    final currentTraditions = List<CulturalTradition>.from(state.data.traditions);
    if (currentTraditions.contains(event.tradition)) {
      currentTraditions.remove(event.tradition);
    } else {
      currentTraditions.add(event.tradition);
    }
    emit(state.copyWith(
      data: state.data.copyWith(traditions: currentTraditions),
    ));
  }

  Future<void> _onSubmitted(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      // Create wedding with onboarding data
      final result = await _homeRepository.createWedding(
        weddingDate: state.data.hasWeddingDate ? state.data.weddingDate : null,
        budget: state.data.budget,
        currency: state.data.currency,
        guestCount: state.data.guestCount,
        styles: state.data.styles.map((s) => s.name).toList(),
        traditions: state.data.traditions.map((t) => t.name).toList(),
      );

      result.fold(
        (failure) {
          // Handle 409 Conflict as success - wedding already exists
          // This can happen if user refreshes page during onboarding
          // or navigates back and tries again
          if (failure is ConflictFailure) {
            emit(state.copyWith(
              currentStep: OnboardingStep.complete,
              isSubmitting: false,
              // Set flag to indicate wedding already existed
              weddingAlreadyExists: true,
            ));
          } else {
            emit(state.copyWith(
              isSubmitting: false,
              errorMessage: failure.message,
            ));
          }
        },
        (wedding) {
          emit(state.copyWith(
            currentStep: OnboardingStep.complete,
            isSubmitting: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to save preferences. Please try again.',
      ));
    }
  }
}
