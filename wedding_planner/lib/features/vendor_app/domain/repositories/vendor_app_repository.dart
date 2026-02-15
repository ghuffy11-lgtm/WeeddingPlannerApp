import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../vendors/domain/entities/vendor.dart';
import '../../../vendors/domain/entities/vendor_package.dart';
import '../entities/vendor_dashboard.dart';
import '../entities/vendor_booking.dart';

/// Filter for vendor bookings
class VendorBookingFilter {
  final VendorBookingStatus? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int page;
  final int limit;

  const VendorBookingFilter({
    this.status,
    this.fromDate,
    this.toDate,
    this.page = 1,
    this.limit = 20,
  });

  VendorBookingFilter copyWith({
    VendorBookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? page,
    int? limit,
  }) {
    return VendorBookingFilter(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// Paginated bookings result
class PaginatedVendorBookings {
  final List<VendorBookingSummary> bookings;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginatedVendorBookings({
    required this.bookings,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
}

/// Request model for creating a package
class CreatePackageRequest {
  final String name;
  final String? description;
  final double price;
  final List<String> features;
  final int? durationHours;

  const CreatePackageRequest({
    required this.name,
    this.description,
    required this.price,
    this.features = const [],
    this.durationHours,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'price': price,
        'features': features,
        if (durationHours != null) 'durationHours': durationHours,
      };
}

/// Request model for updating a package
class UpdatePackageRequest {
  final String? name;
  final String? description;
  final double? price;
  final List<String>? features;
  final int? durationHours;
  final bool? isPopular;

  const UpdatePackageRequest({
    this.name,
    this.description,
    this.price,
    this.features,
    this.durationHours,
    this.isPopular,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (features != null) 'features': features,
        if (durationHours != null) 'durationHours': durationHours,
        if (isPopular != null) 'isPopular': isPopular,
      };
}

/// Request model for updating vendor profile
class UpdateVendorProfileRequest {
  final String? businessName;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;
  final String? locationCity;
  final String? locationCountry;
  final String? priceRange;

  const UpdateVendorProfileRequest({
    this.businessName,
    this.description,
    this.phone,
    this.email,
    this.website,
    this.locationCity,
    this.locationCountry,
    this.priceRange,
  });

  Map<String, dynamic> toJson() => {
        if (businessName != null) 'businessName': businessName,
        if (description != null) 'description': description,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (website != null) 'website': website,
        if (locationCity != null) 'locationCity': locationCity,
        if (locationCountry != null) 'locationCountry': locationCountry,
        if (priceRange != null) 'priceRange': priceRange,
      };
}

/// Request model for registering vendor profile (during onboarding)
class RegisterVendorRequest {
  final String businessName;
  final String categoryId;
  final String? description;
  final String? city;
  final String? country;
  final String? priceRange;

  const RegisterVendorRequest({
    required this.businessName,
    required this.categoryId,
    this.description,
    this.city,
    this.country,
    this.priceRange,
  });

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'categoryId': categoryId,
        if (description != null) 'description': description,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (priceRange != null) 'priceRange': priceRange,
      };
}

/// Vendor App Repository Interface
abstract class VendorAppRepository {
  /// Get vendor dashboard with stats
  Future<Either<Failure, VendorDashboard>> getDashboard();

  /// Get vendor earnings summary
  Future<Either<Failure, VendorEarnings>> getEarnings();

  /// Get pending booking requests
  Future<Either<Failure, PaginatedVendorBookings>> getBookingRequests({
    int page = 1,
    int limit = 20,
  });

  /// Get all vendor bookings with optional filter
  Future<Either<Failure, PaginatedVendorBookings>> getAllBookings({
    VendorBookingFilter filter = const VendorBookingFilter(),
  });

  /// Get single booking details
  Future<Either<Failure, VendorBooking>> getBooking(String id);

  /// Accept a booking request
  Future<Either<Failure, VendorBooking>> acceptBooking(
    String id, {
    String? vendorNotes,
  });

  /// Decline a booking request
  Future<Either<Failure, VendorBooking>> declineBooking(
    String id,
    String reason,
  );

  /// Mark a booking as complete
  Future<Either<Failure, VendorBooking>> completeBooking(String id);

  /// Get vendor's packages
  Future<Either<Failure, List<VendorPackage>>> getMyPackages();

  /// Create a new package
  Future<Either<Failure, VendorPackage>> createPackage(
    CreatePackageRequest request,
  );

  /// Update an existing package
  Future<Either<Failure, VendorPackage>> updatePackage(
    String id,
    UpdatePackageRequest request,
  );

  /// Delete a package
  Future<Either<Failure, void>> deletePackage(String id);

  /// Get current vendor's profile
  Future<Either<Failure, Vendor>> getMyProfile();

  /// Update vendor profile
  Future<Either<Failure, Vendor>> updateProfile(
    UpdateVendorProfileRequest request,
  );

  /// Register vendor profile (during onboarding)
  Future<Either<Failure, Vendor>> registerVendor(
    RegisterVendorRequest request,
  );

  /// Get vendor's booked dates (for availability calendar)
  Future<Either<Failure, List<DateTime>>> getBookedDates({
    DateTime? fromDate,
    DateTime? toDate,
  });
}
