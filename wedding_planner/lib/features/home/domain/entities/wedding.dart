import 'package:equatable/equatable.dart';

/// Wedding Entity
class Wedding extends Equatable {
  final String id;
  final String coupleId;
  final String? partnerOneName;
  final String? partnerTwoName;
  final DateTime? weddingDate;
  final String? venueName;
  final String? venueAddress;
  final int estimatedGuests;
  final double totalBudget;
  final double spentAmount;
  final String currency;
  final String? theme;
  final String? primaryColor;
  final DateTime createdAt;

  const Wedding({
    required this.id,
    required this.coupleId,
    this.partnerOneName,
    this.partnerTwoName,
    this.weddingDate,
    this.venueName,
    this.venueAddress,
    this.estimatedGuests = 0,
    this.totalBudget = 0,
    this.spentAmount = 0,
    this.currency = 'USD',
    this.theme,
    this.primaryColor,
    required this.createdAt,
  });

  /// Days until wedding
  int? get daysUntilWedding {
    if (weddingDate == null) return null;
    final now = DateTime.now();
    return weddingDate!.difference(now).inDays;
  }

  /// Budget remaining
  double get budgetRemaining => totalBudget - spentAmount;

  /// Budget percentage spent
  double get budgetPercentageSpent {
    if (totalBudget == 0) return 0;
    return (spentAmount / totalBudget) * 100;
  }

  /// Couple display name
  String get coupleDisplayName {
    if (partnerOneName != null && partnerTwoName != null) {
      return '$partnerOneName & $partnerTwoName';
    }
    return partnerOneName ?? partnerTwoName ?? 'Your Wedding';
  }

  @override
  List<Object?> get props => [
        id,
        coupleId,
        partnerOneName,
        partnerTwoName,
        weddingDate,
        venueName,
        venueAddress,
        estimatedGuests,
        totalBudget,
        spentAmount,
        currency,
        theme,
        primaryColor,
        createdAt,
      ];
}
