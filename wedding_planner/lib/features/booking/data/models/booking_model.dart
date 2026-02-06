import '../../domain/entities/booking.dart';

/// Booking vendor model for JSON serialization
class BookingVendorModel extends BookingVendor {
  const BookingVendorModel({
    required super.id,
    required super.businessName,
    super.categoryName,
    super.categoryIcon,
  });

  factory BookingVendorModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return BookingVendorModel(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
    );
  }
}

/// Booking package model for JSON serialization
class BookingPackageModel extends BookingPackage {
  const BookingPackageModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory BookingPackageModel.fromJson(Map<String, dynamic> json) {
    return BookingPackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}

/// Booking wedding model for JSON serialization
class BookingWeddingModel extends BookingWedding {
  const BookingWeddingModel({
    required super.id,
    required super.partner1Name,
    required super.partner2Name,
    super.weddingDate,
  });

  factory BookingWeddingModel.fromJson(Map<String, dynamic> json) {
    return BookingWeddingModel(
      id: json['id'] as String,
      partner1Name: json['partner1_name'] as String,
      partner2Name: json['partner2_name'] as String,
      weddingDate: json['wedding_date'] != null
          ? DateTime.parse(json['wedding_date'] as String)
          : null,
    );
  }
}

/// Booking summary model for JSON serialization
class BookingSummaryModel extends BookingSummary {
  const BookingSummaryModel({
    required super.id,
    required super.bookingDate,
    required super.status,
    super.totalAmount,
    super.vendor,
    super.package,
    required super.createdAt,
  });

  factory BookingSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookingSummaryModel(
      id: json['id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      status: _parseStatus(json['status'] as String),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      vendor: json['vendor'] != null
          ? BookingVendorModel.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
      package: json['package'] != null
          ? BookingPackageModel.fromJson(json['package'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'accepted':
        return BookingStatus.accepted;
      case 'declined':
        return BookingStatus.declined;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

/// Full booking model for JSON serialization
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.bookingDate,
    required super.status,
    super.totalAmount,
    super.vendor,
    super.package,
    required super.createdAt,
    super.coupleNotes,
    super.vendorNotes,
    super.commissionRate,
    super.commissionAmount,
    super.vendorPayout,
    super.wedding,
    super.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      status: BookingSummaryModel._parseStatus(json['status'] as String),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      vendor: json['vendor'] != null
          ? BookingVendorModel.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
      package: json['package'] != null
          ? BookingPackageModel.fromJson(json['package'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      coupleNotes: json['couple_notes'] as String?,
      vendorNotes: json['vendor_notes'] as String?,
      commissionRate: (json['commission_rate'] as num?)?.toDouble(),
      commissionAmount: (json['commission_amount'] as num?)?.toDouble(),
      vendorPayout: (json['vendor_payout'] as num?)?.toDouble(),
      wedding: json['wedding'] != null
          ? BookingWeddingModel.fromJson(json['wedding'] as Map<String, dynamic>)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
