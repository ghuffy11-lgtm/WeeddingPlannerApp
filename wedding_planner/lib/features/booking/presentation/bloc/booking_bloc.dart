import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;

  BookingBloc({required this.repository}) : super(const BookingState()) {
    on<LoadBookings>(_onLoadBookings);
    on<LoadMoreBookings>(_onLoadMoreBookings);
    on<RefreshBookings>(_onRefreshBookings);
    on<LoadBookingDetail>(_onLoadBookingDetail);
    on<CreateBooking>(_onCreateBooking);
    on<CancelBooking>(_onCancelBooking);
    on<AddBookingReview>(_onAddBookingReview);
    on<ClearBookingDetail>(_onClearBookingDetail);
    on<ClearBookingError>(_onClearBookingError);
    on<ClearBookingSuccess>(_onClearBookingSuccess);
  }

  Future<void> _onLoadBookings(
    LoadBookings event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(listStatus: BookingListStatus.loading));

    final filter = BookingFilter(
      status: event.statusFilter,
      page: 1,
    );

    final result = await repository.getMyBookings(filter);

    result.fold(
      (failure) => emit(state.copyWith(
        listStatus: BookingListStatus.error,
        listError: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        listStatus: BookingListStatus.loaded,
        bookings: paginated.bookings,
        filter: filter,
        hasMore: paginated.hasMore,
      )),
    );
  }

  Future<void> _onLoadMoreBookings(
    LoadMoreBookings event,
    Emitter<BookingState> emit,
  ) async {
    if (!state.hasMore || state.listStatus == BookingListStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(listStatus: BookingListStatus.loadingMore));

    final filter = state.filter.copyWith(page: state.filter.page + 1);
    final result = await repository.getMyBookings(filter);

    result.fold(
      (failure) => emit(state.copyWith(
        listStatus: BookingListStatus.loaded,
        listError: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        listStatus: BookingListStatus.loaded,
        bookings: [...state.bookings, ...paginated.bookings],
        filter: filter,
        hasMore: paginated.hasMore,
      )),
    );
  }

  Future<void> _onRefreshBookings(
    RefreshBookings event,
    Emitter<BookingState> emit,
  ) async {
    final filter = state.filter.copyWith(page: 1);
    final result = await repository.getMyBookings(filter);

    result.fold(
      (failure) => emit(state.copyWith(
        listError: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        listStatus: BookingListStatus.loaded,
        bookings: paginated.bookings,
        filter: filter,
        hasMore: paginated.hasMore,
      )),
    );
  }

  Future<void> _onLoadBookingDetail(
    LoadBookingDetail event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(detailStatus: BookingDetailStatus.loading));

    final result = await repository.getBooking(event.bookingId);

    result.fold(
      (failure) => emit(state.copyWith(
        detailStatus: BookingDetailStatus.error,
        detailError: failure.message,
      )),
      (booking) => emit(state.copyWith(
        detailStatus: BookingDetailStatus.loaded,
        selectedBooking: booking,
      )),
    );
  }

  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BookingActionStatus.loading));

    final result = await repository.createBooking(event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BookingActionStatus.error,
        actionError: failure.message,
      )),
      (booking) => emit(state.copyWith(
        actionStatus: BookingActionStatus.success,
        actionSuccess: 'Booking request sent successfully!',
        createdBooking: booking,
      )),
    );
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BookingActionStatus.loading));

    final result = await repository.cancelBooking(event.bookingId);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BookingActionStatus.error,
        actionError: failure.message,
      )),
      (_) {
        // Update the booking in the list
        final updatedBookings = state.bookings.map((b) {
          if (b.id == event.bookingId) {
            return BookingSummary(
              id: b.id,
              bookingDate: b.bookingDate,
              status: BookingStatus.cancelled,
              totalAmount: b.totalAmount,
              vendor: b.vendor,
              package: b.package,
              createdAt: b.createdAt,
            );
          }
          return b;
        }).toList();

        emit(state.copyWith(
          actionStatus: BookingActionStatus.success,
          actionSuccess: 'Booking cancelled successfully',
          bookings: updatedBookings,
        ));
      },
    );
  }

  Future<void> _onAddBookingReview(
    AddBookingReview event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BookingActionStatus.loading));

    final result = await repository.addReview(
      bookingId: event.bookingId,
      rating: event.rating,
      reviewText: event.reviewText,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BookingActionStatus.error,
        actionError: failure.message,
      )),
      (_) => emit(state.copyWith(
        actionStatus: BookingActionStatus.success,
        actionSuccess: 'Review added successfully!',
      )),
    );
  }

  void _onClearBookingDetail(
    ClearBookingDetail event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      detailStatus: BookingDetailStatus.initial,
      clearSelectedBooking: true,
    ));
  }

  void _onClearBookingError(
    ClearBookingError event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      actionStatus: BookingActionStatus.initial,
      clearActionError: true,
    ));
  }

  void _onClearBookingSuccess(
    ClearBookingSuccess event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      actionStatus: BookingActionStatus.initial,
      clearActionSuccess: true,
      clearCreatedBooking: true,
    ));
  }
}
