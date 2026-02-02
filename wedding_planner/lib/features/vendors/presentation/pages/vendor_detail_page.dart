import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../widgets/portfolio_tab.dart';
import '../widgets/packages_tab.dart';
import '../widgets/reviews_tab.dart';
import '../widgets/about_tab.dart';

/// Vendor detail page with portfolio, packages, reviews, and about tabs
class VendorDetailPage extends StatefulWidget {
  final String vendorId;

  const VendorDetailPage({
    super.key,
    required this.vendorId,
  });

  @override
  State<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVendor();
  }

  void _loadVendor() {
    context.read<VendorBloc>().add(VendorDetailRequested(widget.vendorId));
    context.read<VendorBloc>().add(VendorReviewsRequested(vendorId: widget.vendorId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFavoriteTap() {
    context.read<VendorBloc>().add(VendorFavoriteToggled(widget.vendorId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blushRose,
      body: BlocBuilder<VendorBloc, VendorState>(
        builder: (context, state) {
          if (state.vendorDetailStatus == VendorStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.roseGold),
            );
          }

          if (state.vendorDetailStatus == VendorStatus.error) {
            return _buildErrorState(state.vendorDetailError);
          }

          final vendor = state.selectedVendor;
          if (vendor == null) {
            return _buildErrorState('Vendor not found');
          }

          final isFavorite = state.isFavorite(vendor.id);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // App Bar with Image
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: AppColors.blushRose,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha(230),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.deepCharcoal,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withAlpha(230),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.roseGold
                              : AppColors.deepCharcoal,
                        ),
                      ),
                      onPressed: _onFavoriteTap,
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white.withAlpha(230),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share,
                          color: AppColors.deepCharcoal,
                        ),
                      ),
                      onPressed: () {
                        // TODO: Implement share
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: vendor.portfolio.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: vendor.portfolio.first.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.blushRose,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.roseGold,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.blushRose,
                              child: const Icon(
                                Icons.store,
                                size: 64,
                                color: AppColors.warmGray,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.champagne,
                            child: const Icon(
                              Icons.store,
                              size: 64,
                              color: AppColors.warmGray,
                            ),
                          ),
                  ),
                ),

                // Vendor Info Header
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges
                        if (vendor.isFeatured || vendor.isVerified)
                          Wrap(
                            spacing: AppSpacing.small,
                            children: [
                              if (vendor.isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.small,
                                    vertical: AppSpacing.micro,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.champagne,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        size: 14,
                                        color: AppColors.deepCharcoal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Featured',
                                        style: AppTypography.tiny.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (vendor.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.small,
                                    vertical: AppSpacing.micro,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withAlpha(51),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: AppTypography.tiny.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                        if (vendor.isFeatured || vendor.isVerified)
                          const SizedBox(height: AppSpacing.small),

                        // Business Name
                        Text(
                          vendor.businessName,
                          style: AppTypography.h1,
                        ),

                        const SizedBox(height: AppSpacing.small),

                        // Category
                        if (vendor.category != null)
                          Text(
                            vendor.category!.name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.warmGray,
                            ),
                          ),

                        const SizedBox(height: AppSpacing.small),

                        // Rating and Reviews
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 20,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vendor.ratingAvg.toStringAsFixed(1),
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${vendor.reviewCount} reviews)',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.warmGray,
                              ),
                            ),
                            const Spacer(),
                            if (vendor.priceDisplay.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.small,
                                  vertical: AppSpacing.micro,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.blushRose,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  vendor.priceDisplay,
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.small),

                        // Location
                        if (vendor.locationDisplay.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: AppColors.warmGray,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vendor.locationDisplay,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.warmGray,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Response Time
                        if (vendor.responseTimeHours != null) ...[
                          const SizedBox(height: AppSpacing.micro),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 18,
                                color: AppColors.warmGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Usually responds within ${vendor.responseTimeHours} hours',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.warmGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.roseGold,
                      unselectedLabelColor: AppColors.warmGray,
                      indicatorColor: AppColors.roseGold,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Portfolio'),
                        Tab(text: 'Packages'),
                        Tab(text: 'Reviews'),
                        Tab(text: 'About'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                PortfolioTab(portfolio: vendor.portfolio),
                PackagesTab(packages: vendor.packages),
                const ReviewsTab(),
                AboutTab(vendor: vendor),
              ],
            ),
          );
        },
      ),

      // Bottom Action Bar
      bottomNavigationBar: BlocBuilder<VendorBloc, VendorState>(
        builder: (context, state) {
          final vendor = state.selectedVendor;
          if (vendor == null) return const SizedBox.shrink();

          return Container(
            padding: EdgeInsets.only(
              left: AppSpacing.medium,
              right: AppSpacing.medium,
              top: AppSpacing.medium,
              bottom: AppSpacing.medium + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Chat Button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.roseGold),
                    borderRadius: AppSpacing.borderRadiusMedium,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.roseGold,
                    ),
                    onPressed: () {
                      // TODO: Navigate to chat
                    },
                  ),
                ),

                // Call Button
                const SizedBox(width: AppSpacing.small),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.roseGold),
                    borderRadius: AppSpacing.borderRadiusMedium,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.roseGold,
                    ),
                    onPressed: () {
                      // TODO: Make phone call
                    },
                  ),
                ),

                const SizedBox(width: AppSpacing.medium),

                // Book Now Button
                Expanded(
                  child: PrimaryButton(
                    text: 'Book Now',
                    onPressed: () {
                      context.push('/vendors/${vendor.id}/book');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return SafeArea(
      child: Center(
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
                'Failed to load vendor',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                error ?? 'An error occurred',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.warmGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.large),
              ElevatedButton(
                onPressed: _loadVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseGold,
                ),
                child: const Text('Retry'),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Delegate for tab bar persistent header
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
