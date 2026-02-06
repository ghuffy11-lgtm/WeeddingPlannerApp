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

/// Booking detail page showing full booking information
class BookingDetailPage extends StatefulWidget {
  final String bookingId;

  const BookingDetailPage({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(LoadBookingDetail(widget.bookingId));
  }

  @override
  void dispose() {
    context.read<BookingBloc>().add(const ClearBookingDetail());
    super.dispose();
  }

  void _onCancelBooking() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Booking?',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'No, Keep It',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BookingBloc>().add(CancelBooking(widget.bookingId));
            },
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddReview(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReviewBottomSheet(
        bookingId: booking.id,
        vendorName: booking.vendor?.businessName ?? 'Vendor',
        onSubmit: (rating, review) {
          context.read<BookingBloc>().add(AddBookingReview(
            bookingId: booking.id,
            rating: rating,
            reviewText: review,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background glows
          const BackgroundGlow(
            color: AppColors.accentPurple,
            alignment: Alignment(-0.8, -0.3),
            size: 350,
          ),
          const BackgroundGlow(
            color: AppColors.primary,
            alignment: Alignment(0.9, 0.5),
            size: 300,
          ),

          // Content
          SafeArea(
            child: BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state.actionStatus == BookingActionStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionSuccess ?? 'Success'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.read<BookingBloc>().add(const ClearBookingSuccess());
                  // Reload booking detail
                  context.read<BookingBloc>().add(LoadBookingDetail(widget.bookingId));
                }

                if (state.actionStatus == BookingActionStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionError ?? 'Error'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  context.read<BookingBloc>().add(const ClearBookingError());
                }
              },
              builder: (context, state) {
                if (state.detailStatus == BookingDetailStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.detailStatus == BookingDetailStatus.error) {
                  return _buildErrorState(state.detailError);
                }

                final booking = state.selectedBooking;
                if (booking == null) {
                  return _buildErrorState('Booking not found');
                }

                return Column(
                  children: [
                    // Header
                    _buildHeader(booking),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.medium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vendor card
                            _buildVendorCard(booking),
                            const SizedBox(height: AppSpacing.medium),

                            // Booking details card
                            _buildDetailsCard(booking),
                            const SizedBox(height: AppSpacing.medium),

                            // Package card
                            if (booking.package != null) ...[
                              _buildPackageCard(booking),
                              const SizedBox(height: AppSpacing.medium),
                            ],

                            // Notes card
                            if (booking.coupleNotes != null || booking.vendorNotes != null)
                              _buildNotesCard(booking),

                            const SizedBox(height: AppSpacing.large),

                            // Action buttons
                            _buildActionButtons(booking, state),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Booking booking) {
    return Padding(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Details',
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'ID: ${booking.id.substring(0, 8)}...',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(booking.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case BookingStatus.pending:
        bgColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      case BookingStatus.accepted:
      case BookingStatus.confirmed:
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        break;
      case BookingStatus.completed:
        bgColor = AppColors.accent.withOpacity(0.2);
        textColor = AppColors.accent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: AppTypography.labelMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVendorCard(Booking booking) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.accentPurple.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.storefront,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.vendor?.businessName ?? 'Unknown Vendor',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (booking.vendor?.categoryName != null)
                    Text(
                      booking.vendor!.categoryName!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            GlassIconButton(
              icon: Icons.chat_bubble_outline,
              onTap: () {
                // TODO: Navigate to chat
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(Booking booking) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Information',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Booking Date',
              value: booking.bookingDateFormatted,
            ),
            const SizedBox(height: AppSpacing.base),
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Created',
              value: booking.createdAtFormatted,
            ),
            const SizedBox(height: AppSpacing.base),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Total Amount',
              value: booking.totalAmountFormatted,
              valueColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.base),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodyLarge.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(Booking booking) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Selected Package',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.package!.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    booking.package!.priceFormatted,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Booking booking) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (booking.coupleNotes != null) ...[
              const SizedBox(height: AppSpacing.base),
              Text(
                'Your Notes:',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.coupleNotes!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (booking.vendorNotes != null) ...[
              const SizedBox(height: AppSpacing.base),
              Text(
                'Vendor Notes:',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.vendorNotes!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Booking booking, BookingState state) {
    final isLoading = state.actionStatus == BookingActionStatus.loading;

    return Column(
      children: [
        // Cancel button (for active bookings)
        if (booking.status.canCancel)
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onTap: isLoading ? null : _onCancelBooking,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : Text(
                      'Cancel Booking',
                      style: TextStyle(color: AppColors.error),
                    ),
            ),
          ),

        // Review button (for completed bookings)
        if (booking.status.canReview) ...[
          const SizedBox(height: AppSpacing.base),
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              onTap: isLoading ? null : () => _onAddReview(booking),
              isPrimary: true,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: AppColors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Write a Review',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ],
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
              'Failed to load booking',
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
              onTap: () => context.read<BookingBloc>().add(
                    LoadBookingDetail(widget.bookingId),
                  ),
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
}

/// Review bottom sheet
class _ReviewBottomSheet extends StatefulWidget {
  final String bookingId;
  final String vendorName;
  final Function(int rating, String review) onSubmit;

  const _ReviewBottomSheet({
    required this.bookingId,
    required this.vendorName,
    required this.onSubmit,
  });

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  int _rating = 5;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.large,
          right: AppSpacing.large,
          top: AppSpacing.large,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review ${widget.vendorName}',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.large),

            // Star rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            // Review text
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your review...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.glassBackground,
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
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                isPrimary: true,
                onTap: () {
                  final review = _reviewController.text.trim();
                  if (review.isNotEmpty) {
                    widget.onSubmit(_rating, review);
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Submit Review',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
