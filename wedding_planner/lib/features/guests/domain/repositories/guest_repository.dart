import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/guest.dart';

/// Filter options for guest list
class GuestFilter {
  final RsvpStatus? rsvpStatus;
  final GuestCategory? category;
  final GuestSide? side;
  final String? searchQuery;
  final int page;
  final int limit;

  const GuestFilter({
    this.rsvpStatus,
    this.category,
    this.side,
    this.searchQuery,
    this.page = 1,
    this.limit = 50,
  });

  GuestFilter copyWith({
    RsvpStatus? rsvpStatus,
    GuestCategory? category,
    GuestSide? side,
    String? searchQuery,
    int? page,
    int? limit,
    bool clearRsvpStatus = false,
    bool clearCategory = false,
    bool clearSide = false,
    bool clearSearchQuery = false,
  }) {
    return GuestFilter(
      rsvpStatus: clearRsvpStatus ? null : (rsvpStatus ?? this.rsvpStatus),
      category: clearCategory ? null : (category ?? this.category),
      side: clearSide ? null : (side ?? this.side),
      searchQuery:
          clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  bool get hasFilters =>
      rsvpStatus != null ||
      category != null ||
      side != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

/// Paginated result for guests
class PaginatedGuests {
  final List<GuestSummary> guests;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedGuests({
    required this.guests,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
}

/// Guest request for creating/updating guests
class GuestRequest {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final GuestCategory category;
  final GuestSide side;
  final int plusOnes;
  final String? dietaryRestrictions;
  final MealPreference? mealPreference;
  final String? tableAssignment;
  final String? notes;

  const GuestRequest({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    required this.category,
    required this.side,
    this.plusOnes = 0,
    this.dietaryRestrictions,
    this.mealPreference,
    this.tableAssignment,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'category': category.name,
        'side': side.name,
        'plusOnes': plusOnes,
        if (dietaryRestrictions != null)
          'dietaryRestrictions': dietaryRestrictions,
        if (mealPreference != null) 'mealPreference': mealPreference!.name,
        if (tableAssignment != null) 'tableAssignment': tableAssignment,
        if (notes != null) 'notes': notes,
      };
}

/// Guest repository interface
abstract class GuestRepository {
  /// Get wedding's guests with optional filter
  /// [weddingId] is required - get from HomeRepository.getWedding()
  Future<Either<Failure, PaginatedGuests>> getGuests(
      String weddingId, GuestFilter filter);

  /// Get single guest details
  Future<Either<Failure, Guest>> getGuest(String weddingId, String id);

  /// Create a new guest
  Future<Either<Failure, Guest>> createGuest(
      String weddingId, GuestRequest request);

  /// Update a guest
  Future<Either<Failure, Guest>> updateGuest(
      String weddingId, String id, GuestRequest request);

  /// Delete a guest
  Future<Either<Failure, void>> deleteGuest(String weddingId, String id);

  /// Update guest RSVP status
  Future<Either<Failure, Guest>> updateRsvpStatus(
      String weddingId, String id, RsvpStatus status);

  /// Send invitation to guest
  Future<Either<Failure, void>> sendInvitation(String weddingId, String id);

  /// Send invitation to multiple guests
  Future<Either<Failure, void>> sendBulkInvitations(
      String weddingId, List<String> guestIds);

  /// Get guest statistics
  Future<Either<Failure, GuestStats>> getGuestStats(String weddingId);

  /// Import guests from CSV
  Future<Either<Failure, List<Guest>>> importGuests(
      String weddingId, String csvData);

  /// Export guests to CSV
  Future<Either<Failure, String>> exportGuests(String weddingId);
}
