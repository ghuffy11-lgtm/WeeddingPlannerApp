import '../../domain/entities/vendor_booking.dart';

class BookingCoupleModel extends BookingCouple {
  const BookingCoupleModel({
    required super.id,
    required super.partner1Name,
    required super.partner2Name,
    super.email,
    super.phone,
  });

  factory BookingCoupleModel.fromJson(Map<String, dynamic> json) {
    return BookingCoupleModel(
      id: json['id'] as String,
      partner1Name: (json['partner1Name'] ?? json['partner1_name'] ?? '') as String,
      partner2Name: (json['partner2Name'] ?? json['partner2_name'] ?? '') as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'partner1Name': partner1Name,
        'partner2Name': partner2Name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      };
}

class BookingPackageInfoModel extends BookingPackageInfo {
  const BookingPackageInfoModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory BookingPackageInfoModel.fromJson(Map<String, dynamic> json) {
    return BookingPackageInfoModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: ((json['price'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };
}

class VendorBookingSummaryModel extends VendorBookingSummary {
  const VendorBookingSummaryModel({
    required super.id,
    required super.bookingDate,
    required super.status,
    super.totalAmount,
    required super.coupleNames,
    super.weddingDate,
    super.packageName,
    required super.createdAt,
  });

  factory VendorBookingSummaryModel.fromJson(Map<String, dynamic> json) {
    // Parse status
    final statusStr = (json['status'] as String?)?.toLowerCase() ?? 'pending';
    final status = VendorBookingStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == statusStr,
      orElse: () => VendorBookingStatus.pending,
    );

    // Parse couple names - could be from embedded couple object or direct field
    String coupleNames;
    if (json['couple'] != null) {
      final couple = json['couple'] as Map<String, dynamic>;
      final p1 = couple['partner1Name'] ?? couple['partner1_name'] ?? '';
      final p2 = couple['partner2Name'] ?? couple['partner2_name'] ?? '';
      coupleNames = '$p1 & $p2';
    } else if (json['wedding'] != null) {
      final wedding = json['wedding'] as Map<String, dynamic>;
      final p1 = wedding['partner1Name'] ?? wedding['partner1_name'] ?? '';
      final p2 = wedding['partner2Name'] ?? wedding['partner2_name'] ?? '';
      coupleNames = '$p1 & $p2';
    } else {
      coupleNames = (json['coupleNames'] ?? json['couple_names'] ?? 'Unknown') as String;
    }

    // Parse package name
    String? packageName;
    if (json['package'] != null) {
      packageName = (json['package'] as Map<String, dynamic>)['name'] as String?;
    } else {
      packageName = json['packageName'] as String?;
    }

    // Parse wedding date
    DateTime? weddingDate;
    if (json['wedding'] != null && json['wedding']['weddingDate'] != null) {
      weddingDate = DateTime.tryParse(json['wedding']['weddingDate'] as String);
    } else if (json['weddingDate'] != null) {
      weddingDate = DateTime.tryParse(json['weddingDate'] as String);
    }

    return VendorBookingSummaryModel(
      id: json['id'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] ?? json['booking_date'] as String),
      status: status,
      totalAmount: json['totalAmount'] != null
          ? ((json['totalAmount'] ?? json['total_amount']) as num).toDouble()
          : null,
      coupleNames: coupleNames,
      weddingDate: weddingDate,
      packageName: packageName,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingDate': bookingDate.toIso8601String(),
        'status': status.name,
        if (totalAmount != null) 'totalAmount': totalAmount,
        'coupleNames': coupleNames,
        if (weddingDate != null) 'weddingDate': weddingDate!.toIso8601String(),
        if (packageName != null) 'packageName': packageName,
        'createdAt': createdAt.toIso8601String(),
      };
}

class VendorBookingModel extends VendorBooking {
  const VendorBookingModel({
    required super.id,
    required super.bookingDate,
    required super.status,
    super.totalAmount,
    required super.coupleNames,
    super.weddingDate,
    super.packageName,
    required super.createdAt,
    super.coupleNotes,
    super.vendorNotes,
    super.commissionRate,
    super.commissionAmount,
    super.vendorPayout,
    super.couple,
    super.package,
    super.updatedAt,
  });

  factory VendorBookingModel.fromJson(Map<String, dynamic> json) {
    // Parse status
    final statusStr = (json['status'] as String?)?.toLowerCase() ?? 'pending';
    final status = VendorBookingStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == statusStr,
      orElse: () => VendorBookingStatus.pending,
    );

    // Parse couple
    BookingCoupleModel? couple;
    String coupleNames;
    if (json['couple'] != null) {
      couple = BookingCoupleModel.fromJson(json['couple'] as Map<String, dynamic>);
      coupleNames = couple.coupleNames;
    } else if (json['wedding'] != null) {
      final wedding = json['wedding'] as Map<String, dynamic>;
      final p1 = wedding['partner1Name'] ?? wedding['partner1_name'] ?? '';
      final p2 = wedding['partner2Name'] ?? wedding['partner2_name'] ?? '';
      coupleNames = '$p1 & $p2';
    } else {
      coupleNames = (json['coupleNames'] ?? json['couple_names'] ?? 'Unknown') as String;
    }

    // Parse package
    BookingPackageInfoModel? package;
    String? packageName;
    if (json['package'] != null) {
      package = BookingPackageInfoModel.fromJson(json['package'] as Map<String, dynamic>);
      packageName = package.name;
    } else {
      packageName = json['packageName'] as String?;
    }

    // Parse wedding date
    DateTime? weddingDate;
    if (json['wedding'] != null && json['wedding']['weddingDate'] != null) {
      weddingDate = DateTime.tryParse(json['wedding']['weddingDate'] as String);
    } else if (json['weddingDate'] != null) {
      weddingDate = DateTime.tryParse(json['weddingDate'] as String);
    }

    return VendorBookingModel(
      id: json['id'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] ?? json['booking_date'] as String),
      status: status,
      totalAmount: json['totalAmount'] != null
          ? ((json['totalAmount'] ?? json['total_amount']) as num).toDouble()
          : null,
      coupleNames: coupleNames,
      weddingDate: weddingDate,
      packageName: packageName,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] as String),
      coupleNotes: (json['coupleNotes'] ?? json['couple_notes']) as String?,
      vendorNotes: (json['vendorNotes'] ?? json['vendor_notes']) as String?,
      commissionRate: json['commissionRate'] != null
          ? ((json['commissionRate'] ?? json['commission_rate']) as num).toDouble()
          : null,
      commissionAmount: json['commissionAmount'] != null
          ? ((json['commissionAmount'] ?? json['commission_amount']) as num).toDouble()
          : null,
      vendorPayout: json['vendorPayout'] != null
          ? ((json['vendorPayout'] ?? json['vendor_payout']) as num).toDouble()
          : null,
      couple: couple,
      package: package,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingDate': bookingDate.toIso8601String(),
        'status': status.name,
        if (totalAmount != null) 'totalAmount': totalAmount,
        'coupleNames': coupleNames,
        if (weddingDate != null) 'weddingDate': weddingDate!.toIso8601String(),
        if (packageName != null) 'packageName': packageName,
        'createdAt': createdAt.toIso8601String(),
        if (coupleNotes != null) 'coupleNotes': coupleNotes,
        if (vendorNotes != null) 'vendorNotes': vendorNotes,
        if (commissionRate != null) 'commissionRate': commissionRate,
        if (commissionAmount != null) 'commissionAmount': commissionAmount,
        if (vendorPayout != null) 'vendorPayout': vendorPayout,
        if (couple != null) 'couple': (couple as BookingCoupleModel).toJson(),
        if (package != null) 'package': (package as BookingPackageInfoModel).toJson(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
