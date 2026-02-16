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

  // Global key to access state from anywhere
  static final GlobalKey<_HomeScreenState> homeKey = GlobalKey<_HomeScreenState>();

  // Static method to set tab index from other screens
  static void setTabIndex(BuildContext context, int index) {
    homeKey.currentState?.setTabIndex(index);
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Method to set tab index from external calls
  void setTabIndex(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }

  final List<NavigationItem> _items = [
    NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
    NavigationItem(icon: Icons.task_alt, label: 'Tasks'),
    NavigationItem(icon: Icons.people, label: 'Guests'),
    NavigationItem(icon: Icons.account_balance_wallet, label: 'Budget'),
    NavigationItem(icon: Icons.store, label: 'Vendors'),
    NavigationItem(icon: Icons.calendar_month, label: 'Bookings'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Wedding Planner'),
          ],
        ),
        actions: [
          if (auth.wedding != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${auth.wedding!['partner1_name'] ?? ''} & ${auth.wedding!['partner2_name'] ?? ''}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(child: Icon(Icons.person)),
            onSelected: (value) {
              if (value == 'logout') auth.logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(auth.email ?? ''),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Sign Out', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // Side Navigation (for wide screens)
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              destinations: _items
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.icon, color: Theme.of(context).primaryColor),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
          if (isWide) const VerticalDivider(width: 1),
          // Main Content
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
      // Bottom Navigation (for narrow screens)
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: _items
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label,
                      ))
                  .toList(),
            ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
