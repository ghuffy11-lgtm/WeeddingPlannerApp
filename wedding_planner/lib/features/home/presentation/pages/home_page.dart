import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/feedback/error_state.dart' as feedback;
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/upcoming_tasks_card.dart';
import '../widgets/vendor_status_card.dart';

/// Home Page
/// Main dashboard for couples showing wedding overview
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load home data when page is first shown
    context.read<HomeBloc>().add(const HomeLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _LoadingState();
          }

          if (state.hasError && !state.hasWedding) {
            return feedback.ErrorState(
              title: 'Failed to load data',
              description: state.errorMessage,
              primaryButtonText: 'Retry',
              onPrimaryButtonTap: () {
                context.read<HomeBloc>().add(const HomeLoadRequested());
              },
            );
          }

          return RefreshIndicator(
            color: AppColors.roseGold,
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested());
              // Wait for refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  title: Text(
                    'Wedding Planner',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: AppColors.deepCharcoal,
                      onPressed: () {
                        // TODO: Navigate to notifications
                      },
                    ),
                  ],
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Countdown Card
                      CountdownCard(
                        daysUntilWedding: state.daysUntilWedding,
                        coupleNames:
                            state.wedding?.coupleDisplayName ?? 'Your Wedding',
                        weddingDate: state.wedding?.weddingDate,
                        onTap: () {
                          // TODO: Navigate to wedding settings
                        },
                      ),
                      const SizedBox(height: AppSpacing.large),

                      // Quick Actions
                      QuickActionsWidget(
                        actions: _buildQuickActions(context),
                      ),
                      const SizedBox(height: AppSpacing.large),

                      // Budget Overview
                      BudgetOverviewCard(
                        totalBudget: state.totalBudget,
                        spentAmount: state.spentAmount,
                        currency: state.wedding?.currency ?? 'USD',
                        categories: state.budgetSummary,
                        onTap: () => context.push(AppRoutes.budget),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Upcoming Tasks
                      UpcomingTasksCard(
                        tasks: state.upcomingTasks,
                        stats: state.taskStats,
                        onTaskComplete: (taskId) {
                          context.read<HomeBloc>().add(HomeTaskCompleted(taskId));
                        },
                        onViewAll: () => context.go(AppRoutes.tasks),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Vendor Status
                      VendorStatusCard(
                        bookings: state.recentBookings,
                        onViewAll: () => context.go(AppRoutes.vendors),
                        onBookingTap: (booking) {
                          context.push('/vendors/${booking.vendorId}');
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<QuickAction> _buildQuickActions(BuildContext context) {
    return [
      QuickAction(
        icon: Icons.checklist,
        label: 'Tasks',
        onTap: () => context.go(AppRoutes.tasks),
      ),
      QuickAction(
        icon: Icons.store,
        label: 'Vendors',
        onTap: () => context.go(AppRoutes.vendors),
      ),
      QuickAction(
        icon: Icons.people,
        label: 'Guests',
        onTap: () => context.push(AppRoutes.guests),
      ),
      QuickAction(
        icon: Icons.account_balance_wallet,
        label: 'Budget',
        onTap: () => context.push(AppRoutes.budget),
      ),
      QuickAction(
        icon: Icons.mail,
        label: 'Invites',
        onTap: () => context.push(AppRoutes.invitations),
      ),
      QuickAction(
        icon: Icons.table_chart,
        label: 'Seating',
        onTap: () => context.push(AppRoutes.seating),
      ),
      QuickAction(
        icon: Icons.chat,
        label: 'Chat',
        onTap: () => context.go(AppRoutes.chat),
      ),
      QuickAction(
        icon: Icons.calendar_today,
        label: 'Timeline',
        onTap: () {
          // TODO: Navigate to timeline
        },
      ),
    ];
  }
}

/// Loading State Widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Wedding Planner',
            style: AppTypography.h2.copyWith(
              color: AppColors.deepCharcoal,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.base),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Countdown skeleton
              _SkeletonBox(height: 180),
              const SizedBox(height: AppSpacing.large),

              // Quick actions skeleton
              _SkeletonBox(height: 100),
              const SizedBox(height: AppSpacing.large),

              // Budget skeleton
              _SkeletonBox(height: 150),
              const SizedBox(height: AppSpacing.base),

              // Tasks skeleton
              _SkeletonBox(height: 200),
              const SizedBox(height: AppSpacing.base),

              // Vendors skeleton
              _SkeletonBox(height: 180),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Skeleton loading placeholder
class _SkeletonBox extends StatelessWidget {
  final double height;

  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.blushRose.withValues(alpha: 0.3),
        borderRadius: AppSpacing.borderRadiusMedium,
      ),
    );
  }
}
