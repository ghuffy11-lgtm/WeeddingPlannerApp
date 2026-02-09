import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../bloc/vendor_dashboard_bloc.dart';
import '../bloc/vendor_dashboard_event.dart';
import '../bloc/vendor_dashboard_state.dart';
import '../widgets/vendor_stat_card.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    super.initState();
    context.read<VendorDashboardBloc>().add(const LoadVendorEarnings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Earnings',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<VendorDashboardBloc>().add(const LoadVendorEarnings());
            },
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
        builder: (context, state) {
          if (state.earningsStatus == EarningsLoadStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final earnings = state.earnings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Earnings Card
                _buildTotalEarningsCard(earnings),
                const SizedBox(height: 24),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: VendorStatCard(
                        title: 'This Month',
                        value: '\$${(earnings?.thisMonthEarnings ?? 0).toStringAsFixed(0)}',
                        icon: Icons.trending_up,
                        iconColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VendorStatCard(
                        title: 'Last Month',
                        value: '\$${(earnings?.lastMonthEarnings ?? 0).toStringAsFixed(0)}',
                        icon: Icons.history,
                        iconColor: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: VendorStatCard(
                        title: 'Pending',
                        value: '\$${(earnings?.pendingEarnings ?? 0).toStringAsFixed(0)}',
                        icon: Icons.schedule,
                        iconColor: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: VendorStatCard(
                        title: 'Paid Out',
                        value: '\$${(earnings?.paidEarnings ?? 0).toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet,
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),

                // Monthly Growth
                if (earnings != null && earnings.lastMonthEarnings > 0) ...[
                  const SizedBox(height: 24),
                  _buildGrowthCard(earnings.monthlyGrowth),
                ],

                // Monthly Breakdown
                if (earnings != null && earnings.monthlyEarnings.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildMonthlyBreakdown(earnings),
                ],

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalEarningsCard(dynamic earnings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Earnings',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${(earnings?.totalEarnings ?? 0).toStringAsFixed(0)}',
            style: AppTypography.hero.copyWith(
              color: AppColors.white,
              fontSize: 36,
            ),
          ),
          if (earnings != null && earnings.pendingEarnings > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '\$${earnings.pendingEarnings.toStringAsFixed(0)} pending',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrowthCard(double growth) {
    final isPositive = growth >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Growth',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%',
                  style: AppTypography.h3.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'vs last month',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(dynamic earnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Breakdown',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...earnings.monthlyEarnings.map<Widget>((period) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.period,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${period.bookingsCount} bookings',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${period.amount.toStringAsFixed(0)}',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
