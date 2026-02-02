import '../../domain/entities/booking.dart';

/// Booking Model for API serialization
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.weddingId,
    required super.vendorId,
    required super.vendorName,
    required super.vendorCategory,
    super.vendorImage,
    super.packageName,
    required super.totalPrice,
    super.depositPaid,
    required super.status,
    required super.bookingDate,
    super.eventDate,
    super.notes,
    required super.createdAt,
  });

  /// Create from JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Handle nested vendor object
    final vendor = json['vendor'] as Map<String, dynamic>?;

    return BookingModel(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      vendorId: json['vendor_id'] as String,
      vendorName: vendor?['business_name'] as String? ??
          json['vendor_name'] as String? ??
          'Unknown Vendor',
      vendorCategory: vendor?['category']?['name'] as String? ??
          json['vendor_category'] as String? ??
          'Service',
      vendorImage: vendor?['logo_url'] as String? ??
          json['vendor_image'] as String?,
      packageName: json['package']?['name'] as String? ??
          json['package_name'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      depositPaid: (json['deposit_paid'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status'] as String?),
      bookingDate: DateTime.parse(json['booking_date'] as String),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wedding_id': weddingId,
      'vendor_id': vendorId,
      'vendor_name': vendorName,
      'vendor_category': vendorCategory,
      'vendor_image': vendorImage,
      'package_name': packageName,
      'total_price': totalPrice,
      'deposit_paid': depositPaid,
      'status': status.name,
      'booking_date': bookingDate.toIso8601String(),
      'event_date': eventDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static BookingStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'declined':
        return BookingStatus.declined;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
