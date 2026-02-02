import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/vendor_repository.dart';
import 'vendor_event.dart';
import 'vendor_state.dart';

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final VendorRepository vendorRepository;

  VendorBloc({required this.vendorRepository}) : super(const VendorState()) {
    on<VendorCategoriesRequested>(_onCategoriesRequested);
    on<VendorsRequested>(_onVendorsRequested);
    on<VendorsLoadMoreRequested>(_onVendorsLoadMoreRequested);
    on<VendorDetailRequested>(_onVendorDetailRequested);
    on<VendorReviewsRequested>(_onVendorReviewsRequested);
    on<VendorReviewsLoadMoreRequested>(_onVendorReviewsLoadMoreRequested);
    on<VendorFilterUpdated>(_onFilterUpdated);
    on<VendorFilterCleared>(_onFilterCleared);
    on<VendorFavoriteToggled>(_onFavoriteToggled);
    on<VendorFavoritesRequested>(_onFavoritesRequested);
    on<VendorSearchRequested>(_onSearchRequested);
  }

  Future<void> _onCategoriesRequested(
    VendorCategoriesRequested event,
    Emitter<VendorState> emit,
  ) async {
    emit(state.copyWith(categoriesStatus: VendorStatus.loading));

    final result = await vendorRepository.getCategories(lang: event.lang);

    result.fold(
      (failure) => emit(state.copyWith(
        categoriesStatus: VendorStatus.error,
        categoriesError: failure.message,
      )),
      (categories) => emit(state.copyWith(
        categoriesStatus: VendorStatus.loaded,
        categories: categories,
        categoriesError: null,
      )),
    );
  }

  Future<void> _onVendorsRequested(
    VendorsRequested event,
    Emitter<VendorState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(vendorsStatus: VendorStatus.loading));
    } else if (event.page == 1) {
      emit(state.copyWith(
        vendorsStatus: VendorStatus.loading,
        vendors: [],
      ));
    } else {
      emit(state.copyWith(vendorsStatus: VendorStatus.loadingMore));
    }

    final result = await vendorRepository.getVendors(
      filter: event.filter,
      page: event.page,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        vendorsStatus: VendorStatus.error,
        vendorsError: failure.message,
      )),
      (paginatedResult) {
        final vendors = event.page == 1
            ? paginatedResult.items
            : [...state.vendors, ...paginatedResult.items];

        emit(state.copyWith(
          vendorsStatus: VendorStatus.loaded,
          vendors: vendors,
          vendorsPage: paginatedResult.page,
          vendorsTotalPages: paginatedResult.totalPages,
          vendorsTotal: paginatedResult.total,
          currentFilter: event.filter,
          vendorsError: null,
        ));
      },
    );
  }

  Future<void> _onVendorsLoadMoreRequested(
    VendorsLoadMoreRequested event,
    Emitter<VendorState> emit,
  ) async {
    if (!state.canLoadMoreVendors ||
        state.vendorsStatus == VendorStatus.loadingMore) {
      return;
    }

    add(VendorsRequested(
      filter: state.currentFilter,
      page: state.vendorsPage + 1,
    ));
  }

  Future<void> _onVendorDetailRequested(
    VendorDetailRequested event,
    Emitter<VendorState> emit,
  ) async {
    emit(state.copyWith(vendorDetailStatus: VendorStatus.loading));

    final result = await vendorRepository.getVendorById(event.vendorId);

    result.fold(
      (failure) => emit(state.copyWith(
        vendorDetailStatus: VendorStatus.error,
        vendorDetailError: failure.message,
      )),
      (vendor) => emit(state.copyWith(
        vendorDetailStatus: VendorStatus.loaded,
        selectedVendor: vendor,
        vendorDetailError: null,
      )),
    );
  }

  Future<void> _onVendorReviewsRequested(
    VendorReviewsRequested event,
    Emitter<VendorState> emit,
  ) async {
    if (event.page == 1) {
      emit(state.copyWith(
        reviewsStatus: VendorStatus.loading,
        reviews: [],
      ));
    } else {
      emit(state.copyWith(reviewsStatus: VendorStatus.loadingMore));
    }

    final result = await vendorRepository.getVendorReviews(
      event.vendorId,
      page: event.page,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        reviewsStatus: VendorStatus.error,
        reviewsError: failure.message,
      )),
      (paginatedResult) {
        final reviews = event.page == 1
            ? paginatedResult.items
            : [...state.reviews, ...paginatedResult.items];

        emit(state.copyWith(
          reviewsStatus: VendorStatus.loaded,
          reviews: reviews,
          reviewsPage: paginatedResult.page,
          reviewsTotalPages: paginatedResult.totalPages,
          reviewsError: null,
        ));
      },
    );
  }

  Future<void> _onVendorReviewsLoadMoreRequested(
    VendorReviewsLoadMoreRequested event,
    Emitter<VendorState> emit,
  ) async {
    if (!state.canLoadMoreReviews ||
        state.reviewsStatus == VendorStatus.loadingMore) {
      return;
    }

    if (state.selectedVendor != null) {
      add(VendorReviewsRequested(
        vendorId: state.selectedVendor!.id,
        page: state.reviewsPage + 1,
      ));
    }
  }

  Future<void> _onFilterUpdated(
    VendorFilterUpdated event,
    Emitter<VendorState> emit,
  ) async {
    add(VendorsRequested(filter: event.filter, refresh: true));
  }

  Future<void> _onFilterCleared(
    VendorFilterCleared event,
    Emitter<VendorState> emit,
  ) async {
    add(VendorsRequested(
      filter: state.currentFilter.clear(),
      refresh: true,
    ));
  }

  Future<void> _onFavoriteToggled(
    VendorFavoriteToggled event,
    Emitter<VendorState> emit,
  ) async {
    final isFav = state.isFavorite(event.vendorId);

    // Optimistic update
    final newFavorites = Set<String>.from(state.favoriteVendorIds);
    if (isFav) {
      newFavorites.remove(event.vendorId);
    } else {
      newFavorites.add(event.vendorId);
    }
    emit(state.copyWith(favoriteVendorIds: newFavorites));

    // Persist to local storage
    final result = isFav
        ? await vendorRepository.removeFromFavorites(event.vendorId)
        : await vendorRepository.addToFavorites(event.vendorId);

    // Revert on failure
    result.fold(
      (failure) {
        final revertedFavorites = Set<String>.from(state.favoriteVendorIds);
        if (isFav) {
          revertedFavorites.add(event.vendorId);
        } else {
          revertedFavorites.remove(event.vendorId);
        }
        emit(state.copyWith(favoriteVendorIds: revertedFavorites));
      },
      (_) {
        // Success - already updated optimistically
      },
    );
  }

  Future<void> _onFavoritesRequested(
    VendorFavoritesRequested event,
    Emitter<VendorState> emit,
  ) async {
    final result = await vendorRepository.getFavoriteVendorIds();

    result.fold(
      (failure) {
        // Ignore failures for favorites loading
      },
      (favoriteIds) => emit(state.copyWith(
        favoriteVendorIds: favoriteIds.toSet(),
      )),
    );
  }

  Future<void> _onSearchRequested(
    VendorSearchRequested event,
    Emitter<VendorState> emit,
  ) async {
    final newFilter = state.currentFilter.copyWith(search: event.query);
    add(VendorsRequested(filter: newFilter, refresh: true));
  }
}
