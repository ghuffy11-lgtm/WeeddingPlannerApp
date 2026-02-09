import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_booking.dart';
import '../../domain/repositories/vendor_app_repository.dart';

abstract class VendorBookingsEvent extends Equatable {
  const VendorBookingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load pending booking requests
class LoadBookingRequests extends VendorBookingsEvent {
  const LoadBookingRequests();
}

/// Load more booking requests (pagination)
class LoadMoreBookingRequests extends VendorBookingsEvent {
  const LoadMoreBookingRequests();
}

/// Load all bookings with filter
class LoadAllBookings extends VendorBookingsEvent {
  final VendorBookingFilter filter;

  const LoadAllBookings({this.filter = const VendorBookingFilter()});

  @override
  List<Object?> get props => [filter];
}

/// Load more bookings (pagination)
class LoadMoreBookings extends VendorBookingsEvent {
  const LoadMoreBookings();
}

/// Update booking filter
class UpdateBookingFilter extends VendorBookingsEvent {
  final VendorBookingStatus? status;

  const UpdateBookingFilter({this.status});

  @override
  List<Object?> get props => [status];
}

/// Load single booking detail
class LoadBookingDetail extends VendorBookingsEvent {
  final String bookingId;

  const LoadBookingDetail(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Accept a booking
class AcceptBooking extends VendorBookingsEvent {
  final String bookingId;
  final String? vendorNotes;

  const AcceptBooking({
    required this.bookingId,
    this.vendorNotes,
  });

  @override
  List<Object?> get props => [bookingId, vendorNotes];
}

/// Decline a booking
class DeclineBooking extends VendorBookingsEvent {
  final String bookingId;
  final String reason;

  const DeclineBooking({
    required this.bookingId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bookingId, reason];
}

/// Complete a booking
class CompleteBooking extends VendorBookingsEvent {
  final String bookingId;

  const CompleteBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Load booked dates for calendar
class LoadBookedDates extends VendorBookingsEvent {
  final DateTime? fromDate;
  final DateTime? toDate;

  const LoadBookedDates({this.fromDate, this.toDate});

  @override
  List<Object?> get props => [fromDate, toDate];
}

/// Clear booking action status
class ClearBookingAction extends VendorBookingsEvent {
  const ClearBookingAction();
}
