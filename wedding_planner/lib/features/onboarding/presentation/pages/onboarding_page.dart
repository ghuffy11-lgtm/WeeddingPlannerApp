import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/injection.dart';
import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/budget_step.dart';
import '../widgets/celebration_step.dart';
import '../widgets/guest_count_step.dart';
import '../widgets/styles_step.dart';
import '../widgets/traditions_step.dart';
import '../widgets/wedding_date_step.dart';

/// Onboarding Page
/// Dark theme with glassmorphism design
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(homeRepository: getIt<HomeRepository>()),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        // Sync page controller with bloc state
        if (_pageController.hasClients) {
          _animateToPage(state.stepIndex);
        }

        // Navigate to home when complete
        if (state.isComplete) {
          context.go(AppRoutes.home);
        }

        // Show error if any
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Stack(
            children: [
              // Background glows
              const BackgroundGlow(
                color: AppColors.accentPurple,
                alignment: Alignment(-0.8, -0.6),
                size: 350,
              ),
              const BackgroundGlow(
                color: AppColors.primary,
                alignment: Alignment(0.9, 0.5),
                size: 300,
              ),
              const BackgroundGlow(
                color: AppColors.accent,
                alignment: Alignment(-0.5, 0.9),
                size: 250,
              ),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Progress indicator
                    _buildProgressBar(state),
                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          WeddingDateStep(),
                          BudgetStep(),
                          GuestCountStep(),
                          StylesStep(),
                          TraditionsStep(),
                          CelebrationStep(),
                        ],
                      ),
                    ),
                    // Navigation buttons
                    if (!state.isComplete) _buildNavigationButtons(context, state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(OnboardingState state) {
    if (state.isComplete) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              if (!state.isFirstStep)
                GlassIconButton(
                  icon: Icons.arrow_back,
                  onTap: () {
                    context.read<OnboardingBloc>().add(const OnboardingBackPressed());
                  },
                )
              else
                const SizedBox(width: 40),
              // Step indicator
              Text(
                'Step ${state.stepIndex + 1} of ${state.totalSteps}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              // Skip button
              TextButton(
                onPressed: () {
                  context.read<OnboardingBloc>().add(const OnboardingSkipPressed());
                },
                child: Text(
                  'Skip',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          // Progress bar with glass effect
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: constraints.maxWidth * state.progress,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, OnboardingState state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: PrimaryButton(
        text: state.isLastStep ? 'Complete' : 'Continue',
        isLoading: state.isSubmitting,
        onPressed: () {
          if (state.isLastStep) {
            context.read<OnboardingBloc>().add(const OnboardingSubmitted());
          } else {
            context.read<OnboardingBloc>().add(const OnboardingNextPressed());
          }
        },
      ),
    );
  }
}
