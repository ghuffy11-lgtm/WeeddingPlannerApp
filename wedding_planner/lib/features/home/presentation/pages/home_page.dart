import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/feedback/error_state.dart' as feedback;
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Home Page - Discovery Home
/// Main dashboard with hero section, trending themes, and featured vendors
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // Redirect to onboarding if user has no wedding
          if (state.isLoaded && !state.hasWedding) {
            context.go(AppRoutes.onboarding);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const _LoadingState();
          }

          // Show loading while redirecting to onboarding
          if (state.isLoaded && !state.hasWedding) {
            return const _LoadingState();
          }

          if (state.hasError && !state.hasWedding) {
            return feedback.ErrorState(
              title: 'Failed to load data',
              description: state.errorMessage,
              primaryButtonText: 'Retry',
              onPrimaryButtonTap: () {
                // Clear error state first, then reload
                context.read<HomeBloc>().add(const HomeClearError());
                context.read<HomeBloc>().add(const HomeLoadRequested());
              },
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceDark,
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshRequested());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Stack(
              children: [
                // Background glows
                const BackgroundGlow(
                  color: AppColors.accentPurple,
                  alignment: Alignment(-1.5, -0.5),
                  size: 400,
                ),
                const BackgroundGlow(
                  color: AppColors.accentCyan,
                  alignment: Alignment(1.5, 0.8),
                  size: 350,
                ),

                // Content
                CustomScrollView(
                  slivers: [
                    // App Bar
                    _buildAppBar(context),

                    // Content
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Section
                          _HeroSection(
                            daysUntilWedding: state.daysUntilWedding ?? 0,
                            coupleNames: state.wedding?.coupleDisplayName ?? 'Your Wedding',
                          ),

                          const SizedBox(height: 32),

                          // Wedding Countdown Card (if wedding date is set)
                          if (state.wedding?.weddingDate != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _WeddingCountdownSection(
                                daysUntilWedding: state.daysUntilWedding ?? 0,
                                weddingDate: state.wedding!.weddingDate!,
                                coupleNames: state.wedding?.coupleDisplayName ?? 'Your Wedding',
                                stylePreferences: state.wedding?.styleDisplay,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Trending Themes Section
                          _buildSectionHeader(
                            'Trending Themes',
                            onSeeAll: () {},
                          ),
                          const SizedBox(height: 16),
                          const _TrendingThemesCarousel(),

                          const SizedBox(height: 32),

                          // Wedding Date CTA Card (only show if no wedding date)
                          if (state.wedding?.weddingDate == null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: const _WeddingDateCard(),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Featured Vendors Section
                          _buildSectionHeader(
                            'Featured Vendors',
                            onSeeAll: () => context.go(AppRoutes.vendors),
                          ),
                          const SizedBox(height: 16),
                          const _FeaturedVendorsSection(),

                          const SizedBox(height: 100), // Bottom padding for nav
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GlassIconButton(
          icon: Icons.search,
          onTap: () {},
        ),
      ),
      title: Text(
        'Discovery Home',
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GlassIconButton(
            icon: Icons.favorite_border,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.h2,
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Hero Section with wedding countdown
class _HeroSection extends StatelessWidget {
  final int daysUntilWedding;
  final String coupleNames;

  const _HeroSection({
    required this.daysUntilWedding,
    required this.coupleNames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      height: 400,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.backgroundDark.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.backgroundDark.withValues(alpha: 0.7),
              AppColors.backgroundDark,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Dream Wedding\nStarts Here',
              style: AppTypography.hero.copyWith(
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover vendors, themes, and shop the latest bridal trends.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _PrimaryButton(
              label: 'Get Inspired',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary Button with gradient
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTypography.buttonMedium.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// Trending Themes Carousel
class _TrendingThemesCarousel extends StatelessWidget {
  const _TrendingThemesCarousel();

  @override
  Widget build(BuildContext context) {
    final themes = [
      _ThemeData(
        title: 'Rustic Charm',
        subtitle: 'Warm and earthy vibes',
        imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=600',
      ),
      _ThemeData(
        title: 'Modern Chic',
        subtitle: 'Clean lines and minimalist',
        imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=600',
      ),
      _ThemeData(
        title: 'Garden Romance',
        subtitle: 'Floral and enchanting',
        imageUrl: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=600',
      ),
    ];

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: themes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < themes.length - 1 ? 16 : 0),
            child: _ThemeCard(theme: themes[index]),
          );
        },
      ),
    );
  }
}

class _ThemeData {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _ThemeData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class _ThemeCard extends StatelessWidget {
  final _ThemeData theme;

  const _ThemeCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to vendor search with theme as filter
        context.push('/vendors/search', extra: theme.title);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(theme.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            theme.title,
            style: AppTypography.h4,
          ),
          Text(
            theme.subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wedding Date CTA Card
class _WeddingDateCard extends StatelessWidget {
  const _WeddingDateCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planning for a specific date?',
            style: AppTypography.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us your wedding date to get personalized recommendations and countdowns.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showDatePicker(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Set Wedding Date'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceDark,
            ),
            dialogBackgroundColor: AppColors.backgroundDark,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && context.mounted) {
      context.read<HomeBloc>().add(HomeWeddingUpdated(weddingDate: selectedDate));
    }
  }
}

/// Featured Vendors Section
class _FeaturedVendorsSection extends StatelessWidget {
  const _FeaturedVendorsSection();

  @override
  Widget build(BuildContext context) {
    final vendors = [
      _VendorData(
        name: 'Elena Bloom',
        role: 'Photographer',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
      ),
      _VendorData(
        name: 'Petals & Co.',
        role: 'Floral Design',
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1487530811176-3780de880c2d?w=300',
      ),
      _VendorData(
        name: 'Sweet Moments',
        role: 'Cake Designer',
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1558636508-e0db3814bd1d?w=300',
      ),
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < vendors.length - 1 ? 16 : 0),
            child: _VendorCircle(vendor: vendors[index]),
          );
        },
      ),
    );
  }
}

class _VendorData {
  final String name;
  final String role;
  final double rating;
  final String imageUrl;

  const _VendorData({
    required this.name,
    required this.role,
    required this.rating,
    required this.imageUrl,
  });
}

class _VendorCircle extends StatelessWidget {
  final _VendorData vendor;

  const _VendorCircle({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to vendors page (featured vendors are just samples)
        context.go(AppRoutes.vendors);
      },
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  vendor.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              vendor.name,
              style: AppTypography.labelLarge,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              vendor.role,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  vendor.rating.toString(),
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Wedding Countdown Section with style display
class _WeddingCountdownSection extends StatelessWidget {
  final int daysUntilWedding;
  final DateTime weddingDate;
  final String coupleNames;
  final String? stylePreferences;

  const _WeddingCountdownSection({
    required this.daysUntilWedding,
    required this.weddingDate,
    required this.coupleNames,
    this.stylePreferences,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CountdownUnit(value: daysUntilWedding, label: 'Days'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Until $coupleNames\'s Wedding',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(weddingDate),
            style: AppTypography.h3.copyWith(
              color: AppColors.primary,
            ),
          ),
          if (stylePreferences != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.style,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stylePreferences!,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppTypography.countdown.copyWith(
            color: AppColors.primary,
            fontSize: 64,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: AppTypography.countdownUnit.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Loading State Widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGlow(
          color: AppColors.accentPurple,
          alignment: Alignment(-1.5, -0.5),
          size: 400,
        ),
        const BackgroundGlow(
          color: AppColors.accentCyan,
          alignment: Alignment(1.5, 0.8),
          size: 350,
        ),
        CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.8),
              elevation: 0,
              title: Text(
                'Discovery Home',
                style: AppTypography.h3,
              ),
              centerTitle: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.base),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SkeletonBox(height: 400),
                  const SizedBox(height: AppSpacing.large),
                  _SkeletonBox(height: 300),
                  const SizedBox(height: AppSpacing.large),
                  _SkeletonBox(height: 150),
                  const SizedBox(height: AppSpacing.large),
                  _SkeletonBox(height: 200),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Skeleton loading placeholder
class _SkeletonBox extends StatelessWidget {
  final double height;

  const _SkeletonBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
    );
  }
}
