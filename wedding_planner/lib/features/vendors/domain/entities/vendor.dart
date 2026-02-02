import 'category.dart';
import 'vendor_package.dart';
import 'portfolio_item.dart';

/// Vendor entity for vendor list (minimal data)
class VendorSummary {
  final String id;
  final String businessName;
  final String? description;
  final String? locationCity;
  final String? locationCountry;
  final String? priceRange;
  final double ratingAvg;
  final int reviewCount;
  final bool isVerified;
  final bool isFeatured;
  final int? responseTimeHours;
  final String? thumbnail;
  final Category? category;

  const VendorSummary({
    required this.id,
    required this.businessName,
    this.description,
    this.locationCity,
    this.locationCountry,
    this.priceRange,
    this.ratingAvg = 0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isFeatured = false,
    this.responseTimeHours,
    this.thumbnail,
    this.category,
  });

  /// Get location display string
  String get locationDisplay {
    if (locationCity != null && locationCountry != null) {
      return '$locationCity, $locationCountry';
    }
    return locationCity ?? locationCountry ?? '';
  }

  /// Get price range display ($ to $$$$)
  String get priceDisplay {
    switch (priceRange) {
      case 'budget':
        return '\$';
      case 'moderate':
        return '\$\$';
      case 'premium':
        return '\$\$\$';
      case 'luxury':
        return '\$\$\$\$';
      default:
        return priceRange ?? '';
    }
  }
}

/// Full vendor entity with all details
class Vendor extends VendorSummary {
  final String? phone;
  final String? email;
  final String? website;
  final double? latitude;
  final double? longitude;
  final List<VendorPackage> packages;
  final List<PortfolioItem> portfolio;

  const Vendor({
    required super.id,
    required super.businessName,
    super.description,
    super.locationCity,
    super.locationCountry,
    super.priceRange,
    super.ratingAvg,
    super.reviewCount,
    super.isVerified,
    super.isFeatured,
    super.responseTimeHours,
    super.thumbnail,
    super.category,
    this.phone,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.packages = const [],
    this.portfolio = const [],
  });

  /// Check if vendor has contact info
  bool get hasContactInfo => phone != null || email != null || website != null;

  /// Check if vendor has location coordinates
  bool get hasCoordinates => latitude != null && longitude != null;
}
