import '../../domain/entities/wedding.dart';

/// Helper to parse double from either String or num
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Wedding Model for API serialization
class WeddingModel extends Wedding {
  const WeddingModel({
    required super.id,
    required super.coupleId,
    super.partnerOneName,
    super.partnerTwoName,
    super.weddingDate,
    super.venueName,
    super.venueAddress,
    super.estimatedGuests,
    super.guestCountExpected,
    super.totalBudget,
    super.spentAmount,
    super.currency,
    super.theme,
    super.primaryColor,
    super.stylePreferences,
    super.culturalTraditions,
    super.region,
    required super.createdAt,
  });

  /// Create from JSON
  factory WeddingModel.fromJson(Map<String, dynamic> json) {
    return WeddingModel(
      id: json['id'] as String,
      coupleId: json['couple_id'] as String? ?? json['user_id'] as String,
      partnerOneName: json['partner1_name'] as String? ?? json['partner_one_name'] as String?,
      partnerTwoName: json['partner2_name'] as String? ?? json['partner_two_name'] as String?,
      weddingDate: json['wedding_date'] != null
          ? DateTime.parse(json['wedding_date'] as String)
          : null,
      venueName: json['venue_name'] as String?,
      venueAddress: json['venue_address'] as String?,
      estimatedGuests: json['estimated_guests'] as int? ?? 0,
      guestCountExpected: json['guest_count_expected'] as int?,
      totalBudget: _parseDouble(json['budget_total']) ??
          _parseDouble(json['total_budget']) ??
          0,
      spentAmount: _parseDouble(json['spent_amount']) ??
          _parseDouble(json['budget_spent']) ??
          0,
      currency: json['currency'] as String? ?? 'USD',
      theme: json['theme'] as String?,
      primaryColor: json['primary_color'] as String?,
      stylePreferences: (json['style_preferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      culturalTraditions: (json['cultural_traditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      region: json['region'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'partner1_name': partnerOneName,
      'partner2_name': partnerTwoName,
      'wedding_date': weddingDate?.toIso8601String(),
      'venue_name': venueName,
      'venue_address': venueAddress,
      'estimated_guests': estimatedGuests,
      'guest_count_expected': guestCountExpected,
      'budget_total': totalBudget,
      'spent_amount': spentAmount,
      'currency': currency,
      'theme': theme,
      'primary_color': primaryColor,
      'style_preferences': stylePreferences,
      'cultural_traditions': culturalTraditions,
      'region': region,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory WeddingModel.fromEntity(Wedding wedding) {
    return WeddingModel(
      id: wedding.id,
      coupleId: wedding.coupleId,
      partnerOneName: wedding.partnerOneName,
      partnerTwoName: wedding.partnerTwoName,
      weddingDate: wedding.weddingDate,
      venueName: wedding.venueName,
      venueAddress: wedding.venueAddress,
      estimatedGuests: wedding.estimatedGuests,
      guestCountExpected: wedding.guestCountExpected,
      totalBudget: wedding.totalBudget,
      spentAmount: wedding.spentAmount,
      currency: wedding.currency,
      theme: wedding.theme,
      primaryColor: wedding.primaryColor,
      stylePreferences: wedding.stylePreferences,
      culturalTraditions: wedding.culturalTraditions,
      region: wedding.region,
      createdAt: wedding.createdAt,
    );
  }
}
