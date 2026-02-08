import 'package:intl/intl.dart';

/// RSVP status enum
enum RsvpStatus {
  pending,
  confirmed,
  declined,
  maybe;

  String get displayName {
    switch (this) {
      case RsvpStatus.pending:
        return 'Pending';
      case RsvpStatus.confirmed:
        return 'Confirmed';
      case RsvpStatus.declined:
        return 'Declined';
      case RsvpStatus.maybe:
        return 'Maybe';
    }
  }

  String get emoji {
    switch (this) {
      case RsvpStatus.pending:
        return '⏳';
      case RsvpStatus.confirmed:
        return '✓';
      case RsvpStatus.declined:
        return '✗';
      case RsvpStatus.maybe:
        return '?';
    }
  }
}

/// Guest category/group enum
enum GuestCategory {
  family,
  friends,
  coworkers,
  neighbors,
  other;

  String get displayName {
    switch (this) {
      case GuestCategory.family:
        return 'Family';
      case GuestCategory.friends:
        return 'Friends';
      case GuestCategory.coworkers:
        return 'Coworkers';
      case GuestCategory.neighbors:
        return 'Neighbors';
      case GuestCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case GuestCategory.family:
        return '👨‍👩‍👧‍👦';
      case GuestCategory.friends:
        return '👫';
      case GuestCategory.coworkers:
        return '💼';
      case GuestCategory.neighbors:
        return '🏠';
      case GuestCategory.other:
        return '👤';
    }
  }
}

/// Meal preference enum
enum MealPreference {
  standard,
  vegetarian,
  vegan,
  glutenFree,
  halal,
  kosher,
  other;

  String get displayName {
    switch (this) {
      case MealPreference.standard:
        return 'Standard';
      case MealPreference.vegetarian:
        return 'Vegetarian';
      case MealPreference.vegan:
        return 'Vegan';
      case MealPreference.glutenFree:
        return 'Gluten-Free';
      case MealPreference.halal:
        return 'Halal';
      case MealPreference.kosher:
        return 'Kosher';
      case MealPreference.other:
        return 'Other';
    }
  }
}

/// Guest side (bride/groom)
enum GuestSide {
  bride,
  groom,
  both;

  String get displayName {
    switch (this) {
      case GuestSide.bride:
        return 'Bride\'s Side';
      case GuestSide.groom:
        return 'Groom\'s Side';
      case GuestSide.both:
        return 'Both';
    }
  }
}

/// Guest entity for list view
class GuestSummary {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final RsvpStatus rsvpStatus;
  final GuestCategory category;
  final GuestSide side;
  final int plusOnes;
  final DateTime createdAt;

  const GuestSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    required this.rsvpStatus,
    required this.category,
    required this.side,
    this.plusOnes = 0,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  int get totalAttending => rsvpStatus == RsvpStatus.confirmed ? 1 + plusOnes : 0;

  String get createdAtFormatted => DateFormat('MMM d, yyyy').format(createdAt);
}

/// Full guest entity with all details
class Guest extends GuestSummary {
  final String? address;
  final String? notes;
  final MealPreference mealPreference;
  final String? dietaryNotes;
  final String? tableAssignment;
  final bool invitationSent;
  final DateTime? invitationSentAt;
  final DateTime? rsvpRespondedAt;
  final DateTime? updatedAt;

  const Guest({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,
    super.phone,
    required super.rsvpStatus,
    required super.category,
    required super.side,
    super.plusOnes,
    required super.createdAt,
    this.address,
    this.notes,
    this.mealPreference = MealPreference.standard,
    this.dietaryNotes,
    this.tableAssignment,
    this.invitationSent = false,
    this.invitationSentAt,
    this.rsvpRespondedAt,
    this.updatedAt,
  });

  String? get rsvpRespondedAtFormatted => rsvpRespondedAt != null
      ? DateFormat('MMM d, yyyy').format(rsvpRespondedAt!)
      : null;

  String? get invitationSentAtFormatted => invitationSentAt != null
      ? DateFormat('MMM d, yyyy').format(invitationSentAt!)
      : null;
}

/// Request model for creating/updating a guest
class GuestRequest {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final GuestCategory category;
  final GuestSide side;
  final int plusOnes;
  final MealPreference mealPreference;
  final String? dietaryNotes;
  final String? notes;

  const GuestRequest({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    required this.category,
    required this.side,
    this.plusOnes = 0,
    this.mealPreference = MealPreference.standard,
    this.dietaryNotes,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        'category': category.name,
        'side': side.name,
        'plusOnes': plusOnes,
        'mealPreference': mealPreference.name,
        if (dietaryNotes != null) 'dietaryNotes': dietaryNotes,
        if (notes != null) 'notes': notes,
      };
}

/// Guest statistics
class GuestStats {
  final int totalGuests;
  final int confirmedGuests;
  final int declinedGuests;
  final int pendingGuests;
  final int maybeGuests;
  final int totalAttending; // Includes plus ones
  final Map<GuestCategory, int> byCategory;
  final Map<GuestSide, int> bySide;
  final Map<MealPreference, int> byMealPreference;

  const GuestStats({
    required this.totalGuests,
    required this.confirmedGuests,
    required this.declinedGuests,
    required this.pendingGuests,
    required this.maybeGuests,
    required this.totalAttending,
    required this.byCategory,
    required this.bySide,
    required this.byMealPreference,
  });

  double get confirmationRate =>
      totalGuests > 0 ? confirmedGuests / totalGuests * 100 : 0;

  int get awaitingResponse => pendingGuests + maybeGuests;
}
