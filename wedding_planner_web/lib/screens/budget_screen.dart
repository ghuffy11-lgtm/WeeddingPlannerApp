import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_card.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  double _totalBudget = 0;
  double _totalSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    if (auth.weddingId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await auth.api.getBudget(auth.weddingId!);

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          final data = response.responseData;
          _expenses = List<Map<String, dynamic>>.from(data?['items'] ?? data ?? []);
          _totalBudget = double.tryParse(
                  data?['summary']?['budgetTotal']?.toString() ?? '0') ??
              0;
          _totalSpent = double.tryParse(
                  data?['summary']?['actualTotal']?.toString() ?? '0') ??
              0;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExpense(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.deleteExpense(auth.weddingId!, id);

    if (response.isSuccess) {
      await _loadData();
      if (mounted) SnackBarHelper.showSuccess(context, 'Expense deleted');
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  Future<void> _togglePaid(Map<String, dynamic> expense) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.updateExpense(
      auth.weddingId!,
      expense['id'],
      {'isPaid': !(expense['is_paid'] ?? false)},
    );

    if (response.isSuccess) {
      await _loadData();
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  void _showExpenseDialog([Map<String, dynamic>? existing]) {
    final isEdit = existing != null;
    final categoryController =
        TextEditingController(text: existing?['category']);
    final descController =
        TextEditingController(text: existing?['description']);
    final estimatedController = TextEditingController(
        text: existing?['estimated_amount']?.toString() ?? '');
    final actualController = TextEditingController(
        text: existing?['actual_amount']?.toString() ?? '');
    bool isPaid = existing?['is_paid'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Expense' : 'Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                    hintText: 'e.g., Venue, Catering, Photography',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: estimatedController,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Cost',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: actualController,
                  decoration: const InputDecoration(
                    labelText: 'Actual Cost',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: isPaid,
                  onChanged: (v) => setDialogState(() => isPaid = v ?? false),
                  title: const Text('Paid'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isEmpty) return;
                Navigator.pop(ctx);

                final auth = context.read<AuthProvider>();
                final data = {
                  'category': categoryController.text,
                  'description': descController.text,
                  'estimatedAmount':
                      double.tryParse(estimatedController.text) ?? 0,
                  'actualAmount': double.tryParse(actualController.text) ?? 0,
                  'isPaid': isPaid,
                };

                final response = isEdit
                    ? await auth.api
                        .updateExpense(auth.weddingId!, existing['id'], data)
                    : await auth.api.addExpense(auth.weddingId!, data);

                if (response.isSuccess) {
                  await _loadData();
                  if (mounted) {
                    SnackBarHelper.showSuccess(
                        context, isEdit ? 'Expense updated' : 'Expense added');
                  }
                } else if (mounted) {
                  SnackBarHelper.showError(
                      context, response.errorMessage ?? 'Failed');
                }
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _totalBudget - _totalSpent;
    final percentUsed = _totalBudget > 0 ? (_totalSpent / _totalBudget) : 0.0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildOverviewCard(context, remaining, percentUsed),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${_expenses.length} items',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            if (_isLoading)
              const SliverFillRemaining(child: LoadingState())
            else if (_expenses.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.receipt_long,
                  title: 'No expenses yet',
                  subtitle: 'Track your wedding budget',
                  actionLabel: 'Add Expense',
                  onAction: () => _showExpenseDialog(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = _expenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ExpenseCard(
                          expense: expense,
                          onTap: () => _showExpenseDialog(expense),
                          onTogglePaid: () => _togglePaid(expense),
                          onDelete: () => _deleteExpense(expense['id']),
                        ),
                      );
                    },
                    childCount: _expenses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildOverviewCard(
      BuildContext context, double remaining, double percentUsed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Budget',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '\$${_totalBudget.toStringAsFixed(0)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      '\$${remaining.toStringAsFixed(0)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: remaining >= 0 ? Colors.green : Colors.red,
                              ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentUsed.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  percentUsed > 1
                      ? Colors.red
                      : percentUsed > 0.8
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentUsed * 100).toStringAsFixed(1)}% used',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
