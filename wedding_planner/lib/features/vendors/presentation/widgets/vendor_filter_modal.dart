import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../domain/repositories/vendor_repository.dart';

/// Modal bottom sheet for filtering vendors
class VendorFilterModal extends StatefulWidget {
  final VendorFilter initialFilter;
  final ValueChanged<VendorFilter> onApply;

  const VendorFilterModal({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required VendorFilter initialFilter,
    required ValueChanged<VendorFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VendorFilterModal(
        initialFilter: initialFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<VendorFilterModal> createState() => _VendorFilterModalState();
}

class _VendorFilterModalState extends State<VendorFilterModal> {
  late String? _priceRange;
  late double? _minRating;
  late String _sortBy;
  late String _sortOrder;

  final List<Map<String, String>> _priceRangeOptions = [
    {'value': 'budget', 'label': 'Budget (\$)'},
    {'value': 'moderate', 'label': 'Moderate (\$\$)'},
    {'value': 'premium', 'label': 'Premium (\$\$\$)'},
    {'value': 'luxury', 'label': 'Luxury (\$\$\$\$)'},
  ];

  final List<Map<String, dynamic>> _ratingOptions = [
    {'value': null, 'label': 'Any rating'},
    {'value': 3.0, 'label': '3+ stars'},
    {'value': 4.0, 'label': '4+ stars'},
    {'value': 4.5, 'label': '4.5+ stars'},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'value': 'rating_avg', 'label': 'Rating'},
    {'value': 'review_count', 'label': 'Most reviewed'},
    {'value': 'price', 'label': 'Price'},
    {'value': 'created_at', 'label': 'Newest'},
  ];

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialFilter.priceRange;
    _minRating = widget.initialFilter.minRating;
    _sortBy = widget.initialFilter.sortBy;
    _sortOrder = widget.initialFilter.sortOrder;
  }

  void _applyFilter() {
    final newFilter = widget.initialFilter.copyWith(
      priceRange: _priceRange,
      minRating: _minRating,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
    widget.onApply(newFilter);
    Navigator.of(context).pop();
  }

  void _clearFilter() {
    setState(() {
      _priceRange = null;
      _minRating = null;
      _sortBy = 'rating_avg';
      _sortOrder = 'desc';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.small),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.warmGray.withAlpha(77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
                  style: AppTypography.h2,
                ),
                TextButton(
                  onPressed: _clearFilter,
                  child: Text(
                    'Clear all',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.roseGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  Text(
                    'Price Range',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: _priceRangeOptions.map((option) {
                      final isSelected = _priceRange == option['value'];
                      return FilterChip(
                        label: Text(option['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _priceRange = selected ? option['value'] : null;
                          });
                        },
                        selectedColor: AppColors.roseGold.withAlpha(51),
                        checkmarkColor: AppColors.roseGold,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.roseGold
                              : AppColors.deepCharcoal,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.large),

                  // Rating
                  Text(
                    'Minimum Rating',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: _ratingOptions.map((option) {
                      final isSelected = _minRating == option['value'];
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (option['value'] != null) ...[
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(option['label'] as String),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _minRating = selected
                                ? option['value'] as double?
                                : null;
                          });
                        },
                        selectedColor: AppColors.roseGold.withAlpha(51),
                        checkmarkColor: AppColors.roseGold,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.roseGold
                              : AppColors.deepCharcoal,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.large),

                  // Sort By
                  Text(
                    'Sort By',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Column(
                    children: _sortOptions.map((option) {
                      final isSelected = _sortBy == option['value'];
                      return RadioListTile<String>(
                        title: Text(option['label']!),
                        value: option['value']!,
                        groupValue: _sortBy,
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                        activeColor: AppColors.roseGold,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpacing.small),

                  // Sort Order
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _sortOrder = 'desc';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.small,
                            ),
                            decoration: BoxDecoration(
                              color: _sortOrder == 'desc'
                                  ? AppColors.roseGold.withAlpha(51)
                                  : AppColors.blushRose,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(AppSpacing.radiusMedium),
                              ),
                              border: Border.all(
                                color: _sortOrder == 'desc'
                                    ? AppColors.roseGold
                                    : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  size: 18,
                                  color: _sortOrder == 'desc'
                                      ? AppColors.roseGold
                                      : AppColors.warmGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'High to Low',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: _sortOrder == 'desc'
                                        ? AppColors.roseGold
                                        : AppColors.warmGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _sortOrder = 'asc';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.small,
                            ),
                            decoration: BoxDecoration(
                              color: _sortOrder == 'asc'
                                  ? AppColors.roseGold.withAlpha(51)
                                  : AppColors.blushRose,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(AppSpacing.radiusMedium),
                              ),
                              border: Border.all(
                                color: _sortOrder == 'asc'
                                    ? AppColors.roseGold
                                    : AppColors.divider,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  size: 18,
                                  color: _sortOrder == 'asc'
                                      ? AppColors.roseGold
                                      : AppColors.warmGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Low to High',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: _sortOrder == 'asc'
                                        ? AppColors.roseGold
                                        : AppColors.warmGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
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
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: PrimaryButton(
                    text: 'Apply',
                    onPressed: _applyFilter,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
