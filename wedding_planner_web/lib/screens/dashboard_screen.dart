import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _budgetSummary;
  int _guestCount = 0;
  int _bookingCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    // Refresh wedding data to get latest counts
    await auth.refreshWedding();

    // Fetch task stats and budget summary
    final taskStatsResponse = await auth.api.getTaskStats();
    final budgetResponse = await auth.api.getBudgetSummary();
    final bookingsResponse = await auth.api.getMyBookings();

    // Fetch guests if wedding exists
    int guestCount = 0;
    if (auth.weddingId != null) {
      final guestsResponse = await auth.api.getGuests(auth.weddingId!);
      if (guestsResponse.isSuccess) {
        final guestData = guestsResponse.responseData;
        guestCount = guestData is List ? guestData.length : (guestData?['total'] ?? 0);
      }
    }

    if (mounted) {
      setState(() {
        // Task stats
        if (taskStatsResponse.isSuccess) {
          _stats = taskStatsResponse.responseData;
        }
        // Budget summary
        if (budgetResponse.isSuccess) {
          _budgetSummary = budgetResponse.responseData?['summary'] ?? budgetResponse.responseData;
        }
        // Guest count
        _guestCount = guestCount;
        // Booking count
        if (bookingsResponse.isSuccess) {
          final bookingData = bookingsResponse.responseData;
          _bookingCount = bookingData is List ? bookingData.length : (bookingData?['total'] ?? 0);
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wedding = auth.wedding;
    final daysUntil = wedding?['wedding_date'] != null
        ? DateTime.parse(wedding!['wedding_date']).difference(DateTime.now()).inDays
        : null;

    // Use fresh budget data from API
    final budgetSpent = _budgetSummary?['actualTotal'] ?? _budgetSummary?['budget_spent'] ?? wedding?['budget_spent'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (wedding != null)
              Text(
                '${wedding['partner1_name']} & ${wedding['partner2_name']}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            const SizedBox(height: 24),

            // Countdown Card
            if (daysUntil != null)
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, Colors.pink[300]!],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.favorite, size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        '$daysUntil',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Days Until Your Wedding',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Stats Grid
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        icon: Icons.task_alt,
                        label: 'Tasks Completed',
                        value: '${_stats?['completed'] ?? 0}/${_stats?['total'] ?? 0}',
                        color: Colors.green,
                      ),
                      _StatCard(
                        icon: Icons.people,
                        label: 'Guests',
                        value: '$_guestCount',
                        color: Colors.blue,
                      ),
                      _StatCard(
                        icon: Icons.calendar_month,
                        label: 'Bookings',
                        value: '$_bookingCount',
                        color: Colors.orange,
                      ),
                      _StatCard(
                        icon: Icons.attach_money,
                        label: 'Budget Spent',
                        value: '\$${double.tryParse(budgetSpent.toString())?.toStringAsFixed(0) ?? 0}',
                        color: Colors.purple,
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickActionChip(
                  icon: Icons.add_task,
                  label: 'Add Task',
                  onTap: () => HomeScreen.setTabIndex(context, 1), // Tasks tab
                ),
                _QuickActionChip(
                  icon: Icons.person_add,
                  label: 'Add Guest',
                  onTap: () => HomeScreen.setTabIndex(context, 2), // Guests tab
                ),
                _QuickActionChip(
                  icon: Icons.receipt_long,
                  label: 'Add Expense',
                  onTap: () => HomeScreen.setTabIndex(context, 3), // Budget tab
                ),
                _QuickActionChip(
                  icon: Icons.store,
                  label: 'Find Vendors',
                  onTap: () => HomeScreen.setTabIndex(context, 4), // Vendors tab
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
