import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/vendor_app_repository.dart';
import 'vendor_bookings_event.dart';
import 'vendor_bookings_state.dart';

class VendorBookingsBloc
    extends Bloc<VendorBookingsEvent, VendorBookingsState> {
  final VendorAppRepository repository;

  VendorBookingsBloc({required this.repository})
      : super(const VendorBookingsState()) {
    on<LoadBookingRequests>(_onLoadRequests);
    on<LoadMoreBookingRequests>(_onLoadMoreRequests);
    on<LoadAllBookings>(_onLoadAllBookings);
    on<LoadMoreBookings>(_onLoadMoreBookings);
    on<UpdateBookingFilter>(_onUpdateFilter);
    on<LoadBookingDetail>(_onLoadDetail);
    on<AcceptBooking>(_onAcceptBooking);
    on<DeclineBooking>(_onDeclineBooking);
    on<CompleteBooking>(_onCompleteBooking);
    on<LoadBookedDates>(_onLoadBookedDates);
    on<ClearBookingAction>(_onClearAction);
  }

  Future<void> _onLoadRequests(
    LoadBookingRequests event,
    Emitter<VendorBookingsState> emit,
  ) async {
    emit(state.copyWith(
      requestsStatus: BookingListStatus.loading,
      requestsPage: 1,
    ));

    final result = await repository.getBookingRequests(page: 1);

    result.fold(
      (failure) => emit(state.copyWith(
        requestsStatus: BookingListStatus.error,
        requestsError: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        requestsStatus: BookingListStatus.loaded,
        requests: paginated.bookings,
        requestsPage: paginated.currentPage,
        hasMoreRequests: paginated.hasMore,
      )),
    );
  }

  Future<void> _onLoadMoreRequests(
    LoadMoreBookingRequests event,
    Emitter<VendorBookingsState> emit,
  ) async {
    if (!state.hasMoreRequests ||
        state.requestsStatus == BookingListStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(requestsStatus: BookingListStatus.loadingMore));

    final result = await repository.getBookingRequests(
      page: state.requestsPage + 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        requestsStatus: BookingListStatus.loaded,
      )),
      (paginated) => emit(state.copyWith(
        requestsStatus: BookingListStatus.loaded,
        requests: [...state.requests, ...paginated.bookings],
        requestsPage: paginated.currentPage,
        hasMoreRequests: paginated.hasMore,
      )),
    );
  }

  Future<void> _onLoadAllBookings(
    LoadAllBookings event,
    Emitter<VendorBookingsState> emit,
  ) async {
    emit(state.copyWith(
      bookingsStatus: BookingListStatus.loading,
      currentFilter: event.filter,
      bookingsPage: 1,
    ));

    final result = await repository.getAllBookings(filter: event.filter);

    result.fold(
      (failure) => emit(state.copyWith(
        bookingsStatus: BookingListStatus.error,
        bookingsError: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        bookingsStatus: BookingListStatus.loaded,
        bookings: paginated.bookings,
        bookingsPage: paginated.currentPage,
        hasMoreBookings: paginated.hasMore,
      )),
    );
  }

  Future<void> _onLoadMoreBookings(
    LoadMoreBookings event,
    Emitter<VendorBookingsState> emit,
  ) async {
    if (!state.hasMoreBookings ||
        state.bookingsStatus == BookingListStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(bookingsStatus: BookingListStatus.loadingMore));

    final nextFilter = state.currentFilter.copyWith(
      page: state.bookingsPage + 1,
    );
    final result = await repository.getAllBookings(filter: nextFilter);

    result.fold(
      (failure) => emit(state.copyWith(
        bookingsStatus: BookingListStatus.loaded,
      )),
      (paginated) => emit(state.copyWith(
        bookingsStatus: BookingListStatus.loaded,
        bookings: [...state.bookings, ...paginated.bookings],
        bookingsPage: paginated.currentPage,
        hasMoreBookings: paginated.hasMore,
      )),
    );
  }

  Future<void> _onUpdateFilter(
    UpdateBookingFilter event,
    Emitter<VendorBookingsState> emit,
  ) async {
    final newFilter = VendorBookingFilter(status: event.status);
    add(LoadAllBookings(filter: newFilter));
  }

  Future<void> _onLoadDetail(
    LoadBookingDetail event,
    Emitter<VendorBookingsState> emit,
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

  Future<void> _onAcceptBooking(
    AcceptBooking event,
    Emitter<VendorBookingsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BookingActionStatus.loading));

    final result = await repository.acceptBooking(
      event.bookingId,
      vendorNotes: event.vendorNotes,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BookingActionStatus.error,
        actionError: failure.message,
      )),
      (booking) {
        // Remove from requests list
        final updatedRequests = state.requests
            .where((b) => b.id != event.bookingId)
            .toList();

        emit(state.copyWith(
          actionStatus: BookingActionStatus.success,
          actionSuccessMessage: 'Booking accepted',
          requests: updatedRequests,
          selectedBooking: booking,
        ));
      },
    );
  }

  Future<void> _onDeclineBooking(
    DeclineBooking event,
    Emitter<VendorBookingsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BookingActionStatus.loading));

    final result = await repository.declineBooking(
      event.bookingId,
      event.reason,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BookingActionStatus.error,
        actionError: failure.message,
      )),
      (booking) {
        // Remove from requests list
        final updatedRequests = state.requests
            .where((b) => b.id != event.bookingId)
            .toList();

        emit(state.copyWith(
          actionStatus: BookingActionStatus.success,
          actionSuccessMessage: 'Booking declined',
          requests: updatedRequests,
          selectedBooking: booking,
        ));
      },
    );
  }

  Future<void> _onCompleteBooking(
    CompleteBooking event,
    Emitter<VendorBookingsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: BookingActionStatus.loading));

    final result = await repository.completeBooking(event.bookingId);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: BookingActionStatus.error,
        actionError: failure.message,
      )),
      (booking) {
        // Update booking in list
        final updatedBookings = state.bookings.map((b) {
          if (b.id == event.bookingId) {
            return booking;
          }
          return b;
        }).toList();

        emit(state.copyWith(
          actionStatus: BookingActionStatus.success,
          actionSuccessMessage: 'Booking completed',
          bookings: updatedBookings,
          selectedBooking: booking,
        ));
      },
    );
  }

  Future<void> _onLoadBookedDates(
    LoadBookedDates event,
    Emitter<VendorBookingsState> emit,
  ) async {
    final result = await repository.getBookedDates(
      fromDate: event.fromDate,
      toDate: event.toDate,
    );

    result.fold(
      (failure) => null,
      (dates) => emit(state.copyWith(bookedDates: dates)),
    );
  }

  void _onClearAction(
    ClearBookingAction event,
    Emitter<VendorBookingsState> emit,
  ) {
    emit(state.copyWith(
      actionStatus: BookingActionStatus.initial,
      actionError: null,
      actionSuccessMessage: null,
    ));
  }
}
