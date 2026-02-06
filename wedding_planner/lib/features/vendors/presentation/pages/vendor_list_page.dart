import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/cards/vendor_card.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../widgets/vendor_filter_modal.dart';

/// Vendor list page showing vendors in a category or search results
/// Dark theme with glassmorphism design
class VendorListPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? searchQuery;

  const VendorListPage({
    super.key,
    this.categoryId,
    this.categoryName,
    this.searchQuery,
  });

  @override
  State<VendorListPage> createState() => _VendorListPageState();
}

class _VendorListPageState extends State<VendorListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadVendors();
    _scrollController.addListener(_onScroll);
  }

  void _loadVendors({bool refresh = false}) {
    VendorFilter filter = const VendorFilter();

    if (widget.categoryId != null) {
      filter = filter.copyWith(categoryId: widget.categoryId);
    }

    if (widget.searchQuery != null) {
      filter = filter.copyWith(search: widget.searchQuery);
    }

    context.read<VendorBloc>().add(VendorsRequested(
      filter: filter,
      refresh: refresh,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VendorBloc>().add(const VendorsLoadMoreRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    final state = context.read<VendorBloc>().state;
    VendorFilterModal.show(
      context,
      initialFilter: state.currentFilter,
      onApply: (filter) {
        context.read<VendorBloc>().add(VendorFilterUpdated(filter));
      },
    );
  }

  void _onVendorTap(String vendorId) {
    context.push('/vendors/$vendorId');
  }

  void _onFavoriteTap(String vendorId) {
    context.read<VendorBloc>().add(VendorFavoriteToggled(vendorId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Background glows
          const BackgroundGlow(
            color: AppColors.accentPurple,
            alignment: Alignment(-0.8, -0.5),
            size: 300,
          ),
          const BackgroundGlow(
            color: AppColors.primary,
            alignment: Alignment(0.9, 0.5),
            size: 250,
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.base),
                      Expanded(
                        child: Text(
                          widget.categoryName ??
                          (widget.searchQuery != null ? 'Search: ${widget.searchQuery}' : 'Vendors'),
                          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GlassIconButton(
                        icon: Icons.tune,
                        onTap: _showFilterModal,
                      ),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: BlocBuilder<VendorBloc, VendorState>(
                    builder: (context, state) {
                      // Active filters indicator
                      final hasFilters = state.currentFilter.hasActiveFilters;

                      return Column(
                        children: [
                          // Filter indicator
                          if (hasFilters)
                            ClipRRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.medium,
                                    vertical: AppSpacing.small,
                                  ),
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.filter_list,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.small),
                                      Expanded(
                                        child: Text(
                                          'Filters active',
                                          style: AppTypography.labelMedium.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<VendorBloc>().add(const VendorFilterCleared());
                                        },
                                        child: Text(
                                          'Clear',
                                          style: AppTypography.labelMedium.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Results count
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.medium,
                              vertical: AppSpacing.small,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${state.vendorsTotal} vendors found',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Vendor list
                          Expanded(
                            child: _buildContent(state),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(VendorState state) {
    if (state.vendorsStatus == VendorStatus.loading && state.vendors.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.vendorsStatus == VendorStatus.error && state.vendors.isEmpty) {
      return _buildErrorState(state.vendorsError);
    }

    if (state.vendors.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadVendors(refresh: true);
      },
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: state.vendors.length + (state.canLoadMoreVendors ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.vendors.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.medium),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          final vendor = state.vendors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: VendorCard(
              id: vendor.id,
              name: vendor.businessName,
              category: vendor.category?.name ?? '',
              imageUrl: vendor.thumbnail,
              rating: vendor.ratingAvg,
              reviewCount: vendor.reviewCount,
              location: vendor.locationDisplay,
              priceRange: vendor.priceDisplay,
              isFeatured: vendor.isFeatured,
              isFavorite: state.isFavorite(vendor.id),
              onTap: () => _onVendorTap(vendor.id),
              onFavoriteTap: () => _onFavoriteTap(vendor.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Failed to load vendors',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              error ?? 'An error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            GlassButton(
              onTap: () => _loadVendors(refresh: true),
              isPrimary: true,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No vendors found',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Try adjusting your filters or search criteria',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
