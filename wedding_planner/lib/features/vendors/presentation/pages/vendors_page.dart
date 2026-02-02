import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../config/routes.dart';
import '../../domain/entities/category.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../widgets/category_card.dart';

/// Main vendors page showing category grid
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
      backgroundColor: AppColors.blushRose,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Text(
                'Find Vendors',
                style: AppTypography.h1,
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppSpacing.borderRadiusMedium,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search vendors...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.warmGray,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.warmGray,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.warmGray),
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

            const SizedBox(height: AppSpacing.large),

            // Categories Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
              child: Text(
                'Browse by Category',
                style: AppTypography.h3,
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
                        color: AppColors.roseGold,
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
                    color: AppColors.roseGold,
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
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseGold,
              ),
              child: const Text('Retry'),
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
              color: AppColors.warmGray,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'No categories available',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Check back later for vendor categories',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.warmGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
