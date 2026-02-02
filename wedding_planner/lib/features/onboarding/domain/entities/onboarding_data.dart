import 'package:equatable/equatable.dart';

/// Onboarding Data Entity
/// Holds all data collected during couple onboarding
class OnboardingData extends Equatable {
  final DateTime? weddingDate;
  final bool hasWeddingDate;
  final double? budget;
  final String currency;
  final int? guestCount;
  final List<WeddingStyle> styles;
  final List<CulturalTradition> traditions;

  const OnboardingData({
    this.weddingDate,
    this.hasWeddingDate = true,
    this.budget,
    this.currency = 'USD',
    this.guestCount,
    this.styles = const [],
    this.traditions = const [],
  });

  OnboardingData copyWith({
    DateTime? weddingDate,
    bool? hasWeddingDate,
    double? budget,
    String? currency,
    int? guestCount,
    List<WeddingStyle>? styles,
    List<CulturalTradition>? traditions,
  }) {
    return OnboardingData(
      weddingDate: weddingDate ?? this.weddingDate,
      hasWeddingDate: hasWeddingDate ?? this.hasWeddingDate,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      guestCount: guestCount ?? this.guestCount,
      styles: styles ?? this.styles,
      traditions: traditions ?? this.traditions,
    );
  }

  @override
  List<Object?> get props => [
        weddingDate,
        hasWeddingDate,
        budget,
        currency,
        guestCount,
        styles,
        traditions,
      ];
}

/// Wedding Style Options
enum WeddingStyle {
  romantic,
  modern,
  traditional,
  bohemian,
  rustic,
  glamorous,
}

extension WeddingStyleExtension on WeddingStyle {
  String get displayName {
    switch (this) {
      case WeddingStyle.romantic:
        return 'Romantic';
      case WeddingStyle.modern:
        return 'Modern';
      case WeddingStyle.traditional:
        return 'Traditional';
      case WeddingStyle.bohemian:
        return 'Bohemian';
      case WeddingStyle.rustic:
        return 'Rustic';
      case WeddingStyle.glamorous:
        return 'Glamorous';
    }
  }

  String get emoji {
    switch (this) {
      case WeddingStyle.romantic:
        return '💕';
      case WeddingStyle.modern:
        return '✨';
      case WeddingStyle.traditional:
        return '👑';
      case WeddingStyle.bohemian:
        return '🌸';
      case WeddingStyle.rustic:
        return '🌿';
      case WeddingStyle.glamorous:
        return '💎';
    }
  }
}

/// Cultural Tradition Options
enum CulturalTradition {
  western,
  islamic,
  hindu,
  jewish,
  chinese,
  african,
  latinAmerican,
  custom,
}

extension CulturalTraditionExtension on CulturalTradition {
  String get displayName {
    switch (this) {
      case CulturalTradition.western:
        return 'Western';
      case CulturalTradition.islamic:
        return 'Islamic';
      case CulturalTradition.hindu:
        return 'Hindu';
      case CulturalTradition.jewish:
        return 'Jewish';
      case CulturalTradition.chinese:
        return 'Chinese';
      case CulturalTradition.african:
        return 'African';
      case CulturalTradition.latinAmerican:
        return 'Latin American';
      case CulturalTradition.custom:
        return 'Custom / Other';
    }
  }
}
