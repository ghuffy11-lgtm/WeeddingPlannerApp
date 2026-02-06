import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../config/routes.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/category.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../widgets/category_card.dart';

/// Main vendors page showing category grid
/// Dark theme with glassmorphism design
class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<VendorBloc>().add(const VendorCategoriesRequested());
    context.read<VendorBloc>().add(const VendorFavoritesRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(Category category) {
    context.push(
      '${AppRoutes.vendors}/category/${category.id}',
      extra: category.name,
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.push(
        '${AppRoutes.vendors}/search',
        extra: query,
      );
    }
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
            size: 350,
          ),
          const BackgroundGlow(
            color: AppColors.primary,
            alignment: Alignment(0.9, 0.3),
            size: 300,
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Text(
                    'Find Vendors',
                    style: AppTypography.hero.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search vendors...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textTertiary,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.tune, color: AppColors.textTertiary),
                              onPressed: _onSearch,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.medium,
                              vertical: AppSpacing.base,
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _onSearch(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.large),

                // Categories Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                  child: Text(
                    'Browse by Category',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.medium),

                // Categories Grid
                Expanded(
                  child: BlocBuilder<VendorBloc, VendorState>(
                    builder: (context, state) {
                      if (state.categoriesStatus == VendorStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (state.categoriesStatus == VendorStatus.error) {
                        return _buildErrorState(state.categoriesError);
                      }

                      if (state.categories.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _loadData();
                        },
                        color: AppColors.primary,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: AppSpacing.medium,
                            crossAxisSpacing: AppSpacing.medium,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: state.categories.length,
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            return CategoryCard(
                              category: category,
                              onTap: () => _onCategoryTap(category),
                            );
                          },
                        ),
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
              'Failed to load categories',
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
              onTap: _loadData,
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
              Icons.category_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No categories available',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Check back later for vendor categories',
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
