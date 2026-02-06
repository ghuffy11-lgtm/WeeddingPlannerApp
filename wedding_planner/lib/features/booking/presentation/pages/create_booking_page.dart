import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../vendors/domain/entities/vendor.dart';
import '../../../vendors/domain/entities/vendor_package.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

/// Create booking page for booking a vendor
class CreateBookingPage extends StatefulWidget {
  final Vendor vendor;

  const CreateBookingPage({
    super.key,
    required this.vendor,
  });

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  DateTime? _selectedDate;
  VendorPackage? _selectedPackage;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSubmit() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a booking date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final request = CreateBookingRequest(
      vendorId: widget.vendor.id,
      packageId: _selectedPackage?.id,
      bookingDate: _selectedDate!,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    context.read<BookingBloc>().add(CreateBooking(request));
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
            color: AppColors.accent,
            alignment: Alignment(0.9, 0.3),
            size: 300,
          ),

          // Content
          SafeArea(
            child: BlocConsumer<BookingBloc, BookingState>(
              listener: (context, state) {
                if (state.actionStatus == BookingActionStatus.success &&
                    state.createdBooking != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking request sent successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.read<BookingBloc>().add(const ClearBookingSuccess());
                  // Go to bookings page
                  context.go('/bookings');
                }

                if (state.actionStatus == BookingActionStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.actionError ?? 'Failed to create booking'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  context.read<BookingBloc>().add(const ClearBookingError());
                }
              },
              builder: (context, state) {
                final isLoading = state.actionStatus == BookingActionStatus.loading;

                return Column(
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
                            'Book Vendor',
                            style: AppTypography.hero.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.medium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vendor info
                            _buildVendorCard(),
                            const SizedBox(height: AppSpacing.large),

                            // Date selection
                            Text(
                              'Select Date',
                              style: AppTypography.h4.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.small),
                            _buildDateSelector(),
                            const SizedBox(height: AppSpacing.large),

                            // Package selection
                            if (widget.vendor.packages.isNotEmpty) ...[
                              Text(
                                'Select Package (Optional)',
                                style: AppTypography.h4.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              _buildPackageSelector(),
                              const SizedBox(height: AppSpacing.large),
                            ],

                            // Notes
                            Text(
                              'Notes (Optional)',
                              style: AppTypography.h4.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.small),
                            _buildNotesField(),
                            const SizedBox(height: AppSpacing.xl),

                            // Summary
                            _buildSummary(),
                            const SizedBox(height: AppSpacing.large),

                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              child: GlassButton(
                                isPrimary: true,
                                onTap: isLoading ? null : _onSubmit,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Send Booking Request',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.medium),
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

  Widget _buildVendorCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.accentPurple.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.storefront,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vendor.businessName,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.vendor.category != null)
                    Text(
                      widget.vendor.category!.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (widget.vendor.locationDisplay.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.vendor.locationDisplay,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Text(
                  _selectedDate != null
                      ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                      : 'Tap to select date',
                  style: AppTypography.bodyLarge.copyWith(
                    color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageSelector() {
    return Column(
      children: widget.vendor.packages.map((package) {
        final isSelected = _selectedPackage?.id == package.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPackage = isSelected ? null : package;
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.glassBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.base),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.name,
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (package.description != null)
                              Text(
                                package.description!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        package.formatPrice(),
                        style: AppTypography.h4.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: TextField(
          controller: _notesController,
          maxLines: 4,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Add any special requests or notes for the vendor...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.glassBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final total = _selectedPackage?.price;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            const Divider(color: AppColors.glassBorder),
            const SizedBox(height: AppSpacing.base),
            _buildSummaryRow(
              'Vendor',
              widget.vendor.businessName,
            ),
            const SizedBox(height: AppSpacing.small),
            _buildSummaryRow(
              'Date',
              _selectedDate != null
                  ? DateFormat('MMM d, yyyy').format(_selectedDate!)
                  : 'Not selected',
            ),
            if (_selectedPackage != null) ...[
              const SizedBox(height: AppSpacing.small),
              _buildSummaryRow(
                'Package',
                _selectedPackage!.name,
              ),
            ],
            const SizedBox(height: AppSpacing.base),
            const Divider(color: AppColors.glassBorder),
            const SizedBox(height: AppSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  total != null ? '\$${total.toStringAsFixed(0)}' : 'TBD',
                  style: AppTypography.hero.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
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
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
