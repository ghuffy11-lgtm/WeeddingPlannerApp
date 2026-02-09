import 'package:equatable/equatable.dart';
import 'vendor_booking.dart';

/// Vendor dashboard stats and overview
class VendorDashboard extends Equatable {
  final int pendingBookings;
  final int acceptedBookings;
  final int completedBookings;
  final int totalBookings;
  final double totalEarnings;
  final double pendingEarnings;
  final double ratingAvg;
  final int reviewCount;
  final List<VendorBookingSummary> recentBookings;

  const VendorDashboard({
    this.pendingBookings = 0,
    this.acceptedBookings = 0,
    this.completedBookings = 0,
    this.totalBookings = 0,
    this.totalEarnings = 0,
    this.pendingEarnings = 0,
    this.ratingAvg = 0,
    this.reviewCount = 0,
    this.recentBookings = const [],
  });

  /// Earnings available for payout
  double get availableEarnings => totalEarnings - pendingEarnings;

  /// Active bookings (pending + accepted)
  int get activeBookings => pendingBookings + acceptedBookings;

  /// Format total earnings
  String get totalEarningsFormatted => '\$${totalEarnings.toStringAsFixed(0)}';

  /// Format pending earnings
  String get pendingEarningsFormatted => '\$${pendingEarnings.toStringAsFixed(0)}';

  /// Format rating
  String get ratingFormatted => ratingAvg.toStringAsFixed(1);

  @override
  List<Object?> get props => [
        pendingBookings,
        acceptedBookings,
        completedBookings,
        totalBookings,
        totalEarnings,
        pendingEarnings,
        ratingAvg,
        reviewCount,
        recentBookings,
      ];
}

/// Earnings summary for vendor
class VendorEarnings extends Equatable {
  final double totalEarnings;
  final double pendingEarnings;
  final double paidEarnings;
  final double thisMonthEarnings;
  final double lastMonthEarnings;
  final List<EarningsPeriod> monthlyEarnings;

  const VendorEarnings({
    this.totalEarnings = 0,
    this.pendingEarnings = 0,
    this.paidEarnings = 0,
    this.thisMonthEarnings = 0,
    this.lastMonthEarnings = 0,
    this.monthlyEarnings = const [],
  });

  /// Growth percentage compared to last month
  double get monthlyGrowth {
    if (lastMonthEarnings == 0) return 0;
    return ((thisMonthEarnings - lastMonthEarnings) / lastMonthEarnings) * 100;
  }

  @override
  List<Object?> get props => [
        totalEarnings,
        pendingEarnings,
        paidEarnings,
        thisMonthEarnings,
        lastMonthEarnings,
        monthlyEarnings,
      ];
}

/// Earnings for a specific period
class EarningsPeriod extends Equatable {
  final String period;
  final double amount;
  final int bookingsCount;

  const EarningsPeriod({
    required this.period,
    required this.amount,
    this.bookingsCount = 0,
  });

  @override
  List<Object?> get props => [period, amount, bookingsCount];
}
