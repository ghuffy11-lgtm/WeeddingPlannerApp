import '../../domain/entities/wedding.dart';

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
    super.totalBudget,
    super.spentAmount,
    super.currency,
    super.theme,
    super.primaryColor,
    required super.createdAt,
  });

  /// Create from JSON
  factory WeddingModel.fromJson(Map<String, dynamic> json) {
    return WeddingModel(
      id: json['id'] as String,
      coupleId: json['couple_id'] as String? ?? json['user_id'] as String,
      partnerOneName: json['partner_one_name'] as String?,
      partnerTwoName: json['partner_two_name'] as String?,
      weddingDate: json['wedding_date'] != null
          ? DateTime.parse(json['wedding_date'] as String)
          : null,
      venueName: json['venue_name'] as String?,
      venueAddress: json['venue_address'] as String?,
      estimatedGuests: json['estimated_guests'] as int? ?? 0,
      totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0,
      spentAmount: (json['spent_amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      theme: json['theme'] as String?,
      primaryColor: json['primary_color'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couple_id': coupleId,
      'partner_one_name': partnerOneName,
      'partner_two_name': partnerTwoName,
      'wedding_date': weddingDate?.toIso8601String(),
      'venue_name': venueName,
      'venue_address': venueAddress,
      'estimated_guests': estimatedGuests,
      'total_budget': totalBudget,
      'spent_amount': spentAmount,
      'currency': currency,
      'theme': theme,
      'primary_color': primaryColor,
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
      totalBudget: wedding.totalBudget,
      spentAmount: wedding.spentAmount,
      currency: wedding.currency,
      theme: wedding.theme,
      primaryColor: wedding.primaryColor,
      createdAt: wedding.createdAt,
    );
  }
}
