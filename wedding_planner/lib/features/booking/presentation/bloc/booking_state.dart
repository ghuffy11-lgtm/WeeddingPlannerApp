import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

enum BookingListStatus { initial, loading, loaded, loadingMore, error }

enum BookingDetailStatus { initial, loading, loaded, error }

enum BookingActionStatus { initial, loading, success, error }

class BookingState extends Equatable {
  // List state
  final BookingListStatus listStatus;
  final List<BookingSummary> bookings;
  final BookingFilter filter;
  final bool hasMore;
  final String? listError;

  // Detail state
  final BookingDetailStatus detailStatus;
  final Booking? selectedBooking;
  final String? detailError;

  // Action state (create, cancel, review)
  final BookingActionStatus actionStatus;
  final String? actionError;
  final String? actionSuccess;
  final BookingSummary? createdBooking;

  const BookingState({
    this.listStatus = BookingListStatus.initial,
    this.bookings = const [],
    this.filter = const BookingFilter(),
    this.hasMore = true,
    this.listError,
    this.detailStatus = BookingDetailStatus.initial,
    this.selectedBooking,
    this.detailError,
    this.actionStatus = BookingActionStatus.initial,
    this.actionError,
    this.actionSuccess,
    this.createdBooking,
  });

  BookingState copyWith({
    BookingListStatus? listStatus,
    List<BookingSummary>? bookings,
    BookingFilter? filter,
    bool? hasMore,
    String? listError,
    BookingDetailStatus? detailStatus,
    Booking? selectedBooking,
    String? detailError,
    BookingActionStatus? actionStatus,
    String? actionError,
    String? actionSuccess,
    BookingSummary? createdBooking,
    bool clearSelectedBooking = false,
    bool clearActionError = false,
    bool clearActionSuccess = false,
    bool clearCreatedBooking = false,
  }) {
    return BookingState(
      listStatus: listStatus ?? this.listStatus,
      bookings: bookings ?? this.bookings,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      listError: listError ?? this.listError,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedBooking: clearSelectedBooking ? null : (selectedBooking ?? this.selectedBooking),
      detailError: detailError ?? this.detailError,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      actionSuccess: clearActionSuccess ? null : (actionSuccess ?? this.actionSuccess),
      createdBooking: clearCreatedBooking ? null : (createdBooking ?? this.createdBooking),
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        bookings,
        filter,
        hasMore,
        listError,
        detailStatus,
        selectedBooking,
        detailError,
        actionStatus,
        actionError,
        actionSuccess,
        createdBooking,
      ];
}
