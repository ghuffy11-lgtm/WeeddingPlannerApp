import '../../domain/entities/guest.dart';
import '../../domain/repositories/guest_repository.dart';

enum GuestListStatus { initial, loading, loaded, loadingMore, error }

enum GuestDetailStatus { initial, loading, loaded, error }

enum GuestActionStatus { initial, loading, success, error }

class GuestState {
  // List state
  final GuestListStatus listStatus;
  final List<GuestSummary> guests;
  final GuestFilter filter;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final String? listError;

  // Detail state
  final GuestDetailStatus detailStatus;
  final Guest? selectedGuest;
  final String? detailError;

  // Action state (create, update, delete)
  final GuestActionStatus actionStatus;
  final String? actionError;
  final String? actionSuccessMessage;

  // Stats
  final GuestStats? stats;
  final bool statsLoading;

  // Selection state for bulk actions
  final Set<String> selectedGuestIds;
  final bool isSelectionMode;

  const GuestState({
    this.listStatus = GuestListStatus.initial,
    this.guests = const [],
    this.filter = const GuestFilter(),
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = false,
    this.listError,
    this.detailStatus = GuestDetailStatus.initial,
    this.selectedGuest,
    this.detailError,
    this.actionStatus = GuestActionStatus.initial,
    this.actionError,
    this.actionSuccessMessage,
    this.stats,
    this.statsLoading = false,
    this.selectedGuestIds = const {},
    this.isSelectionMode = false,
  });

  GuestState copyWith({
    GuestListStatus? listStatus,
    List<GuestSummary>? guests,
    GuestFilter? filter,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    String? listError,
    bool clearListError = false,
    GuestDetailStatus? detailStatus,
    Guest? selectedGuest,
    String? detailError,
    bool clearDetailError = false,
    bool clearSelectedGuest = false,
    GuestActionStatus? actionStatus,
    String? actionError,
    String? actionSuccessMessage,
    bool clearActionError = false,
    bool clearActionSuccess = false,
    GuestStats? stats,
    bool? statsLoading,
    Set<String>? selectedGuestIds,
    bool? isSelectionMode,
  }) {
    return GuestState(
      listStatus: listStatus ?? this.listStatus,
      guests: guests ?? this.guests,
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      listError: clearListError ? null : (listError ?? this.listError),
      detailStatus: detailStatus ?? this.detailStatus,
      selectedGuest:
          clearSelectedGuest ? null : (selectedGuest ?? this.selectedGuest),
      detailError:
          clearDetailError ? null : (detailError ?? this.detailError),
      actionStatus: actionStatus ?? this.actionStatus,
      actionError:
          clearActionError ? null : (actionError ?? this.actionError),
      actionSuccessMessage: clearActionSuccess
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
      stats: stats ?? this.stats,
      statsLoading: statsLoading ?? this.statsLoading,
      selectedGuestIds: selectedGuestIds ?? this.selectedGuestIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  // Computed properties
  int get confirmedCount =>
      guests.where((g) => g.rsvpStatus == RsvpStatus.confirmed).length;

  int get pendingCount =>
      guests.where((g) => g.rsvpStatus == RsvpStatus.pending).length;

  int get declinedCount =>
      guests.where((g) => g.rsvpStatus == RsvpStatus.declined).length;

  int get totalAttendingCount =>
      guests.where((g) => g.rsvpStatus == RsvpStatus.confirmed).fold(
            0,
            (sum, g) => sum + g.totalAttending,
          );

  bool get hasSelectedGuests => selectedGuestIds.isNotEmpty;

  int get selectedCount => selectedGuestIds.length;

  List<GuestSummary> get selectedGuestsList =>
      guests.where((g) => selectedGuestIds.contains(g.id)).toList();
}
