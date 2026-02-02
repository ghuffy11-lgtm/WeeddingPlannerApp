import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../entities/vendor.dart';
import '../entities/review.dart';

/// Filter options for vendor search
class VendorFilter {
  final String? categoryId;
  final String? city;
  final String? country;
  final String? priceRange;
  final double? minRating;
  final String? search;
  final bool? featured;
  final String sortBy;
  final String sortOrder;

  const VendorFilter({
    this.categoryId,
    this.city,
    this.country,
    this.priceRange,
    this.minRating,
    this.search,
    this.featured,
    this.sortBy = 'rating_avg',
    this.sortOrder = 'desc',
  });

  VendorFilter copyWith({
    String? categoryId,
    String? city,
    String? country,
    String? priceRange,
    double? minRating,
    String? search,
    bool? featured,
    String? sortBy,
    String? sortOrder,
  }) {
    return VendorFilter(
      categoryId: categoryId ?? this.categoryId,
      city: city ?? this.city,
      country: country ?? this.country,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      search: search ?? this.search,
      featured: featured ?? this.featured,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Clear all filters
  VendorFilter clear() {
    return const VendorFilter();
  }

  /// Check if any filter is active
  bool get hasActiveFilters =>
      city != null ||
      country != null ||
      priceRange != null ||
      minRating != null ||
      search != null ||
      featured == true;
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

/// Vendor repository interface
abstract class VendorRepository {
  /// Get all categories
  Future<Either<Failure, List<Category>>> getCategories({String? lang});

  /// Get category by ID
  Future<Either<Failure, Category>> getCategoryById(String id);

  /// Get vendors with filters and pagination
  Future<Either<Failure, PaginatedResult<VendorSummary>>> getVendors({
    VendorFilter filter = const VendorFilter(),
    int page = 1,
    int limit = 20,
  });

  /// Get vendor details by ID
  Future<Either<Failure, Vendor>> getVendorById(String id);

  /// Get vendor reviews with pagination
  Future<Either<Failure, PaginatedResult<Review>>> getVendorReviews(
    String vendorId, {
    int page = 1,
    int limit = 10,
  });

  /// Get favorite vendor IDs
  Future<Either<Failure, List<String>>> getFavoriteVendorIds();

  /// Add vendor to favorites
  Future<Either<Failure, void>> addToFavorites(String vendorId);

  /// Remove vendor from favorites
  Future<Either<Failure, void>> removeFromFavorites(String vendorId);

  /// Check if vendor is favorited
  Future<Either<Failure, bool>> isFavorite(String vendorId);
}
