import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../widgets/loading_state.dart';
import '../widgets/stat_card.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _taskStats;
  Map<String, dynamic>? _budgetSummary;
  int _guestCount = 0;
  int _bookingCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    await auth.refreshWedding();

    final results = await Future.wait([
      auth.api.getTaskStats(),
      auth.api.getBudgetSummary(),
      auth.api.getMyBookings(),
      if (auth.weddingId != null) auth.api.getGuests(auth.weddingId!),
    ]);

    if (mounted) {
      final taskStatsResponse = results[0];
      final budgetResponse = results[1];
      final bookingsResponse = results[2];

      setState(() {
        if (taskStatsResponse.isSuccess) {
          _taskStats = taskStatsResponse.responseData;
        }
        if (budgetResponse.isSuccess) {
          _budgetSummary = budgetResponse.responseData?['summary'] ??
              budgetResponse.responseData;
        }
        if (bookingsResponse.isSuccess) {
          final data = bookingsResponse.responseData;
          _bookingCount = data is List ? data.length : (data?['total'] ?? 0);
        }
        if (results.length > 3 && results[3].isSuccess) {
          final guestData = results[3].responseData;
          _guestCount =
              guestData is List ? guestData.length : (guestData?['total'] ?? 0);
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wedding = auth.wedding;

    final weddingDate = wedding?['wedding_date'] != null
        ? DateTime.tryParse(wedding!['wedding_date'])
        : null;
    final daysUntil =
        weddingDate?.difference(DateTime.now()).inDays;

    final budgetSpent = _budgetSummary?['actualTotal'] ??
        _budgetSummary?['budget_spent'] ??
        wedding?['budget_spent'] ??
        0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (wedding != null)
              Text(
                '${wedding['partner1_name'] ?? ''} & ${wedding['partner2_name'] ?? ''}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            const SizedBox(height: 24),
            if (daysUntil != null) _buildCountdownCard(context, daysUntil),
            const SizedBox(height: 24),
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const SizedBox(
                height: 150,
                child: LoadingState(),
              )
            else
              _buildStatsGrid(context, budgetSpent),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard(BuildContext context, int daysUntil) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.favorite, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              '$daysUntil',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              daysUntil == 1 ? 'Day Until Your Wedding' : 'Days Until Your Wedding',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic budgetSpent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            StatCard(
              label: 'Tasks Done',
              value: '${_taskStats?['completed'] ?? 0}/${_taskStats?['total'] ?? 0}',
              icon: Icons.task_alt,
              color: Colors.green,
              onTap: () => HomeScreen.setTabIndex(context, 1),
            ),
            StatCard(
              label: 'Guests',
              value: '$_guestCount',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => HomeScreen.setTabIndex(context, 2),
            ),
            StatCard(
              label: 'Bookings',
              value: '$_bookingCount',
              icon: Icons.calendar_month,
              color: Colors.orange,
              onTap: () => HomeScreen.setTabIndex(context, 5),
            ),
            StatCard(
              label: 'Budget Spent',
              value:
                  '\$${double.tryParse(budgetSpent.toString())?.toStringAsFixed(0) ?? '0'}',
              icon: Icons.attach_money,
              color: Colors.purple,
              onTap: () => HomeScreen.setTabIndex(context, 3),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ActionChip(
          avatar: const Icon(Icons.add_task, size: 18),
          label: const Text('Add Task'),
          onPressed: () => HomeScreen.setTabIndex(context, 1),
        ),
        ActionChip(
          avatar: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Guest'),
          onPressed: () => HomeScreen.setTabIndex(context, 2),
        ),
        ActionChip(
          avatar: const Icon(Icons.receipt_long, size: 18),
          label: const Text('Add Expense'),
          onPressed: () => HomeScreen.setTabIndex(context, 3),
        ),
        ActionChip(
          avatar: const Icon(Icons.store, size: 18),
          label: const Text('Find Vendors'),
          onPressed: () => HomeScreen.setTabIndex(context, 4),
        ),
      ],
    );
  }
}
