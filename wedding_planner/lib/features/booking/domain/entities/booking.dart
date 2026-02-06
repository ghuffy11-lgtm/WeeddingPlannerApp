import 'package:intl/intl.dart';

/// Booking status enum
enum BookingStatus {
  pending,
  accepted,
  declined,
  confirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.declined:
        return 'Declined';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive =>
      this == BookingStatus.pending ||
      this == BookingStatus.accepted ||
      this == BookingStatus.confirmed;

  bool get canCancel =>
      this == BookingStatus.pending || this == BookingStatus.accepted;

  bool get canReview => this == BookingStatus.completed;
}

/// Vendor info embedded in booking
class BookingVendor {
  final String id;
  final String businessName;
  final String? categoryName;
  final String? categoryIcon;

  const BookingVendor({
    required this.id,
    required this.businessName,
    this.categoryName,
    this.categoryIcon,
  });
}

/// Package info embedded in booking
class BookingPackage {
  final String id;
  final String name;
  final double price;

  const BookingPackage({
    required this.id,
    required this.name,
    required this.price,
  });

  String get priceFormatted => '\$${price.toStringAsFixed(0)}';
}

/// Wedding info embedded in booking
class BookingWedding {
  final String id;
  final String partner1Name;
  final String partner2Name;
  final DateTime? weddingDate;

  const BookingWedding({
    required this.id,
    required this.partner1Name,
    required this.partner2Name,
    this.weddingDate,
  });

  String get coupleNames => '$partner1Name & $partner2Name';
}

/// Booking entity for list view
class BookingSummary {
  final String id;
  final DateTime bookingDate;
  final BookingStatus status;
  final double? totalAmount;
  final BookingVendor? vendor;
  final BookingPackage? package;
  final DateTime createdAt;

  const BookingSummary({
    required this.id,
    required this.bookingDate,
    required this.status,
    this.totalAmount,
    this.vendor,
    this.package,
    required this.createdAt,
  });

  String get bookingDateFormatted =>
      DateFormat('MMM d, yyyy').format(bookingDate);

  String get totalAmountFormatted =>
      totalAmount != null ? '\$${totalAmount!.toStringAsFixed(0)}' : 'TBD';

  String get createdAtFormatted =>
      DateFormat('MMM d, yyyy').format(createdAt);
}

/// Full booking entity with all details
class Booking extends BookingSummary {
  final String? coupleNotes;
  final String? vendorNotes;
  final double? commissionRate;
  final double? commissionAmount;
  final double? vendorPayout;
  final BookingWedding? wedding;
  final DateTime? updatedAt;

  const Booking({
    required super.id,
    required super.bookingDate,
    required super.status,
    super.totalAmount,
    super.vendor,
    super.package,
    required super.createdAt,
    this.coupleNotes,
    this.vendorNotes,
    this.commissionRate,
    this.commissionAmount,
    this.vendorPayout,
    this.wedding,
    this.updatedAt,
  });
}

/// Request model for creating a booking
class CreateBookingRequest {
  final String vendorId;
  final String? packageId;
  final DateTime bookingDate;
  final String? notes;

  const CreateBookingRequest({
    required this.vendorId,
    this.packageId,
    required this.bookingDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'vendorId': vendorId,
        if (packageId != null) 'packageId': packageId,
        'bookingDate': bookingDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}
