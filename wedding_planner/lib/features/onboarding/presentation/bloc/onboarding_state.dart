import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_data.dart';

/// Onboarding Step
enum OnboardingStep {
  weddingDate,
  budget,
  guestCount,
  styles,
  traditions,
  complete,
}

/// Onboarding State
class OnboardingState extends Equatable {
  final OnboardingStep currentStep;
  final OnboardingData data;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = OnboardingStep.weddingDate,
    this.data = const OnboardingData(),
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Get step index (0-based)
  int get stepIndex => OnboardingStep.values.indexOf(currentStep);

  /// Total steps (excluding complete)
  int get totalSteps => OnboardingStep.values.length - 1;

  /// Progress percentage (0.0 - 1.0)
  double get progress => (stepIndex + 1) / totalSteps;

  /// Check if on first step
  bool get isFirstStep => currentStep == OnboardingStep.weddingDate;

  /// Check if on last step before completion
  bool get isLastStep => currentStep == OnboardingStep.traditions;

  /// Check if complete
  bool get isComplete => currentStep == OnboardingStep.complete;

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    OnboardingData? data,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [currentStep, data, isSubmitting, errorMessage];
}
