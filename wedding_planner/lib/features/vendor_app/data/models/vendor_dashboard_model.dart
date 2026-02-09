import '../../domain/entities/vendor_dashboard.dart';
import 'vendor_booking_model.dart';

class VendorDashboardModel extends VendorDashboard {
  const VendorDashboardModel({
    super.pendingBookings,
    super.acceptedBookings,
    super.completedBookings,
    super.totalBookings,
    super.totalEarnings,
    super.pendingEarnings,
    super.ratingAvg,
    super.reviewCount,
    super.recentBookings,
  });

  factory VendorDashboardModel.fromJson(Map<String, dynamic> json) {
    final recentBookingsData = json['recentBookings'] as List<dynamic>?;
    final recentBookings = recentBookingsData
            ?.map((item) =>
                VendorBookingSummaryModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return VendorDashboardModel(
      pendingBookings: (json['pendingBookings'] ?? json['pending_bookings'] ?? 0) as int,
      acceptedBookings: (json['acceptedBookings'] ?? json['accepted_bookings'] ?? 0) as int,
      completedBookings: (json['completedBookings'] ?? json['completed_bookings'] ?? 0) as int,
      totalBookings: (json['totalBookings'] ?? json['total_bookings'] ?? 0) as int,
      totalEarnings: ((json['totalEarnings'] ?? json['total_earnings'] ?? 0) as num).toDouble(),
      pendingEarnings: ((json['pendingEarnings'] ?? json['pending_earnings'] ?? 0) as num).toDouble(),
      ratingAvg: ((json['ratingAvg'] ?? json['rating_avg'] ?? 0) as num).toDouble(),
      reviewCount: (json['reviewCount'] ?? json['review_count'] ?? 0) as int,
      recentBookings: recentBookings,
    );
  }

  Map<String, dynamic> toJson() => {
        'pendingBookings': pendingBookings,
        'acceptedBookings': acceptedBookings,
        'completedBookings': completedBookings,
        'totalBookings': totalBookings,
        'totalEarnings': totalEarnings,
        'pendingEarnings': pendingEarnings,
        'ratingAvg': ratingAvg,
        'reviewCount': reviewCount,
        'recentBookings': recentBookings
            .map((b) => (b as VendorBookingSummaryModel).toJson())
            .toList(),
      };
}

class VendorEarningsModel extends VendorEarnings {
  const VendorEarningsModel({
    super.totalEarnings,
    super.pendingEarnings,
    super.paidEarnings,
    super.thisMonthEarnings,
    super.lastMonthEarnings,
    super.monthlyEarnings,
  });

  factory VendorEarningsModel.fromJson(Map<String, dynamic> json) {
    final monthlyData = json['monthlyEarnings'] as List<dynamic>?;
    final monthlyEarnings = monthlyData
            ?.map((item) =>
                EarningsPeriodModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return VendorEarningsModel(
      totalEarnings: ((json['totalEarnings'] ?? json['total_earnings'] ?? 0) as num).toDouble(),
      pendingEarnings: ((json['pendingEarnings'] ?? json['pending_earnings'] ?? 0) as num).toDouble(),
      paidEarnings: ((json['paidEarnings'] ?? json['paid_earnings'] ?? 0) as num).toDouble(),
      thisMonthEarnings: ((json['thisMonthEarnings'] ?? json['this_month_earnings'] ?? 0) as num).toDouble(),
      lastMonthEarnings: ((json['lastMonthEarnings'] ?? json['last_month_earnings'] ?? 0) as num).toDouble(),
      monthlyEarnings: monthlyEarnings,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalEarnings': totalEarnings,
        'pendingEarnings': pendingEarnings,
        'paidEarnings': paidEarnings,
        'thisMonthEarnings': thisMonthEarnings,
        'lastMonthEarnings': lastMonthEarnings,
        'monthlyEarnings': monthlyEarnings
            .map((e) => (e as EarningsPeriodModel).toJson())
            .toList(),
      };
}

class EarningsPeriodModel extends EarningsPeriod {
  const EarningsPeriodModel({
    required super.period,
    required super.amount,
    super.bookingsCount,
  });

  factory EarningsPeriodModel.fromJson(Map<String, dynamic> json) {
    return EarningsPeriodModel(
      period: json['period'] as String,
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      bookingsCount: (json['bookingsCount'] ?? json['bookings_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'amount': amount,
        'bookingsCount': bookingsCount,
      };
}
