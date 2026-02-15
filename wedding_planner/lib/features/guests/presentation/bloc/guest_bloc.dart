import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/guest_repository.dart';
import 'guest_event.dart';
import 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository _repository;

  GuestBloc({required GuestRepository repository})
      : _repository = repository,
        super(const GuestState()) {
    on<InitializeGuests>(_onInitializeGuests);
    on<LoadGuests>(_onLoadGuests);
    on<LoadMoreGuests>(_onLoadMoreGuests);
    on<RefreshGuests>(_onRefreshGuests);
    on<LoadGuestDetail>(_onLoadGuestDetail);
    on<CreateGuest>(_onCreateGuest);
    on<UpdateGuest>(_onUpdateGuest);
    on<DeleteGuest>(_onDeleteGuest);
    on<UpdateRsvpStatus>(_onUpdateRsvpStatus);
    on<SendInvitation>(_onSendInvitation);
    on<SendBulkInvitations>(_onSendBulkInvitations);
    on<LoadGuestStats>(_onLoadGuestStats);
    on<UpdateFilter>(_onUpdateFilter);
    on<ClearFilter>(_onClearFilter);
    on<SearchGuests>(_onSearchGuests);
    on<ToggleGuestSelection>(_onToggleGuestSelection);
    on<SelectAllGuests>(_onSelectAllGuests);
    on<ClearSelections>(_onClearSelections);
    on<ClearGuestError>(_onClearGuestError);
  }

  void _onInitializeGuests(
    InitializeGuests event,
    Emitter<GuestState> emit,
  ) {
    emit(state.copyWith(weddingId: event.weddingId));
    // Auto-load guests after initialization
    add(const LoadGuests());
  }

  Future<void> _onLoadGuests(
    LoadGuests event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) {
      emit(state.copyWith(
        listStatus: GuestListStatus.error,
        listError: 'Wedding not initialized. Please create a wedding first.',
      ));
      return;
    }

    emit(state.copyWith(
      listStatus: GuestListStatus.loading,
      filter: event.filter,
    ));

    final result =
        await _repository.getGuests(state.weddingId!, event.filter);

    result.fold(
      (failure) => emit(state.copyWith(
        listStatus: GuestListStatus.error,
        listError: failure.message,
      )),
      (paginatedGuests) => emit(state.copyWith(
        listStatus: GuestListStatus.loaded,
        guests: paginatedGuests.guests,
        currentPage: paginatedGuests.currentPage,
        totalPages: paginatedGuests.totalPages,
        totalItems: paginatedGuests.totalItems,
        hasMore: paginatedGuests.hasMore,
      )),
    );
  }

  Future<void> _onLoadMoreGuests(
    LoadMoreGuests event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId ||
        !state.hasMore ||
        state.listStatus == GuestListStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(listStatus: GuestListStatus.loadingMore));

    final nextFilter = state.filter.copyWith(page: state.currentPage + 1);
    final result = await _repository.getGuests(state.weddingId!, nextFilter);

    result.fold(
      (failure) => emit(state.copyWith(
        listStatus: GuestListStatus.loaded,
        listError: failure.message,
      )),
      (paginatedGuests) => emit(state.copyWith(
        listStatus: GuestListStatus.loaded,
        guests: [...state.guests, ...paginatedGuests.guests],
        currentPage: paginatedGuests.currentPage,
        totalPages: paginatedGuests.totalPages,
        totalItems: paginatedGuests.totalItems,
        hasMore: paginatedGuests.hasMore,
      )),
    );
  }

  Future<void> _onRefreshGuests(
    RefreshGuests event,
    Emitter<GuestState> emit,
  ) async {
    final refreshFilter = state.filter.copyWith(page: 1);
    add(LoadGuests(filter: refreshFilter));
  }

  Future<void> _onLoadGuestDetail(
    LoadGuestDetail event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) return;

    emit(state.copyWith(detailStatus: GuestDetailStatus.loading));

    final result =
        await _repository.getGuest(state.weddingId!, event.guestId);

    result.fold(
      (failure) => emit(state.copyWith(
        detailStatus: GuestDetailStatus.error,
        detailError: failure.message,
      )),
      (guest) => emit(state.copyWith(
        detailStatus: GuestDetailStatus.loaded,
        selectedGuest: guest,
      )),
    );
  }

  Future<void> _onCreateGuest(
    CreateGuest event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) {
      emit(state.copyWith(
        actionStatus: GuestActionStatus.error,
        actionError: 'Wedding not initialized',
      ));
      return;
    }

    emit(state.copyWith(actionStatus: GuestActionStatus.loading));

    final result =
        await _repository.createGuest(state.weddingId!, event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: GuestActionStatus.error,
        actionError: failure.message,
      )),
      (guest) {
        emit(state.copyWith(
          actionStatus: GuestActionStatus.success,
          actionSuccessMessage: 'Guest added successfully',
          selectedGuest: guest,
        ));
        // Refresh the list
        add(const RefreshGuests());
      },
    );
  }

  Future<void> _onUpdateGuest(
    UpdateGuest event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) return;

    emit(state.copyWith(actionStatus: GuestActionStatus.loading));

    final result = await _repository.updateGuest(
        state.weddingId!, event.guestId, event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: GuestActionStatus.error,
        actionError: failure.message,
      )),
      (guest) {
        emit(state.copyWith(
          actionStatus: GuestActionStatus.success,
          actionSuccessMessage: 'Guest updated successfully',
          selectedGuest: guest,
        ));
        // Refresh the list
        add(const RefreshGuests());
      },
    );
  }

  Future<void> _onDeleteGuest(
    DeleteGuest event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) return;

    emit(state.copyWith(actionStatus: GuestActionStatus.loading));

    final result =
        await _repository.deleteGuest(state.weddingId!, event.guestId);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: GuestActionStatus.error,
        actionError: failure.message,
      )),
      (_) {
        // Remove from local list
        final updatedGuests =
            state.guests.where((g) => g.id != event.guestId).toList();
        final updatedSelections = Set<String>.from(state.selectedGuestIds)
          ..remove(event.guestId);

        emit(state.copyWith(
          actionStatus: GuestActionStatus.success,
          actionSuccessMessage: 'Guest deleted',
          guests: updatedGuests,
          totalItems: state.totalItems - 1,
          selectedGuestIds: updatedSelections,
          clearSelectedGuest: true,
        ));
      },
    );
  }

  Future<void> _onUpdateRsvpStatus(
    UpdateRsvpStatus event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) return;

    emit(state.copyWith(actionStatus: GuestActionStatus.loading));

    final result = await _repository.updateRsvpStatus(
        state.weddingId!, event.guestId, event.status);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: GuestActionStatus.error,
        actionError: failure.message,
      )),
      (guest) {
        // Update in local list
        final updatedGuests = state.guests.map((g) {
          if (g.id == event.guestId) {
            return guest;
          }
          return g;
        }).toList();

        emit(state.copyWith(
          actionStatus: GuestActionStatus.success,
          actionSuccessMessage: 'RSVP status updated',
          guests: updatedGuests,
          selectedGuest: guest,
        ));
      },
    );
  }

  Future<void> _onSendInvitation(
    SendInvitation event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) return;

    emit(state.copyWith(actionStatus: GuestActionStatus.loading));

    final result =
        await _repository.sendInvitation(state.weddingId!, event.guestId);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: GuestActionStatus.error,
        actionError: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          actionStatus: GuestActionStatus.success,
          actionSuccessMessage: 'Invitation sent',
        ));
        // Refresh to update invitation status
        add(const RefreshGuests());
      },
    );
  }

  Future<void> _onSendBulkInvitations(
    SendBulkInvitations event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) return;

    emit(state.copyWith(actionStatus: GuestActionStatus.loading));

    final result = await _repository.sendBulkInvitations(
        state.weddingId!, event.guestIds);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: GuestActionStatus.error,
        actionError: failure.message,
      )),
      (_) {
        emit(state.copyWith(
          actionStatus: GuestActionStatus.success,
          actionSuccessMessage: '${event.guestIds.length} invitations sent',
          selectedGuestIds: {},
          isSelectionMode: false,
        ));
        // Refresh to update invitation statuses
        add(const RefreshGuests());
      },
    );
  }

  Future<void> _onLoadGuestStats(
    LoadGuestStats event,
    Emitter<GuestState> emit,
  ) async {
    if (!state.hasWeddingId) return;

    emit(state.copyWith(statsLoading: true));

    final result = await _repository.getGuestStats(state.weddingId!);

    result.fold(
      (failure) => emit(state.copyWith(statsLoading: false)),
      (stats) => emit(state.copyWith(
        statsLoading: false,
        stats: stats,
      )),
    );
  }

  void _onUpdateFilter(
    UpdateFilter event,
    Emitter<GuestState> emit,
  ) {
    add(LoadGuests(filter: event.filter.copyWith(page: 1)));
  }

  void _onClearFilter(
    ClearFilter event,
    Emitter<GuestState> emit,
  ) {
    add(const LoadGuests(filter: GuestFilter()));
  }

  void _onSearchGuests(
    SearchGuests event,
    Emitter<GuestState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      searchQuery: event.query,
      page: 1,
    );
    add(LoadGuests(filter: newFilter));
  }

  void _onToggleGuestSelection(
    ToggleGuestSelection event,
    Emitter<GuestState> emit,
  ) {
    final newSelections = Set<String>.from(state.selectedGuestIds);
    if (newSelections.contains(event.guestId)) {
      newSelections.remove(event.guestId);
    } else {
      newSelections.add(event.guestId);
    }

    emit(state.copyWith(
      selectedGuestIds: newSelections,
      isSelectionMode: newSelections.isNotEmpty,
    ));
  }

  void _onSelectAllGuests(
    SelectAllGuests event,
    Emitter<GuestState> emit,
  ) {
    final allIds = state.guests.map((g) => g.id).toSet();
    emit(state.copyWith(
      selectedGuestIds: allIds,
      isSelectionMode: true,
    ));
  }

  void _onClearSelections(
    ClearSelections event,
    Emitter<GuestState> emit,
  ) {
    emit(state.copyWith(
      selectedGuestIds: {},
      isSelectionMode: false,
    ));
  }

  void _onClearGuestError(
    ClearGuestError event,
    Emitter<GuestState> emit,
  ) {
    emit(state.copyWith(
      clearListError: true,
      clearDetailError: true,
      clearActionError: true,
      clearActionSuccess: true,
    ));
  }
}
