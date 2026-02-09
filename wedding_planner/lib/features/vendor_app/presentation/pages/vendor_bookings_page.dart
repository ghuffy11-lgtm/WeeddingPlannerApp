import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../config/routes.dart';
import '../../domain/entities/vendor_booking.dart';
import '../bloc/vendor_bookings_bloc.dart';
import '../bloc/vendor_bookings_event.dart';
import '../bloc/vendor_bookings_state.dart';
import '../widgets/vendor_booking_card.dart';

class VendorBookingsPage extends StatefulWidget {
  const VendorBookingsPage({super.key});

  @override
  State<VendorBookingsPage> createState() => _VendorBookingsPageState();
}

class _VendorBookingsPageState extends State<VendorBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<VendorBookingStatus?> _statusFilters = [
    null, // All
    VendorBookingStatus.pending,
    VendorBookingStatus.accepted,
    VendorBookingStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadBookings(null);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final status = _statusFilters[_tabController.index];
      _loadBookings(status);
    }
  }

  void _loadBookings(VendorBookingStatus? status) {
    context.read<VendorBookingsBloc>().add(UpdateBookingFilter(status: status));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Bookings',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.vendorBookingRequests),
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textSecondary,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTypography.labelLarge,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocBuilder<VendorBookingsBloc, VendorBookingsState>(
        builder: (context, state) {
          if (state.bookingsStatus == BookingListStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.bookings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              final status = _statusFilters[_tabController.index];
              _loadBookings(status);
            },
            color: AppColors.primary,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 200 &&
                    state.hasMoreBookings) {
                  context.read<VendorBookingsBloc>().add(const LoadMoreBookings());
                }
                return false;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookings.length +
                    (state.bookingsStatus == BookingListStatus.loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= state.bookings.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }

                  final booking = state.bookings[index];
                  return VendorBookingCard(
                    booking: booking,
                    onTap: () => context.push('/vendor/bookings/${booking.id}'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: AppTypography.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookings will appear here',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
