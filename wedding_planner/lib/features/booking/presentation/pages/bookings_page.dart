import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_card.dart';

/// My Bookings page showing all user's bookings
/// Dark theme with glassmorphism design
class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  BookingStatus? _selectedFilter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    context.read<BookingBloc>().add(LoadBookings(statusFilter: _selectedFilter));
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BookingBloc>().add(const LoadMoreBookings());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onFilterChanged(BookingStatus? status) {
    setState(() {
      _selectedFilter = status;
    });
    context.read<BookingBloc>().add(LoadBookings(statusFilter: status));
  }

  void _onBookingTap(BookingSummary booking) {
    context.push('/bookings/${booking.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background glows
          const BackgroundGlow(
            color: AppColors.primary,
            alignment: Alignment(-0.8, -0.5),
            size: 350,
          ),
          const BackgroundGlow(
            color: AppColors.accentPurple,
            alignment: Alignment(0.9, 0.6),
            size: 300,
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Text(
                        'My Bookings',
                        style: AppTypography.hero.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                  child: Row(
                    children: [
                      _buildFilterChip(null, 'All'),
                      const SizedBox(width: AppSpacing.small),
                      _buildFilterChip(BookingStatus.pending, 'Pending'),
                      const SizedBox(width: AppSpacing.small),
                      _buildFilterChip(BookingStatus.accepted, 'Accepted'),
                      const SizedBox(width: AppSpacing.small),
                      _buildFilterChip(BookingStatus.completed, 'Completed'),
                      const SizedBox(width: AppSpacing.small),
                      _buildFilterChip(BookingStatus.cancelled, 'Cancelled'),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.medium),

                // Bookings list
                Expanded(
                  child: BlocConsumer<BookingBloc, BookingState>(
                    listener: (context, state) {
                      if (state.actionStatus == BookingActionStatus.success &&
                          state.actionSuccess != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.actionSuccess!),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        context.read<BookingBloc>().add(const ClearBookingSuccess());
                      }
                    },
                    builder: (context, state) {
                      if (state.listStatus == BookingListStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (state.listStatus == BookingListStatus.error) {
                        return _buildErrorState(state.listError);
                      }

                      if (state.bookings.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<BookingBloc>().add(const RefreshBookings());
                        },
                        color: AppColors.primary,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          itemCount: state.bookings.length +
                              (state.listStatus == BookingListStatus.loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.medium),
                          itemBuilder: (context, index) {
                            if (index >= state.bookings.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.medium),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }

                            final booking = state.bookings[index];
                            return BookingCard(
                              booking: booking,
                              onTap: () => _onBookingTap(booking),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BookingStatus? status, String label) {
    final isSelected = _selectedFilter == status;

    return GestureDetector(
      onTap: () => _onFilterChanged(status),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.small,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.glassBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.glassBorder,
              ),
            ),
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Failed to load bookings',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              error ?? 'An error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            GlassButton(
              onTap: _loadBookings,
              isPrimary: true,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.accentPurple.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              'No bookings yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Browse vendors and book services\nfor your special day',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            GlassButton(
              onTap: () => context.go('/vendors'),
              isPrimary: true,
              child: const Text(
                'Browse Vendors',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
