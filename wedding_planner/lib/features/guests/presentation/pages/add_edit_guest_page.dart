import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/guest.dart';
import '../bloc/guest_bloc.dart';
import '../bloc/guest_event.dart';
import '../bloc/guest_state.dart';

class AddEditGuestPage extends StatefulWidget {
  final String? guestId;

  const AddEditGuestPage({super.key, this.guestId});

  bool get isEditing => guestId != null;

  @override
  State<AddEditGuestPage> createState() => _AddEditGuestPageState();
}

class _AddEditGuestPageState extends State<AddEditGuestPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _dietaryNotesController = TextEditingController();

  GuestCategory _category = GuestCategory.friends;
  GuestSide _side = GuestSide.both;
  int _plusOnes = 0;
  MealPreference _mealPreference = MealPreference.standard;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      context.read<GuestBloc>().add(LoadGuestDetail(widget.guestId!));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _dietaryNotesController.dispose();
    super.dispose();
  }

  void _initializeFromGuest(Guest guest) {
    if (_isInitialized) return;
    _isInitialized = true;

    _firstNameController.text = guest.firstName;
    _lastNameController.text = guest.lastName;
    _emailController.text = guest.email ?? '';
    _phoneController.text = guest.phone ?? '';
    _addressController.text = guest.address ?? '';
    _notesController.text = guest.notes ?? '';
    _dietaryNotesController.text = guest.dietaryNotes ?? '';
    _category = guest.category;
    _side = guest.side;
    _plusOnes = guest.plusOnes;
    _mealPreference = guest.mealPreference;
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
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppColors.textPrimary,
        ),
        title: Text(
          widget.isEditing ? 'Edit Guest' : 'Add Guest',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<GuestBloc, GuestState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == GuestActionStatus.success) {
            context.pop();
          } else if (state.actionStatus == GuestActionStatus.error &&
              state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<GuestBloc>().add(const ClearGuestError());
          }
        },
        builder: (context, state) {
          // Initialize form for editing
          if (widget.isEditing && state.selectedGuest != null) {
            _initializeFromGuest(state.selectedGuest!);
          }

          if (widget.isEditing &&
              state.detailStatus == GuestDetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Section
                  _buildSectionTitle('Name'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contact Section
                  _buildSectionTitle('Contact (Optional)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Category & Side
                  _buildSectionTitle('Category'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GuestCategory.values.map((category) {
                      final isSelected = _category == category;
                      return GlassChip(
                        label: '${category.icon} ${category.displayName}',
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _category = category);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Side'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: GuestSide.values.map((side) {
                      final isSelected = _side == side;
                      return GlassChip(
                        label: side.displayName,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _side = side);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Plus Ones
                  _buildSectionTitle('Plus Ones'),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Additional guests',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _plusOnes > 0
                                  ? () => setState(() => _plusOnes--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: _plusOnes > 0
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$_plusOnes',
                                textAlign: TextAlign.center,
                                style: AppTypography.h4.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _plusOnes < 10
                                  ? () => setState(() => _plusOnes++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: _plusOnes < 10
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Meal Preference
                  _buildSectionTitle('Meal Preference'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MealPreference.values.map((pref) {
                      final isSelected = _mealPreference == pref;
                      return GlassChip(
                        label: pref.displayName,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _mealPreference = pref);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _dietaryNotesController,
                    label: 'Dietary Notes (allergies, restrictions)',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Notes
                  _buildSectionTitle('Notes (Optional)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Additional notes about this guest',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  GlassButton(
                    onTap: state.actionStatus == GuestActionStatus.loading
                        ? null
                        : _handleSubmit,
                    isPrimary: true,
                    width: double.infinity,
                    height: 56,
                    child: state.actionStatus == GuestActionStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isEditing ? 'Save Changes' : 'Add Guest',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 12,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorStyle: AppTypography.bodySmall.copyWith(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final request = GuestRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      category: _category,
      side: _side,
      plusOnes: _plusOnes,
      mealPreference: _mealPreference,
      dietaryNotes: _dietaryNotesController.text.trim().isNotEmpty
          ? _dietaryNotesController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (widget.isEditing) {
      context.read<GuestBloc>().add(UpdateGuest(
            guestId: widget.guestId!,
            request: request,
          ));
    } else {
      context.read<GuestBloc>().add(CreateGuest(request));
    }
  }
}
