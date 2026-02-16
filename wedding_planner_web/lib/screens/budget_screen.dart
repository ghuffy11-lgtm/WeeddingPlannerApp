import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<dynamic> _expenses = [];
  bool _isLoading = true;
  double _totalBudget = 0;
  double _totalSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    if (auth.weddingId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await auth.api.getBudget(auth.weddingId!);
    if (response.isSuccess && mounted) {
      final data = response.responseData;
      setState(() {
        _expenses = data?['items'] ?? data ?? [];
        _totalBudget = double.tryParse(data?['summary']?['budgetTotal']?.toString() ?? '0') ?? 0;
        _totalSpent = double.tryParse(data?['summary']?['actualTotal']?.toString() ?? '0') ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExpense(String id) async {
    final auth = context.read<AuthProvider>();
    await auth.api.deleteExpense(auth.weddingId!, id);
    _loadBudget();
  }

  void _showAddExpenseDialog() {
    final categoryController = TextEditingController();
    final descController = TextEditingController();
    final estimatedController = TextEditingController();
    final actualController = TextEditingController();
    bool paid = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
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
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Paid'),
                  value: paid,
                  onChanged: (v) => setDialogState(() => paid = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isEmpty) return;
                final auth = context.read<AuthProvider>();
                await auth.api.addExpense(auth.weddingId!, {
                  'category': categoryController.text,
                  'description': descController.text,
                  'estimatedAmount': double.tryParse(estimatedController.text) ?? 0,
                  'actualAmount': double.tryParse(actualController.text) ?? 0,
                  'isPaid': paid,
                });
                if (mounted) {
                  Navigator.pop(context);
                  _loadBudget();
                }
              },
              child: const Text('Add'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBudget,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Budget Overview Card
                    Card(
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
                                    Text('Total Budget', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                                    Text(
                                      '\$${_totalBudget.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Remaining', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                                    Text(
                                      '\$${remaining.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                                  percentUsed > 1 ? Colors.red : percentUsed > 0.8 ? Colors.orange : Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(percentUsed * 100).toStringAsFixed(1)}% used',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Expenses Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expenses',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_expenses.length} items',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Expenses List
                    if (_expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No expenses yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...(_expenses.map((expense) => _ExpenseCard(
                            expense: expense,
                            onDelete: () => _deleteExpense(expense['id']),
                          ))),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> expense;
  final VoidCallback onDelete;

  const _ExpenseCard({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final estimated = double.tryParse(expense['estimated_amount']?.toString() ?? '0') ?? 0;
    final actual = double.tryParse(expense['actual_amount']?.toString() ?? '0') ?? 0;
    final paid = expense['is_paid'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: paid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          child: Icon(
            paid ? Icons.check_circle : Icons.schedule,
            color: paid ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(expense['category'] ?? 'Expense'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expense['description'] != null)
              Text(expense['description'], maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Est: \$${estimated.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 16),
                Text(
                  'Actual: \$${actual.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: actual > estimated ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
