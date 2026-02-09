import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Booking status enum (shared with booking feature)
enum VendorBookingStatus {
  pending,
  accepted,
  declined,
  confirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case VendorBookingStatus.pending:
        return 'Pending';
      case VendorBookingStatus.accepted:
        return 'Accepted';
      case VendorBookingStatus.declined:
        return 'Declined';
      case VendorBookingStatus.confirmed:
        return 'Confirmed';
      case VendorBookingStatus.completed:
        return 'Completed';
      case VendorBookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPending => this == VendorBookingStatus.pending;
  bool get isActive =>
      this == VendorBookingStatus.pending ||
      this == VendorBookingStatus.accepted ||
      this == VendorBookingStatus.confirmed;
  bool get canAccept => this == VendorBookingStatus.pending;
  bool get canDecline => this == VendorBookingStatus.pending;
  bool get canComplete =>
      this == VendorBookingStatus.accepted ||
      this == VendorBookingStatus.confirmed;
}

/// Couple info embedded in vendor booking
class BookingCouple extends Equatable {
  final String id;
  final String partner1Name;
  final String partner2Name;
  final String? email;
  final String? phone;

  const BookingCouple({
    required this.id,
    required this.partner1Name,
    required this.partner2Name,
    this.email,
    this.phone,
  });

  String get coupleNames => '$partner1Name & $partner2Name';

  @override
  List<Object?> get props => [id, partner1Name, partner2Name, email, phone];
}

/// Package info embedded in vendor booking
class BookingPackageInfo extends Equatable {
  final String id;
  final String name;
  final double price;

  const BookingPackageInfo({
    required this.id,
    required this.name,
    required this.price,
  });

  String get priceFormatted => '\$${price.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [id, name, price];
}

/// Vendor booking summary for list view
class VendorBookingSummary extends Equatable {
  final String id;
  final DateTime bookingDate;
  final VendorBookingStatus status;
  final double? totalAmount;
  final String coupleNames;
  final DateTime? weddingDate;
  final String? packageName;
  final DateTime createdAt;

  const VendorBookingSummary({
    required this.id,
    required this.bookingDate,
    required this.status,
    this.totalAmount,
    required this.coupleNames,
    this.weddingDate,
    this.packageName,
    required this.createdAt,
  });

  String get bookingDateFormatted =>
      DateFormat('MMM d, yyyy').format(bookingDate);

  String get weddingDateFormatted =>
      weddingDate != null ? DateFormat('MMM d, yyyy').format(weddingDate!) : '';

  String get totalAmountFormatted =>
      totalAmount != null ? '\$${totalAmount!.toStringAsFixed(0)}' : 'TBD';

  String get createdAtFormatted => DateFormat('MMM d, yyyy').format(createdAt);

  /// Time since booking was created
  String get timeSinceCreated {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }

  @override
  List<Object?> get props => [
        id,
        bookingDate,
        status,
        totalAmount,
        coupleNames,
        weddingDate,
        packageName,
        createdAt,
      ];
}

/// Full vendor booking entity with all details
class VendorBooking extends VendorBookingSummary {
  final String? coupleNotes;
  final String? vendorNotes;
  final double? commissionRate;
  final double? commissionAmount;
  final double? vendorPayout;
  final BookingCouple? couple;
  final BookingPackageInfo? package;
  final DateTime? updatedAt;

  const VendorBooking({
    required super.id,
    required super.bookingDate,
    required super.status,
    super.totalAmount,
    required super.coupleNames,
    super.weddingDate,
    super.packageName,
    required super.createdAt,
    this.coupleNotes,
    this.vendorNotes,
    this.commissionRate,
    this.commissionAmount,
    this.vendorPayout,
    this.couple,
    this.package,
    this.updatedAt,
  });

  /// Format vendor payout
  String get vendorPayoutFormatted =>
      vendorPayout != null ? '\$${vendorPayout!.toStringAsFixed(0)}' : 'TBD';

  /// Format commission
  String get commissionFormatted =>
      commissionAmount != null
          ? '\$${commissionAmount!.toStringAsFixed(0)}'
          : '';

  @override
  List<Object?> get props => [
        ...super.props,
        coupleNotes,
        vendorNotes,
        commissionRate,
        commissionAmount,
        vendorPayout,
        couple,
        package,
        updatedAt,
      ];
}

/// Request model for accepting a booking
class AcceptBookingRequest {
  final String? vendorNotes;

  const AcceptBookingRequest({this.vendorNotes});

  Map<String, dynamic> toJson() => {
        if (vendorNotes != null) 'vendorNotes': vendorNotes,
      };
}

/// Request model for declining a booking
class DeclineBookingRequest {
  final String reason;

  const DeclineBookingRequest({required this.reason});

  Map<String, dynamic> toJson() => {
        'reason': reason,
      };
}
