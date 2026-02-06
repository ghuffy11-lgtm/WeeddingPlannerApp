import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Load user's bookings
class LoadBookings extends BookingEvent {
  final BookingStatus? statusFilter;

  const LoadBookings({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

/// Load more bookings (pagination)
class LoadMoreBookings extends BookingEvent {
  const LoadMoreBookings();
}

/// Refresh bookings
class RefreshBookings extends BookingEvent {
  const RefreshBookings();
}

/// Load single booking details
class LoadBookingDetail extends BookingEvent {
  final String bookingId;

  const LoadBookingDetail(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Create a new booking
class CreateBooking extends BookingEvent {
  final CreateBookingRequest request;

  const CreateBooking(this.request);

  @override
  List<Object?> get props => [request];
}

/// Cancel a booking
class CancelBooking extends BookingEvent {
  final String bookingId;

  const CancelBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Add review to booking
class AddBookingReview extends BookingEvent {
  final String bookingId;
  final int rating;
  final String reviewText;

  const AddBookingReview({
    required this.bookingId,
    required this.rating,
    required this.reviewText,
  });

  @override
  List<Object?> get props => [bookingId, rating, reviewText];
}

/// Clear booking detail
class ClearBookingDetail extends BookingEvent {
  const ClearBookingDetail();
}

/// Clear error message
class ClearBookingError extends BookingEvent {
  const ClearBookingError();
}

/// Clear success message
class ClearBookingSuccess extends BookingEvent {
  const ClearBookingSuccess();
}
