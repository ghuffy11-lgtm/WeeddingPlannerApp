import '../../domain/entities/guest.dart';

class GuestSummaryModel extends GuestSummary {
  const GuestSummaryModel({
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
  });

  factory GuestSummaryModel.fromJson(Map<String, dynamic> json) {
    return GuestSummaryModel(
      id: json['id'] as String,
      firstName: (json['firstName'] ?? json['first_name'] ?? '') as String,
      lastName: (json['lastName'] ?? json['last_name'] ?? '') as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      rsvpStatus: _parseRsvpStatus(json['rsvpStatus'] ?? json['rsvp_status']),
      category: _parseCategory(json['category']),
      side: _parseSide(json['side']),
      plusOnes: (json['plusOnes'] ?? json['plus_ones'] ?? 0) as int,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'rsvpStatus': rsvpStatus.name,
        'category': category.name,
        'side': side.name,
        'plusOnes': plusOnes,
        'createdAt': createdAt.toIso8601String(),
      };

  static RsvpStatus _parseRsvpStatus(dynamic value) {
    if (value == null) return RsvpStatus.pending;
    final statusStr = value.toString().toLowerCase();
    return RsvpStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == statusStr,
      orElse: () => RsvpStatus.pending,
    );
  }

  static GuestCategory _parseCategory(dynamic value) {
    if (value == null) return GuestCategory.other;
    final categoryStr = value.toString().toLowerCase();
    return GuestCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == categoryStr,
      orElse: () => GuestCategory.other,
    );
  }

  static GuestSide _parseSide(dynamic value) {
    if (value == null) return GuestSide.both;
    final sideStr = value.toString().toLowerCase();
    return GuestSide.values.firstWhere(
      (s) => s.name.toLowerCase() == sideStr,
      orElse: () => GuestSide.both,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}

class GuestModel extends Guest {
  const GuestModel({
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
    super.address,
    super.notes,
    super.mealPreference,
    super.dietaryNotes,
    super.tableAssignment,
    super.invitationSent,
    super.invitationSentAt,
    super.rsvpRespondedAt,
    super.updatedAt,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'] as String,
      firstName: (json['firstName'] ?? json['first_name'] ?? '') as String,
      lastName: (json['lastName'] ?? json['last_name'] ?? '') as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      rsvpStatus: GuestSummaryModel._parseRsvpStatus(
          json['rsvpStatus'] ?? json['rsvp_status']),
      category: GuestSummaryModel._parseCategory(json['category']),
      side: GuestSummaryModel._parseSide(json['side']),
      plusOnes: (json['plusOnes'] ?? json['plus_ones'] ?? 0) as int,
      createdAt: GuestSummaryModel._parseDateTime(
          json['createdAt'] ?? json['created_at']),
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      mealPreference: _parseMealPreference(
          json['mealPreference'] ?? json['meal_preference']),
      dietaryNotes: (json['dietaryNotes'] ?? json['dietary_notes']) as String?,
      tableAssignment:
          (json['tableAssignment'] ?? json['table_assignment']) as String?,
      invitationSent:
          (json['invitationSent'] ?? json['invitation_sent'] ?? false) as bool,
      invitationSentAt: _parseNullableDateTime(
          json['invitationSentAt'] ?? json['invitation_sent_at']),
      rsvpRespondedAt: _parseNullableDateTime(
          json['rsvpRespondedAt'] ?? json['rsvp_responded_at']),
      updatedAt: _parseNullableDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'rsvpStatus': rsvpStatus.name,
        'category': category.name,
        'side': side.name,
        'plusOnes': plusOnes,
        'createdAt': createdAt.toIso8601String(),
        if (address != null) 'address': address,
        if (notes != null) 'notes': notes,
        'mealPreference': mealPreference.name,
        if (dietaryNotes != null) 'dietaryNotes': dietaryNotes,
        if (tableAssignment != null) 'tableAssignment': tableAssignment,
        'invitationSent': invitationSent,
        if (invitationSentAt != null)
          'invitationSentAt': invitationSentAt!.toIso8601String(),
        if (rsvpRespondedAt != null)
          'rsvpRespondedAt': rsvpRespondedAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  static MealPreference _parseMealPreference(dynamic value) {
    if (value == null) return MealPreference.standard;
    final prefStr = value.toString().toLowerCase();
    return MealPreference.values.firstWhere(
      (m) => m.name.toLowerCase() == prefStr,
      orElse: () => MealPreference.standard,
    );
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class GuestStatsModel extends GuestStats {
  const GuestStatsModel({
    required super.totalGuests,
    required super.confirmedGuests,
    required super.declinedGuests,
    required super.pendingGuests,
    required super.maybeGuests,
    required super.totalAttending,
    required super.byCategory,
    required super.bySide,
    required super.byMealPreference,
  });

  /// Returns an empty stats model (for when no wedding exists yet)
  factory GuestStatsModel.empty() {
    return const GuestStatsModel(
      totalGuests: 0,
      confirmedGuests: 0,
      declinedGuests: 0,
      pendingGuests: 0,
      maybeGuests: 0,
      totalAttending: 0,
      byCategory: {},
      bySide: {},
      byMealPreference: {},
    );
  }

  factory GuestStatsModel.fromJson(Map<String, dynamic> json) {
    return GuestStatsModel(
      totalGuests: (json['totalGuests'] ?? json['total_guests'] ?? 0) as int,
      confirmedGuests: (json['confirmedGuests'] ?? json['confirmed_guests'] ?? 0) as int,
      declinedGuests: (json['declinedGuests'] ?? json['declined_guests'] ?? 0) as int,
      pendingGuests: (json['pendingGuests'] ?? json['pending_guests'] ?? 0) as int,
      maybeGuests: (json['maybeGuests'] ?? json['maybe_guests'] ?? 0) as int,
      totalAttending: (json['totalAttending'] ?? json['total_attending'] ?? 0) as int,
      byCategory: _parseByCategory(json['byCategory'] ?? json['by_category']),
      bySide: _parseBySide(json['bySide'] ?? json['by_side']),
      byMealPreference: _parseByMealPreference(
          json['byMealPreference'] ?? json['by_meal_preference']),
    );
  }

  static Map<GuestCategory, int> _parseByCategory(dynamic value) {
    if (value == null) return {};
    final map = value as Map<String, dynamic>;
    return map.map((key, val) => MapEntry(
          GuestSummaryModel._parseCategory(key),
          val as int,
        ));
  }

  static Map<GuestSide, int> _parseBySide(dynamic value) {
    if (value == null) return {};
    final map = value as Map<String, dynamic>;
    return map.map((key, val) => MapEntry(
          GuestSummaryModel._parseSide(key),
          val as int,
        ));
  }

  static Map<MealPreference, int> _parseByMealPreference(dynamic value) {
    if (value == null) return {};
    final map = value as Map<String, dynamic>;
    return map.map((key, val) => MapEntry(
          GuestModel._parseMealPreference(key),
          val as int,
        ));
  }
}
