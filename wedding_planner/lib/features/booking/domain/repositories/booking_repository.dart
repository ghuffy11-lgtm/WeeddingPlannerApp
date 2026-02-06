import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking.dart';

/// Filter options for booking list
class BookingFilter {
  final BookingStatus? status;
  final int page;
  final int limit;

  const BookingFilter({
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  BookingFilter copyWith({
    BookingStatus? status,
    int? page,
    int? limit,
  }) {
    return BookingFilter(
      status: status ?? this.status,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// Paginated result for bookings
class PaginatedBookings {
  final List<BookingSummary> bookings;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedBookings({
    required this.bookings,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
}

/// Booking repository interface
abstract class BookingRepository {
  /// Get user's bookings with optional filter
  Future<Either<Failure, PaginatedBookings>> getMyBookings(BookingFilter filter);

  /// Get single booking details
  Future<Either<Failure, Booking>> getBooking(String id);

  /// Create a new booking
  Future<Either<Failure, BookingSummary>> createBooking(CreateBookingRequest request);

  /// Cancel a booking
  Future<Either<Failure, void>> cancelBooking(String id);

  /// Add review to completed booking
  Future<Either<Failure, void>> addReview({
    required String bookingId,
    required int rating,
    required String reviewText,
  });
}
