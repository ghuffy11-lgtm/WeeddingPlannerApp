import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class AddEditExpensePage extends StatefulWidget {
  final String? expenseId;

  const AddEditExpensePage({super.key, this.expenseId});

  bool get isEditing => expenseId != null;

  @override
  State<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _actualCostController = TextEditingController();
  final _notesController = TextEditingController();

  BudgetCategory _category = BudgetCategory.other;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  DateTime? _dueDate;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      context.read<BudgetBloc>().add(LoadExpenseDetail(widget.expenseId!));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _actualCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFromExpense(Expense expense) {
    if (_isInitialized) return;
    _isInitialized = true;

    _titleController.text = expense.title;
    _descriptionController.text = expense.description ?? '';
    _estimatedCostController.text = expense.estimatedCost.toStringAsFixed(0);
    _actualCostController.text = expense.actualCost.toStringAsFixed(0);
    _notesController.text = expense.notes ?? '';
    _category = expense.category;
    _paymentStatus = expense.paymentStatus;
    _dueDate = expense.dueDate;
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
          widget.isEditing ? 'Edit Expense' : 'Add Expense',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == BudgetActionStatus.success) {
            context.pop();
          } else if (state.actionStatus == BudgetActionStatus.error &&
              state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<BudgetBloc>().add(const ClearBudgetError());
          }
        },
        builder: (context, state) {
          // Initialize form for editing
          if (widget.isEditing && state.selectedExpense != null) {
            _initializeFromExpense(state.selectedExpense!);
          }

          if (widget.isEditing &&
              state.detailStatus == ExpenseDetailStatus.loading) {
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
                  // Title
                  _buildSectionTitle('Title'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Expense name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Category
                  _buildSectionTitle('Category'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BudgetCategory.values.map((category) {
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

                  // Costs
                  _buildSectionTitle('Cost'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _estimatedCostController,
                          label: 'Estimated (\$)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _actualCostController,
                          label: 'Actual (\$)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Payment Status
                  _buildSectionTitle('Payment Status'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PaymentStatus.values.map((status) {
                      final isSelected = _paymentStatus == status;
                      return GlassChip(
                        label: '${status.icon} ${status.displayName}',
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _paymentStatus = status);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Due Date
                  _buildSectionTitle('Due Date (Optional)'),
                  const SizedBox(height: 8),
                  GlassCard(
                    onTap: _selectDueDate,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _dueDate != null
                              ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                              : 'Select due date',
                          style: AppTypography.bodyMedium.copyWith(
                            color: _dueDate != null
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() => _dueDate = null);
                            },
                            child: Icon(
                              Icons.close,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _buildSectionTitle('Description (Optional)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Brief description',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Notes
                  _buildSectionTitle('Notes (Optional)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _notesController,
                    label: 'Additional notes',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  GlassButton(
                    onTap: state.actionStatus == BudgetActionStatus.loading
                        ? null
                        : _handleSubmit,
                    isPrimary: true,
                    width: double.infinity,
                    height: 56,
                    child: state.actionStatus == BudgetActionStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isEditing ? 'Save Changes' : 'Add Expense',
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

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final estimatedCost =
        double.tryParse(_estimatedCostController.text.trim()) ?? 0;
    final actualCost =
        double.tryParse(_actualCostController.text.trim()) ?? 0;

    // Calculate paid amount based on status
    double paidAmount = 0;
    if (_paymentStatus == PaymentStatus.paid) {
      paidAmount = actualCost;
    } else if (_paymentStatus == PaymentStatus.partiallyPaid) {
      paidAmount = actualCost * 0.5; // Default to 50% for partial
    }

    final request = ExpenseRequest(
      category: _category,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      estimatedCost: estimatedCost,
      actualCost: actualCost,
      paymentStatus: _paymentStatus,
      paidAmount: paidAmount,
      dueDate: _dueDate,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (widget.isEditing) {
      context.read<BudgetBloc>().add(UpdateExpense(
            expenseId: widget.expenseId!,
            request: request,
          ));
    } else {
      context.read<BudgetBloc>().add(CreateExpense(request));
    }
  }
}
