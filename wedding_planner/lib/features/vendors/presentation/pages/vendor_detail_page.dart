import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../widgets/portfolio_tab.dart';
import '../widgets/packages_tab.dart';
import '../widgets/reviews_tab.dart';
import '../widgets/about_tab.dart';

/// Vendor detail page with portfolio, packages, reviews, and about tabs
/// Dark theme with glassmorphism design
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
      backgroundColor: AppColors.backgroundDark,
      body: BlocBuilder<VendorBloc, VendorState>(
        builder: (context, state) {
          if (state.vendorDetailStatus == VendorStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
                  backgroundColor: AppColors.surfaceDark,
                  leading: IconButton(
                    icon: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      onPressed: _onFavoriteTap,
                    ),
                    IconButton(
                      icon: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: const Icon(
                              Icons.share,
                              color: AppColors.textPrimary,
                            ),
                          ),
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
                              color: AppColors.surfaceDark,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceDark,
                              child: const Icon(
                                Icons.store,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceDark,
                            child: const Icon(
                              Icons.store,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),
                ),

                // Vendor Info Header
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surfaceDark,
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
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withValues(alpha: 0.2),
                                        AppColors.accentPurple.withValues(alpha: 0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Featured',
                                        style: AppTypography.tiny.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
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
                                    color: AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.success.withValues(alpha: 0.3),
                                    ),
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
                          style: AppTypography.h1.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.small),

                        // Category
                        if (vendor.category != null)
                          Text(
                            vendor.category!.name,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
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
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${vendor.reviewCount} reviews)',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
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
                                  color: AppColors.glassBackground,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Text(
                                  vendor.priceDisplay,
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
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
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  vendor.locationDisplay,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
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
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Usually responds within ${vendor.responseTimeHours} hours',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
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
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textTertiary,
                      indicatorColor: AppColors.primary,
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

          return ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.medium,
                  right: AppSpacing.medium,
                  top: AppSpacing.medium,
                  bottom: AppSpacing.medium + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  border: Border(
                    top: BorderSide(color: AppColors.glassBorder),
                  ),
                ),
                child: Row(
                  children: [
                    // Chat Button
                    GlassIconButton(
                      icon: Icons.chat_bubble_outline,
                      size: 48,
                      onTap: () {
                        // TODO: Navigate to chat
                      },
                    ),

                    // Call Button
                    const SizedBox(width: AppSpacing.small),
                    GlassIconButton(
                      icon: Icons.phone_outlined,
                      size: 48,
                      onTap: () {
                        // TODO: Make phone call
                      },
                    ),

                    const SizedBox(width: AppSpacing.medium),

                    // Book Now Button
                    Expanded(
                      child: PrimaryButton(
                        text: 'Book Now',
                        onPressed: () {
                          context.push('/vendors/${vendor.id}/book', extra: vendor);
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
                onTap: _loadVendor,
                isPrimary: true,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Go Back',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
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
      color: AppColors.surfaceDark,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
