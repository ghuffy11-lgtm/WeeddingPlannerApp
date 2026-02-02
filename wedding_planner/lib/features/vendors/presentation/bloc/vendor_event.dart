import 'package:equatable/equatable.dart';
import '../../domain/repositories/vendor_repository.dart';

abstract class VendorEvent extends Equatable {
  const VendorEvent();

  @override
  List<Object?> get props => [];
}

/// Load categories
class VendorCategoriesRequested extends VendorEvent {
  final String? lang;

  const VendorCategoriesRequested({this.lang});

  @override
  List<Object?> get props => [lang];
}

/// Load vendors (with optional filter)
class VendorsRequested extends VendorEvent {
  final VendorFilter filter;
  final int page;
  final bool refresh;

  const VendorsRequested({
    this.filter = const VendorFilter(),
    this.page = 1,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [filter, page, refresh];
}

/// Load more vendors (pagination)
class VendorsLoadMoreRequested extends VendorEvent {
  const VendorsLoadMoreRequested();
}

/// Load vendor details
class VendorDetailRequested extends VendorEvent {
  final String vendorId;

  const VendorDetailRequested(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

/// Load vendor reviews
class VendorReviewsRequested extends VendorEvent {
  final String vendorId;
  final int page;

  const VendorReviewsRequested({
    required this.vendorId,
    this.page = 1,
  });

  @override
  List<Object?> get props => [vendorId, page];
}

/// Load more reviews (pagination)
class VendorReviewsLoadMoreRequested extends VendorEvent {
  const VendorReviewsLoadMoreRequested();
}

/// Update filter
class VendorFilterUpdated extends VendorEvent {
  final VendorFilter filter;

  const VendorFilterUpdated(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Clear filter
class VendorFilterCleared extends VendorEvent {
  const VendorFilterCleared();
}

/// Toggle favorite
class VendorFavoriteToggled extends VendorEvent {
  final String vendorId;

  const VendorFavoriteToggled(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

/// Load favorites
class VendorFavoritesRequested extends VendorEvent {
  const VendorFavoritesRequested();
}

/// Search vendors
class VendorSearchRequested extends VendorEvent {
  final String query;

  const VendorSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}
