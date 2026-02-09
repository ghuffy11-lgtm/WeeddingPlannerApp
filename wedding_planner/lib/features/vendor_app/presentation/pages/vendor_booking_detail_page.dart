import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/vendor_booking.dart';
import '../bloc/vendor_bookings_bloc.dart';
import '../bloc/vendor_bookings_event.dart';
import '../bloc/vendor_bookings_state.dart';
import '../bloc/vendor_dashboard_bloc.dart';
import '../bloc/vendor_dashboard_event.dart';

class VendorBookingDetailPage extends StatefulWidget {
  final String bookingId;

  const VendorBookingDetailPage({
    super.key,
    required this.bookingId,
  });

  @override
  State<VendorBookingDetailPage> createState() => _VendorBookingDetailPageState();
}

class _VendorBookingDetailPageState extends State<VendorBookingDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<VendorBookingsBloc>().add(LoadBookingDetail(widget.bookingId));
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
          'Booking Details',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<VendorBookingsBloc, VendorBookingsState>(
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
          if (state.detailStatus == BookingDetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.detailStatus == BookingDetailStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.detailError ?? 'Failed to load booking',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VendorBookingsBloc>().add(
                            LoadBookingDetail(widget.bookingId),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final booking = state.selectedBooking;
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(booking),
                const SizedBox(height: 20),
                _buildCoupleInfo(booking),
                const SizedBox(height: 20),
                _buildBookingInfo(booking),
                const SizedBox(height: 20),
                if (booking.coupleNotes != null) ...[
                  _buildNotesSection('Couple Notes', booking.coupleNotes!),
                  const SizedBox(height: 20),
                ],
                if (booking.vendorNotes != null) ...[
                  _buildNotesSection('Your Notes', booking.vendorNotes!),
                  const SizedBox(height: 20),
                ],
                _buildPaymentInfo(booking),
                const SizedBox(height: 32),
                _buildActions(booking, state),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(VendorBooking booking) {
    Color statusColor;
    IconData statusIcon;

    switch (booking.status) {
      case VendorBookingStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case VendorBookingStatus.accepted:
        statusColor = AppColors.accent;
        statusIcon = Icons.check_circle_outline;
        break;
      case VendorBookingStatus.confirmed:
        statusColor = AppColors.primary;
        statusIcon = Icons.verified;
        break;
      case VendorBookingStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.task_alt;
        break;
      case VendorBookingStatus.declined:
      case VendorBookingStatus.cancelled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.status.displayName,
                  style: AppTypography.h4.copyWith(color: statusColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created ${booking.createdAtFormatted}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleInfo(VendorBooking booking) {
    return _buildCard(
      title: 'Couple',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.coupleNames,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (booking.couple?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        booking.couple!.email!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (booking.couple?.phone != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Text(
                  booking.couple!.phone!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingInfo(VendorBooking booking) {
    return _buildCard(
      title: 'Booking Details',
      child: Column(
        children: [
          _buildInfoRow('Event Date', booking.bookingDateFormatted),
          if (booking.weddingDate != null)
            _buildInfoRow('Wedding Date', booking.weddingDateFormatted),
          if (booking.packageName != null)
            _buildInfoRow('Package', booking.packageName!),
          if (booking.package?.price != null)
            _buildInfoRow('Package Price', booking.package!.priceFormatted),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String title, String notes) {
    return _buildCard(
      title: title,
      child: Text(
        notes,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(VendorBooking booking) {
    return _buildCard(
      title: 'Payment',
      child: Column(
        children: [
          _buildInfoRow(
            'Total Amount',
            booking.totalAmountFormatted,
            valueColor: AppColors.textPrimary,
          ),
          if (booking.commissionAmount != null)
            _buildInfoRow(
              'Platform Fee',
              '-${booking.commissionFormatted}',
              valueColor: AppColors.error,
            ),
          if (booking.vendorPayout != null) ...[
            const Divider(color: AppColors.glassBorder),
            _buildInfoRow(
              'Your Payout',
              booking.vendorPayoutFormatted,
              valueColor: AppColors.success,
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(VendorBooking booking, VendorBookingsState state) {
    final isLoading = state.actionStatus == BookingActionStatus.loading;

    if (booking.status.canAccept) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => _showDeclineDialog(booking.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<VendorBookingsBloc>().add(
                            AcceptBooking(bookingId: booking.id),
                          );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Accept'),
            ),
          ),
        ],
      );
    }

    if (booking.status.canComplete) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  context.read<VendorBookingsBloc>().add(
                        CompleteBooking(booking.id),
                      );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Text('Mark as Completed'),
        ),
      );
    }

    return const SizedBox.shrink();
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
              'Please provide a reason for declining:',
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
