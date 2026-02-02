import 'package:equatable/equatable.dart';

/// Booking Status
enum BookingStatus {
  pending,
  confirmed,
  declined,
  completed,
  cancelled,
}

/// Booking Entity
class Booking extends Equatable {
  final String id;
  final String weddingId;
  final String vendorId;
  final String vendorName;
  final String vendorCategory;
  final String? vendorImage;
  final String? packageName;
  final double totalPrice;
  final double depositPaid;
  final BookingStatus status;
  final DateTime bookingDate;
  final DateTime? eventDate;
  final String? notes;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.weddingId,
    required this.vendorId,
    required this.vendorName,
    required this.vendorCategory,
    this.vendorImage,
    this.packageName,
    required this.totalPrice,
    this.depositPaid = 0,
    required this.status,
    required this.bookingDate,
    this.eventDate,
    this.notes,
    required this.createdAt,
  });

  /// Remaining balance
  double get remainingBalance => totalPrice - depositPaid;

  /// Is confirmed?
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Is pending?
  bool get isPending => status == BookingStatus.pending;

  @override
  List<Object?> get props => [
        id,
        weddingId,
        vendorId,
        vendorName,
        vendorCategory,
        vendorImage,
        packageName,
        totalPrice,
        depositPaid,
        status,
        bookingDate,
        eventDate,
        notes,
        createdAt,
      ];
}
