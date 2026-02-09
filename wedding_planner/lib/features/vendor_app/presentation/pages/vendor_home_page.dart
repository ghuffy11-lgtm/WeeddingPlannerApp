import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../config/routes.dart';
import '../bloc/vendor_dashboard_bloc.dart';
import '../bloc/vendor_dashboard_event.dart';
import '../bloc/vendor_dashboard_state.dart';
import '../bloc/vendor_bookings_bloc.dart';
import '../bloc/vendor_bookings_event.dart';
import '../bloc/vendor_bookings_state.dart';
import '../widgets/vendor_stat_card.dart';
import '../widgets/booking_request_card.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<VendorDashboardBloc>().add(const LoadVendorDashboard());
    context.read<VendorBookingsBloc>().add(const LoadBookingRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEarningsCard(),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildRequestsSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.vendorBookingRequests),
          icon: Badge(
            isLabelVisible: true,
            label: BlocBuilder<VendorBookingsBloc, VendorBookingsState>(
              builder: (context, state) {
                final count = state.requests.length;
                if (count == 0) return const SizedBox.shrink();
                return Text(count > 9 ? '9+' : count.toString());
              },
            ),
            child: const Icon(Icons.notifications_outlined),
          ),
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEarningsCard() {
    return BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
      builder: (context, state) {
        final dashboard = state.dashboard;

        return VendorLargeStatCard(
          title: 'Total Earnings',
          value: dashboard?.totalEarningsFormatted ?? '\$0',
          subtitle: dashboard != null && dashboard.pendingEarnings > 0
              ? '${dashboard.pendingEarningsFormatted} pending'
              : null,
          icon: Icons.account_balance_wallet,
          onTap: () => context.push(AppRoutes.vendorEarnings),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
      builder: (context, state) {
        if (state.dashboardStatus == DashboardLoadStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final dashboard = state.dashboard;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: VendorStatCard(
                    title: 'Pending',
                    value: '${dashboard?.pendingBookings ?? 0}',
                    icon: Icons.schedule,
                    iconColor: AppColors.warning,
                    onTap: () => context.push(AppRoutes.vendorBookingRequests),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VendorStatCard(
                    title: 'Completed',
                    value: '${dashboard?.completedBookings ?? 0}',
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                    onTap: () => context.push(AppRoutes.vendorBookings),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: VendorStatCard(
                    title: 'Rating',
                    value: dashboard?.ratingFormatted ?? '0.0',
                    icon: Icons.star,
                    iconColor: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VendorStatCard(
                    title: 'Reviews',
                    value: '${dashboard?.reviewCount ?? 0}',
                    icon: Icons.rate_review,
                    iconColor: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Booking Requests',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.vendorBookingRequests),
              child: Text(
                'See All',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocConsumer<VendorBookingsBloc, VendorBookingsState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus,
          listener: (context, state) {
            if (state.actionStatus == BookingActionStatus.success &&
                state.actionSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccessMessage!),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<VendorBookingsBloc>().add(const ClearBookingAction());
              // Refresh dashboard
              context.read<VendorDashboardBloc>().add(const RefreshVendorDashboard());
            } else if (state.actionStatus == BookingActionStatus.error &&
                state.actionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionError!),
                  backgroundColor: Colors.red,
                ),
              );
              context.read<VendorBookingsBloc>().add(const ClearBookingAction());
            }
          },
          builder: (context, state) {
            if (state.requestsStatus == BookingListStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (state.requests.isEmpty) {
              return _buildEmptyRequests();
            }

            return Column(
              children: state.requests.take(3).map((booking) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BookingRequestCard(
                    booking: booking,
                    onTap: () => context.push('/vendor/bookings/${booking.id}'),
                    onAccept: () {
                      context.read<VendorBookingsBloc>().add(
                            AcceptBooking(bookingId: booking.id),
                          );
                    },
                    onDecline: () {
                      _showDeclineDialog(booking.id);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyRequests() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No pending requests',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New booking requests will appear here',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(String bookingId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Decline Booking',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason for declining this booking:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                context.read<VendorBookingsBloc>().add(
                      DeclineBooking(bookingId: bookingId, reason: reason),
                    );
                Navigator.pop(ctx);
              }
            },
            child: Text(
              'Decline',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
