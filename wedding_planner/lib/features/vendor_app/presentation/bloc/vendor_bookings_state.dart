import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_booking.dart';
import '../../domain/repositories/vendor_app_repository.dart';

enum BookingListStatus { initial, loading, loaded, loadingMore, error }
enum BookingDetailStatus { initial, loading, loaded, error }
enum BookingActionStatus { initial, loading, success, error }

class VendorBookingsState extends Equatable {
  // Booking requests (pending)
  final BookingListStatus requestsStatus;
  final List<VendorBookingSummary> requests;
  final int requestsPage;
  final bool hasMoreRequests;
  final String? requestsError;

  // All bookings
  final BookingListStatus bookingsStatus;
  final List<VendorBookingSummary> bookings;
  final VendorBookingFilter currentFilter;
  final int bookingsPage;
  final bool hasMoreBookings;
  final String? bookingsError;

  // Booking detail
  final BookingDetailStatus detailStatus;
  final VendorBooking? selectedBooking;
  final String? detailError;

  // Booked dates (for calendar)
  final List<DateTime> bookedDates;

  // Action status (accept, decline, complete)
  final BookingActionStatus actionStatus;
  final String? actionError;
  final String? actionSuccessMessage;

  const VendorBookingsState({
    this.requestsStatus = BookingListStatus.initial,
    this.requests = const [],
    this.requestsPage = 1,
    this.hasMoreRequests = false,
    this.requestsError,
    this.bookingsStatus = BookingListStatus.initial,
    this.bookings = const [],
    this.currentFilter = const VendorBookingFilter(),
    this.bookingsPage = 1,
    this.hasMoreBookings = false,
    this.bookingsError,
    this.detailStatus = BookingDetailStatus.initial,
    this.selectedBooking,
    this.detailError,
    this.bookedDates = const [],
    this.actionStatus = BookingActionStatus.initial,
    this.actionError,
    this.actionSuccessMessage,
  });

  VendorBookingsState copyWith({
    BookingListStatus? requestsStatus,
    List<VendorBookingSummary>? requests,
    int? requestsPage,
    bool? hasMoreRequests,
    String? requestsError,
    BookingListStatus? bookingsStatus,
    List<VendorBookingSummary>? bookings,
    VendorBookingFilter? currentFilter,
    int? bookingsPage,
    bool? hasMoreBookings,
    String? bookingsError,
    BookingDetailStatus? detailStatus,
    VendorBooking? selectedBooking,
    String? detailError,
    List<DateTime>? bookedDates,
    BookingActionStatus? actionStatus,
    String? actionError,
    String? actionSuccessMessage,
  }) {
    return VendorBookingsState(
      requestsStatus: requestsStatus ?? this.requestsStatus,
      requests: requests ?? this.requests,
      requestsPage: requestsPage ?? this.requestsPage,
      hasMoreRequests: hasMoreRequests ?? this.hasMoreRequests,
      requestsError: requestsError,
      bookingsStatus: bookingsStatus ?? this.bookingsStatus,
      bookings: bookings ?? this.bookings,
      currentFilter: currentFilter ?? this.currentFilter,
      bookingsPage: bookingsPage ?? this.bookingsPage,
      hasMoreBookings: hasMoreBookings ?? this.hasMoreBookings,
      bookingsError: bookingsError,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      detailError: detailError,
      bookedDates: bookedDates ?? this.bookedDates,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        requestsStatus,
        requests,
        requestsPage,
        hasMoreRequests,
        requestsError,
        bookingsStatus,
        bookings,
        currentFilter,
        bookingsPage,
        hasMoreBookings,
        bookingsError,
        detailStatus,
        selectedBooking,
        detailError,
        bookedDates,
        actionStatus,
        actionError,
        actionSuccessMessage,
      ];
}
