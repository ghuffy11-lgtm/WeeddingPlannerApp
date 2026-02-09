import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/vendor_repository.dart';

enum VendorStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

class VendorState extends Equatable {
  // Categories
  final List<Category> categories;
  final VendorStatus categoriesStatus;
  final String? categoriesError;

  // Vendor list
  final List<VendorSummary> vendors;
  final VendorStatus vendorsStatus;
  final String? vendorsError;
  final int vendorsPage;
  final int vendorsTotalPages;
  final int vendorsTotal;
  final VendorFilter currentFilter;

  // Vendor detail
  final Vendor? selectedVendor;
  final VendorStatus vendorDetailStatus;
  final String? vendorDetailError;

  // Reviews
  final List<Review> reviews;
  final VendorStatus reviewsStatus;
  final String? reviewsError;
  final int reviewsPage;
  final int reviewsTotalPages;

  // Favorites
  final Set<String> favoriteVendorIds;

  const VendorState({
    this.categories = const [],
    this.categoriesStatus = VendorStatus.initial,
    this.categoriesError,
    this.vendors = const [],
    this.vendorsStatus = VendorStatus.initial,
    this.vendorsError,
    this.vendorsPage = 1,
    this.vendorsTotalPages = 1,
    this.vendorsTotal = 0,
    this.currentFilter = const VendorFilter(),
    this.selectedVendor,
    this.vendorDetailStatus = VendorStatus.initial,
    this.vendorDetailError,
    this.reviews = const [],
    this.reviewsStatus = VendorStatus.initial,
    this.reviewsError,
    this.reviewsPage = 1,
    this.reviewsTotalPages = 1,
    this.favoriteVendorIds = const {},
  });

  /// Check if categories are loading
  bool get isLoadingCategories => categoriesStatus == VendorStatus.loading;

  /// Check if we can load more vendors
  bool get canLoadMoreVendors => vendorsPage < vendorsTotalPages;

  /// Check if we can load more reviews
  bool get canLoadMoreReviews => reviewsPage < reviewsTotalPages;

  /// Check if a vendor is favorited
  bool isFavorite(String vendorId) => favoriteVendorIds.contains(vendorId);

  VendorState copyWith({
    List<Category>? categories,
    VendorStatus? categoriesStatus,
    String? categoriesError,
    List<VendorSummary>? vendors,
    VendorStatus? vendorsStatus,
    String? vendorsError,
    int? vendorsPage,
    int? vendorsTotalPages,
    int? vendorsTotal,
    VendorFilter? currentFilter,
    Vendor? selectedVendor,
    VendorStatus? vendorDetailStatus,
    String? vendorDetailError,
    List<Review>? reviews,
    VendorStatus? reviewsStatus,
    String? reviewsError,
    int? reviewsPage,
    int? reviewsTotalPages,
    Set<String>? favoriteVendorIds,
  }) {
    return VendorState(
      categories: categories ?? this.categories,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      categoriesError: categoriesError,
      vendors: vendors ?? this.vendors,
      vendorsStatus: vendorsStatus ?? this.vendorsStatus,
      vendorsError: vendorsError,
      vendorsPage: vendorsPage ?? this.vendorsPage,
      vendorsTotalPages: vendorsTotalPages ?? this.vendorsTotalPages,
      vendorsTotal: vendorsTotal ?? this.vendorsTotal,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedVendor: selectedVendor ?? this.selectedVendor,
      vendorDetailStatus: vendorDetailStatus ?? this.vendorDetailStatus,
      vendorDetailError: vendorDetailError,
      reviews: reviews ?? this.reviews,
      reviewsStatus: reviewsStatus ?? this.reviewsStatus,
      reviewsError: reviewsError,
      reviewsPage: reviewsPage ?? this.reviewsPage,
      reviewsTotalPages: reviewsTotalPages ?? this.reviewsTotalPages,
      favoriteVendorIds: favoriteVendorIds ?? this.favoriteVendorIds,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        categoriesStatus,
        categoriesError,
        vendors,
        vendorsStatus,
        vendorsError,
        vendorsPage,
        vendorsTotalPages,
        vendorsTotal,
        currentFilter,
        selectedVendor,
        vendorDetailStatus,
        vendorDetailError,
        reviews,
        reviewsStatus,
        reviewsError,
        reviewsPage,
        reviewsTotalPages,
        favoriteVendorIds,
      ];
}
