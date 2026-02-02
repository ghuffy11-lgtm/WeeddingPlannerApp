import '../../domain/entities/category.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/entities/vendor_package.dart';
import '../../domain/entities/portfolio_item.dart';
import 'category_model.dart';
import 'vendor_package_model.dart';
import 'portfolio_item_model.dart';

/// Vendor summary data model for JSON serialization
class VendorSummaryModel extends VendorSummary {
  const VendorSummaryModel({
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
  });

  factory VendorSummaryModel.fromJson(Map<String, dynamic> json) {
    return VendorSummaryModel(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      description: json['description'] as String?,
      locationCity: json['location_city'] as String?,
      locationCountry: json['location_country'] as String?,
      priceRange: json['price_range'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      responseTimeHours: json['response_time_hours'] as int?,
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'description': description,
      'location_city': locationCity,
      'location_country': locationCountry,
      'price_range': priceRange,
      'rating_avg': ratingAvg,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'response_time_hours': responseTimeHours,
      'thumbnail': thumbnail,
    };
  }
}

/// Full vendor data model for JSON serialization
class VendorModel extends Vendor {
  const VendorModel({
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
    super.phone,
    super.email,
    super.website,
    super.latitude,
    super.longitude,
    super.packages,
    super.portfolio,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as String,
      businessName: json['business_name'] as String,
      description: json['description'] as String?,
      locationCity: json['location_city'] as String?,
      locationCountry: json['location_country'] as String?,
      priceRange: json['price_range'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      responseTimeHours: json['response_time_hours'] as int?,
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      packages: (json['packages'] as List<dynamic>?)
              ?.map((e) => VendorPackageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      portfolio: (json['portfolio'] as List<dynamic>?)
              ?.map((e) => PortfolioItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'description': description,
      'location_city': locationCity,
      'location_country': locationCountry,
      'price_range': priceRange,
      'rating_avg': ratingAvg,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'response_time_hours': responseTimeHours,
      'thumbnail': thumbnail,
      'phone': phone,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
