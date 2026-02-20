import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/booking_card.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  int _selectedIndex = 0;

  static const List<_NavDestination> _destinations = [
    _NavDestination(icon: Icons.dashboard, label: 'Dashboard'),
    _NavDestination(icon: Icons.inbox, label: 'Requests'),
    _NavDestination(icon: Icons.calendar_month, label: 'Bookings'),
    _NavDestination(icon: Icons.inventory_2, label: 'Packages'),
    _NavDestination(icon: Icons.settings, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vendor = auth.vendor;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Vendor Dashboard'),
          ],
        ),
        actions: [
          if (vendor != null && isWide) ...[
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vendor['business_name'] ?? '',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 8),
                  _VendorStatusBadge(status: vendor['status'] ?? 'pending'),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
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
                    if (vendor != null)
                      Text(
                        vendor['business_name'] ?? '',
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
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                _VendorDashboard(),
                _VendorRequests(),
                _VendorBookings(),
                _VendorPackages(),
                _VendorProfile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final String label;

  const _NavDestination({required this.icon, required this.label});
}

class _VendorStatusBadge extends StatelessWidget {
  final String status;

  const _VendorStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _VendorDashboard extends StatefulWidget {
  const _VendorDashboard();

  @override
  State<_VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<_VendorDashboard> {
  int _pendingRequests = 0;
  int _activeBookings = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    final results = await Future.wait([
      auth.api.getVendorRequests(),
      auth.api.getVendorBookings(),
    ]);

    if (mounted) {
      setState(() {
        if (results[0].isSuccess) {
          final data = results[0].responseData;
          _pendingRequests = data is List ? data.length : 0;
        }
        if (results[1].isSuccess) {
          final data = results[1].responseData;
          _activeBookings = data is List ? data.length : (data?['total'] ?? 0);
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vendor = auth.vendor;
    final isApproved = vendor?['status'] == 'approved';

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
            Text(
              vendor?['business_name'] ?? '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            if (!isApproved)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top, color: Colors.orange),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Under Review',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your business profile is being reviewed. You will be notified once approved.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isApproved) ...[
              const SizedBox(height: 16),
              if (_isLoading)
                const SizedBox(height: 150, child: LoadingState())
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
                      childAspectRatio: 1.4,
                      children: [
                        StatCard(
                          label: 'Pending Requests',
                          value: '$_pendingRequests',
                          icon: Icons.inbox,
                          color: Colors.orange,
                        ),
                        StatCard(
                          label: 'Active Bookings',
                          value: '$_activeBookings',
                          icon: Icons.calendar_month,
                          color: Colors.blue,
                        ),
                        StatCard(
                          label: 'Rating',
                          value: (double.tryParse(
                                      vendor?['rating_avg']?.toString() ?? '0') ??
                                  0)
                              .toStringAsFixed(1),
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                        StatCard(
                          label: 'Completed',
                          value: '${vendor?['weddings_completed'] ?? 0}',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VendorRequests extends StatefulWidget {
  const _VendorRequests();

  @override
  State<_VendorRequests> createState() => _VendorRequestsState();
}

class _VendorRequestsState extends State<_VendorRequests> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getVendorRequests();

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _requests = List<Map<String, dynamic>>.from(response.responseData ?? []);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.acceptBooking(id);

    if (response.isSuccess) {
      await _loadData();
      if (mounted) SnackBarHelper.showSuccess(context, 'Booking accepted!');
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  Future<void> _declineRequest(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.declineBooking(id);

    if (response.isSuccess) {
      await _loadData();
      if (mounted) SnackBarHelper.showInfo(context, 'Booking declined');
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _isLoading
          ? const LoadingState()
          : _requests.isEmpty
              ? const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 400,
                    child: EmptyState(
                      icon: Icons.inbox,
                      title: 'No pending requests',
                      subtitle: 'New booking requests will appear here',
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    final wedding = request['wedding'] as Map<String, dynamic>?;
                    final package = request['package'] as Map<String, dynamic>?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.pink),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${wedding?['partner1_name'] ?? ''} & ${wedding?['partner2_name'] ?? ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (package != null)
                              Text('Package: ${package['name']} - \$${package['price']}'),
                            Text(
                                'Booking Date: ${request['booking_date']?.toString().split('T')[0] ?? 'TBD'}'),
                            if (wedding?['wedding_date'] != null)
                              Text(
                                  'Wedding Date: ${wedding!['wedding_date'].toString().split('T')[0]}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _declineRequest(request['id']),
                                  child: const Text('Decline'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _acceptRequest(request['id']),
                                  child: const Text('Accept'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _VendorBookings extends StatefulWidget {
  const _VendorBookings();

  @override
  State<_VendorBookings> createState() => _VendorBookingsState();
}

class _VendorBookingsState extends State<_VendorBookings> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getVendorBookings();

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          final data = response.responseData;
          _bookings = data is List
              ? List<Map<String, dynamic>>.from(data)
              : List<Map<String, dynamic>>.from(data?['data'] ?? []);
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _isLoading
          ? const LoadingState()
          : _bookings.isEmpty
              ? const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 400,
                    child: EmptyState(
                      icon: Icons.calendar_month,
                      title: 'No bookings yet',
                      subtitle: 'Confirmed bookings will appear here',
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BookingCard(
                        booking: booking,
                        isVendorView: true,
                      ),
                    );
                  },
                ),
    );
  }
}

class _VendorPackages extends StatefulWidget {
  const _VendorPackages();

  @override
  State<_VendorPackages> createState() => _VendorPackagesState();
}

class _VendorPackagesState extends State<_VendorPackages> {
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    if (auth.vendorId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await auth.api.getVendorPackages(auth.vendorId!);

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _packages = List<Map<String, dynamic>>.from(response.responseData ?? []);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePackage(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.deletePackage(id);

    if (response.isSuccess) {
      await _loadData();
      if (mounted) SnackBarHelper.showSuccess(context, 'Package deleted');
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  void _showPackageDialog([Map<String, dynamic>? existing]) {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?['name']);
    final descController = TextEditingController(text: existing?['description']);
    final priceController =
        TextEditingController(text: existing?['price']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Package' : 'Add Package'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Package Name',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
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
              if (nameController.text.isEmpty) return;
              Navigator.pop(ctx);

              final auth = context.read<AuthProvider>();
              final data = {
                'name': nameController.text,
                'description': descController.text,
                'price': double.tryParse(priceController.text) ?? 0,
              };

              final response = isEdit
                  ? await auth.api.updatePackage(existing['id'], data)
                  : await auth.api.createPackage(data);

              if (response.isSuccess) {
                await _loadData();
                if (mounted) {
                  SnackBarHelper.showSuccess(
                      context, isEdit ? 'Package updated' : 'Package created');
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const LoadingState()
            : _packages.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 400,
                      child: EmptyState(
                        icon: Icons.inventory_2,
                        title: 'No packages yet',
                        subtitle: 'Create packages for couples to book',
                        actionLabel: 'Add Package',
                        onAction: () => _showPackageDialog(),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final pkg = _packages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            pkg['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            pkg['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${pkg['price'] ?? 0}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showPackageDialog(pkg);
                                  } else if (value == 'delete') {
                                    _deletePackage(pkg['id']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _showPackageDialog(pkg),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPackageDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Package'),
      ),
    );
  }
}

class _VendorProfile extends StatelessWidget {
  const _VendorProfile();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vendor = auth.vendor;

    return RefreshIndicator(
      onRefresh: () => auth.refreshVendor(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _ProfileRow(
                        label: 'Business Name',
                        value: vendor?['business_name'] ?? ''),
                    _ProfileRow(
                        label: 'Category',
                        value: vendor?['category']?['name'] ?? ''),
                    _ProfileRow(
                        label: 'Description',
                        value: vendor?['description'] ?? ''),
                    _ProfileRow(
                      label: 'Location',
                      value:
                          '${vendor?['location_city'] ?? ''}, ${vendor?['location_country'] ?? ''}',
                    ),
                    _ProfileRow(
                        label: 'Price Range',
                        value: vendor?['price_range'] ?? ''),
                    _ProfileRow(
                      label: 'Status',
                      value: vendor?['status']?.toString().toUpperCase() ?? '',
                    ),
                    _ProfileRow(
                      label: 'Rating',
                      value:
                          '${vendor?['rating_avg'] ?? 0} (${vendor?['review_count'] ?? 0} reviews)',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
