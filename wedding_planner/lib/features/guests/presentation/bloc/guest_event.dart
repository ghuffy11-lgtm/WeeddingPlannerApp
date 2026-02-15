import '../../domain/entities/guest.dart';
import '../../domain/repositories/guest_repository.dart';

abstract class GuestEvent {
  const GuestEvent();
}

/// Initialize with wedding ID - must be called before any other operations
class InitializeGuests extends GuestEvent {
  final String weddingId;

  const InitializeGuests(this.weddingId);
}

/// Load guests with filter
class LoadGuests extends GuestEvent {
  final GuestFilter filter;

  const LoadGuests({this.filter = const GuestFilter()});
}

/// Load more guests (pagination)
class LoadMoreGuests extends GuestEvent {
  const LoadMoreGuests();
}

/// Refresh guests list
class RefreshGuests extends GuestEvent {
  const RefreshGuests();
}

/// Load single guest details
class LoadGuestDetail extends GuestEvent {
  final String guestId;

  const LoadGuestDetail(this.guestId);
}

/// Create a new guest
class CreateGuest extends GuestEvent {
  final GuestRequest request;

  const CreateGuest(this.request);
}

/// Update a guest
class UpdateGuest extends GuestEvent {
  final String guestId;
  final GuestRequest request;

  const UpdateGuest({required this.guestId, required this.request});
}

/// Delete a guest
class DeleteGuest extends GuestEvent {
  final String guestId;

  const DeleteGuest(this.guestId);
}

/// Update RSVP status
class UpdateRsvpStatus extends GuestEvent {
  final String guestId;
  final RsvpStatus status;

  const UpdateRsvpStatus({required this.guestId, required this.status});
}

/// Send invitation to a guest
class SendInvitation extends GuestEvent {
  final String guestId;

  const SendInvitation(this.guestId);
}

/// Send invitations to multiple guests
class SendBulkInvitations extends GuestEvent {
  final List<String> guestIds;

  const SendBulkInvitations(this.guestIds);
}

/// Load guest statistics
class LoadGuestStats extends GuestEvent {
  const LoadGuestStats();
}

/// Update filter
class UpdateFilter extends GuestEvent {
  final GuestFilter filter;

  const UpdateFilter(this.filter);
}

/// Clear filter
class ClearFilter extends GuestEvent {
  const ClearFilter();
}

/// Search guests
class SearchGuests extends GuestEvent {
  final String query;

  const SearchGuests(this.query);
}

/// Toggle guest selection for bulk actions
class ToggleGuestSelection extends GuestEvent {
  final String guestId;

  const ToggleGuestSelection(this.guestId);
}

/// Select all guests
class SelectAllGuests extends GuestEvent {
  const SelectAllGuests();
}

/// Clear all selections
class ClearSelections extends GuestEvent {
  const ClearSelections();
}

/// Clear error
class ClearGuestError extends GuestEvent {
  const ClearGuestError();
}
