import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../vendors/domain/entities/vendor_package.dart';
import '../../domain/repositories/vendor_app_repository.dart';
import '../bloc/vendor_packages_bloc.dart';
import '../bloc/vendor_packages_event.dart';
import '../bloc/vendor_packages_state.dart';

class AddEditPackagePage extends StatefulWidget {
  final VendorPackage? package;

  const AddEditPackagePage({
    super.key,
    this.package,
  });

  @override
  State<AddEditPackagePage> createState() => _AddEditPackagePageState();
}

class _AddEditPackagePageState extends State<AddEditPackagePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _featureController;
  late List<String> _features;
  late bool _isPopular;

  bool get _isEditing => widget.package != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.package?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.package?.price.toStringAsFixed(0) ?? '',
    );
    _durationController = TextEditingController(
      text: widget.package?.durationHours?.toString() ?? '',
    );
    _featureController = TextEditingController();
    _features = List.from(widget.package?.features ?? []);
    _isPopular = widget.package?.isPopular ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  void _addFeature() {
    final feature = _featureController.text.trim();
    if (feature.isNotEmpty && !_features.contains(feature)) {
      setState(() {
        _features.add(feature);
        _featureController.clear();
      });
    }
  }

  void _removeFeature(String feature) {
    setState(() {
      _features.remove(feature);
    });
  }

  void _savePackage() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text);
    final duration = _durationController.text.isNotEmpty
        ? int.parse(_durationController.text)
        : null;

    if (_isEditing) {
      context.read<VendorPackagesBloc>().add(
            UpdateVendorPackage(
              packageId: widget.package!.id,
              request: UpdatePackageRequest(
                name: name,
                description: description.isNotEmpty ? description : null,
                price: price,
                features: _features,
                durationHours: duration,
                isPopular: _isPopular,
              ),
            ),
          );
    } else {
      context.read<VendorPackagesBloc>().add(
            CreateVendorPackage(
              CreatePackageRequest(
                name: name,
                description: description.isNotEmpty ? description : null,
                price: price,
                features: _features,
                durationHours: duration,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
          color: AppColors.textPrimary,
        ),
        title: Text(
          _isEditing ? 'Edit Package' : 'Add Package',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocListener<VendorPackagesBloc, VendorPackagesState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == PackageActionStatus.success) {
            context.pop();
          } else if (state.actionStatus == PackageActionStatus.error &&
              state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<VendorPackagesBloc>().add(const ClearPackageAction());
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Package Name',
                hint: 'e.g., Premium Wedding Photography',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a package name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe what this package includes',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Price
              _buildTextField(
                controller: _priceController,
                label: 'Price (KWD)',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration
              _buildTextField(
                controller: _durationController,
                label: 'Duration (hours)',
                hint: 'Optional',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),

              // Features
              Text(
                'Features',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Add feature input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _featureController,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _inputDecoration('Add a feature'),
                      onSubmitted: (_) => _addFeature(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _addFeature,
                    icon: const Icon(Icons.add_circle),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Features list
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _features.map((feature) {
                  return Chip(
                    label: Text(
                      feature,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteIconColor: AppColors.textSecondary,
                    onDeleted: () => _removeFeature(feature),
                    backgroundColor: AppColors.glassBackground,
                    side: BorderSide(color: AppColors.glassBorder),
                  );
                }).toList(),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 24),
                // Popular toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mark as Popular',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Highlight this package for customers',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isPopular,
                        onChanged: (value) {
                          setState(() {
                            _isPopular = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Save Button
              BlocBuilder<VendorPackagesBloc, VendorPackagesState>(
                builder: (context, state) {
                  final isLoading =
                      state.actionStatus == PackageActionStatus.loading;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _savePackage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(_isEditing ? 'Save Changes' : 'Create Package'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
