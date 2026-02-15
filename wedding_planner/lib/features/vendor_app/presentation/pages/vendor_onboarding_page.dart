import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../vendors/domain/entities/category.dart';
import '../../../vendors/presentation/bloc/vendor_bloc.dart';
import '../../../vendors/presentation/bloc/vendor_event.dart';
import '../../../vendors/presentation/bloc/vendor_state.dart';
import '../../domain/repositories/vendor_app_repository.dart';
import '../bloc/vendor_packages_bloc.dart';
import '../bloc/vendor_packages_event.dart';
import '../bloc/vendor_packages_state.dart';

/// Vendor Onboarding Page
/// Shown after vendor registration to set up business profile
class VendorOnboardingPage extends StatefulWidget {
  const VendorOnboardingPage({super.key});

  @override
  State<VendorOnboardingPage> createState() => _VendorOnboardingPageState();
}

class _VendorOnboardingPageState extends State<VendorOnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  final Set<String> _selectedCategoryIds = {};
  String? _selectedPriceRange;
  int _currentStep = 0;
  bool _isSubmitting = false;

  final List<String> _priceRanges = ['budget', 'moderate', 'premium', 'luxury'];

  @override
  void initState() {
    super.initState();
    // Load categories
    context.read<VendorBloc>().add(const VendorCategoriesRequested());
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate business info
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      // Validate category selection
      if (_selectedCategoryIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one category'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      // Submit
      _submitOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitOnboarding() {
    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Use the first selected category for registration
    // (backend currently only supports single category)
    final primaryCategoryId = _selectedCategoryIds.first;

    context.read<VendorPackagesBloc>().add(
          RegisterVendorProfile(
            RegisterVendorRequest(
              businessName: _businessNameController.text.trim(),
              categoryId: primaryCategoryId,
              description: _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
              priceRange: _selectedPriceRange,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VendorPackagesBloc, VendorPackagesState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == PackageActionStatus.success) {
          // Navigate to vendor dashboard
          context.go(AppRoutes.vendorHome);
        } else if (state.actionStatus == PackageActionStatus.error) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError ?? 'Failed to save profile'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Stack(
          children: [
            // Background glows
            const BackgroundGlow(
              color: AppColors.accentPurple,
              alignment: Alignment(-0.8, -0.6),
              size: 350,
            ),
            const BackgroundGlow(
              color: AppColors.primary,
              alignment: Alignment(0.9, 0.5),
              size: 300,
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  _buildProgressBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: _buildCurrentStep(),
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                GlassIconButton(
                  icon: Icons.arrow_back,
                  onTap: _previousStep,
                )
              else
                const SizedBox(width: 40),
              Text(
                'Step ${_currentStep + 1} of 3',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Skip onboarding
                  context.go(AppRoutes.vendorHome);
                },
                child: Text(
                  'Skip',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: constraints.maxWidth * ((_currentStep + 1) / 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBusinessInfoStep();
      case 1:
        return _buildCategoryStep();
      case 2:
        return _buildPriceRangeStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBusinessInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about\nyour business',
            style: AppTypography.hero.copyWith(
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'This information will be shown to couples looking for vendors.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Business Name
          _buildTextField(
            controller: _businessNameController,
            label: 'Business Name',
            hint: 'e.g., Elegant Photography Studio',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.base),

          // Description
          _buildTextField(
            controller: _descriptionController,
            label: 'Description (Optional)',
            hint: 'Tell couples what makes your service special...',
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.base),

          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number (Optional)',
            hint: '+1 234 567 8900',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What services\ndo you offer?',
          style: AppTypography.hero.copyWith(
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          'Select all categories that apply to your business.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        BlocBuilder<VendorBloc, VendorState>(
          builder: (context, state) {
            if (state.isLoadingCategories) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.categories.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No categories available',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: state.categories.map((category) {
                final isSelected = _selectedCategoryIds.contains(category.id);
                return _CategoryChip(
                  category: category,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategoryIds.remove(category.id);
                      } else {
                        _selectedCategoryIds.add(category.id);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),

        if (_selectedCategoryIds.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.large),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedCategoryIds.length} ${_selectedCategoryIds.length == 1 ? 'category' : 'categories'} selected',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceRangeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your\nprice range?',
          style: AppTypography.hero.copyWith(
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          'Help couples find you based on their budget.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        ..._priceRanges.map((range) {
          final isSelected = _selectedPriceRange == range;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PriceRangeCard(
              range: range,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedPriceRange = range;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              validator: validator,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.glassBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: PrimaryButton(
        text: _currentStep == 2 ? 'Complete Setup' : 'Continue',
        isLoading: _isSubmitting,
        onPressed: _nextStep,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category.name),
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('photo')) return Icons.camera_alt;
    if (lowerName.contains('video')) return Icons.videocam;
    if (lowerName.contains('cater')) return Icons.restaurant;
    if (lowerName.contains('cake')) return Icons.cake;
    if (lowerName.contains('music') || lowerName.contains('dj')) return Icons.music_note;
    if (lowerName.contains('flower')) return Icons.local_florist;
    if (lowerName.contains('decor')) return Icons.celebration;
    if (lowerName.contains('venue')) return Icons.location_on;
    if (lowerName.contains('makeup') || lowerName.contains('beauty')) return Icons.face;
    if (lowerName.contains('dress') || lowerName.contains('attire')) return Icons.checkroom;
    if (lowerName.contains('invitation')) return Icons.mail;
    if (lowerName.contains('transport')) return Icons.directions_car;
    return Icons.store;
  }
}

class _PriceRangeCard extends StatelessWidget {
  final String range;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriceRangeCard({
    required this.range,
    required this.isSelected,
    required this.onTap,
  });

  String get _displayText {
    switch (range) {
      case 'budget':
        return '\$ Budget-Friendly';
      case 'moderate':
        return '\$\$ Moderate';
      case 'premium':
        return '\$\$\$ Premium';
      case 'luxury':
        return '\$\$\$\$ Luxury';
      default:
        return range;
    }
  }

  String get _description {
    switch (range) {
      case 'budget':
        return 'Great value for couples on a budget';
      case 'moderate':
        return 'Balanced quality and affordability';
      case 'premium':
        return 'High-quality services with premium features';
      case 'luxury':
        return 'Exclusive, top-tier experiences';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayText,
                    style: AppTypography.h4.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
