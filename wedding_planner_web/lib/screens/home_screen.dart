import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'guests_screen.dart';
import 'budget_screen.dart';
import 'vendors_screen.dart';
import 'bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final GlobalKey<_HomeScreenState> homeKey = GlobalKey<_HomeScreenState>();

  static void setTabIndex(BuildContext context, int index) {
    homeKey.currentState?.setTabIndex(index);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void setTabIndex(int index) {
    if (mounted && index >= 0 && index < _destinations.length) {
      setState(() => _selectedIndex = index);
    }
  }

  static const List<_NavDestination> _destinations = [
    _NavDestination(icon: Icons.dashboard, label: 'Dashboard'),
    _NavDestination(icon: Icons.task_alt, label: 'Tasks'),
    _NavDestination(icon: Icons.people, label: 'Guests'),
    _NavDestination(icon: Icons.account_balance_wallet, label: 'Budget'),
    _NavDestination(icon: Icons.store, label: 'Vendors'),
    _NavDestination(icon: Icons.calendar_month, label: 'Bookings'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width > 800;
    final wedding = auth.wedding;
    final partnerNames = wedding != null
        ? '${wedding['partner1_name'] ?? ''} & ${wedding['partner2_name'] ?? ''}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Wedding Planner'),
          ],
        ),
        actions: [
          if (partnerNames != null && isWide)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  partnerNames,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') auth.logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.email ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (partnerNames != null)
                      Text(
                        partnerNames,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isWide) ...[
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(
                          d.icon,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                DashboardScreen(),
                TasksScreen(),
                GuestsScreen(),
                BudgetScreen(),
                VendorsScreen(),
                BookingsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: _destinations
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        label: d.label,
                      ))
                  .toList(),
            ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final String label;

  const _NavDestination({required this.icon, required this.label});
}
