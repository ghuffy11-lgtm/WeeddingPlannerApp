import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Vendor Dashboard'),
          ],
        ),
        actions: [
          if (auth.vendor != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Row(
                  children: [
                    Text(auth.vendor!['business_name'] ?? ''),
                    const SizedBox(width: 8),
                    _StatusBadge(status: auth.vendor!['status'] ?? 'pending'),
                  ],
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
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.inbox), label: Text('Requests')),
              NavigationRailDestination(icon: Icon(Icons.calendar_month), label: Text('Bookings')),
              NavigationRailDestination(icon: Icon(Icons.inventory_2), label: Text('Packages')),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Profile')),
            ],
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
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
    _loadStats();
  }

  Future<void> _loadStats() async {
    final auth = context.read<AuthProvider>();
    final requestsResponse = await auth.api.getVendorRequests();
    final bookingsResponse = await auth.api.getVendorBookings();

    if (mounted) {
      setState(() {
        if (requestsResponse.isSuccess) {
          final data = requestsResponse.responseData;
          _pendingRequests = data is List ? data.length : 0;
        }
        if (bookingsResponse.isSuccess) {
          final data = bookingsResponse.responseData;
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

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              vendor?['business_name'] ?? '',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 24),
            if (vendor?['status'] == 'pending')
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
                            Text('Profile Under Review', style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              'Your business profile is being reviewed by our team. You will be notified once approved.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (vendor?['status'] == 'approved') ...[
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.inbox,
                            label: 'Pending Requests',
                            value: '$_pendingRequests',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.calendar_month,
                            label: 'Active Bookings',
                            value: '$_activeBookings',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star,
                            label: 'Rating',
                            value: '${double.tryParse(vendor?['rating_avg']?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0'}',
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            label: 'Completed',
                            value: '${vendor?['weddings_completed'] ?? 0}',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
            ],
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

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
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
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getVendorRequests();

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _requests = response.responseData ?? [];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.acceptBooking(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.isSuccess ? 'Booking accepted!' : response.errorMessage ?? 'Failed'),
          backgroundColor: response.isSuccess ? Colors.green : Colors.red,
        ),
      );
      if (response.isSuccess) _loadRequests();
    }
  }

  Future<void> _declineRequest(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.declineBooking(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.isSuccess ? 'Booking declined' : response.errorMessage ?? 'Failed'),
          backgroundColor: response.isSuccess ? Colors.orange : Colors.red,
        ),
      );
      if (response.isSuccess) _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No pending requests', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final wedding = request['wedding'];
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
                                  Text(
                                    '${wedding?['partner1_name'] ?? ''} & ${wedding?['partner2_name'] ?? ''}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (request['package'] != null)
                                Text('Package: ${request['package']['name']} - \$${request['package']['price']}'),
                              Text('Date: ${request['booking_date']?.toString().split('T')[0] ?? 'TBD'}'),
                              if (wedding?['wedding_date'] != null)
                                Text('Wedding Date: ${wedding['wedding_date'].toString().split('T')[0]}'),
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
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getVendorBookings();

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          final data = response.responseData;
          _bookings = data is List ? data : (data?['data'] ?? []);
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No bookings yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final wedding = booking['wedding'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(booking['status']).withOpacity(0.1),
                            child: Icon(Icons.event, color: _getStatusColor(booking['status'])),
                          ),
                          title: Text('${wedding?['partner1_name'] ?? ''} & ${wedding?['partner2_name'] ?? ''}'),
                          subtitle: Text('${booking['booking_date']?.toString().split('T')[0] ?? ''} - ${booking['status']}'),
                          trailing: Text('\$${booking['total_amount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class _VendorPackages extends StatefulWidget {
  const _VendorPackages();

  @override
  State<_VendorPackages> createState() => _VendorPackagesState();
}

class _VendorPackagesState extends State<_VendorPackages> {
  List<dynamic> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
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
          _packages = response.responseData ?? [];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _packages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No packages yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {}, // TODO: Add package dialog
                        icon: const Icon(Icons.add),
                        label: const Text('Add Package'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPackages,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final pkg = _packages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(pkg['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(pkg['description'] ?? ''),
                          trailing: Text('\$${pkg['price'] ?? 0}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor)),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // TODO: Add package dialog
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Profile', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileRow(label: 'Business Name', value: vendor?['business_name'] ?? ''),
                  _ProfileRow(label: 'Category', value: vendor?['category']?['name'] ?? ''),
                  _ProfileRow(label: 'Description', value: vendor?['description'] ?? ''),
                  _ProfileRow(label: 'Location', value: '${vendor?['location_city'] ?? ''}, ${vendor?['location_country'] ?? ''}'),
                  _ProfileRow(label: 'Price Range', value: vendor?['price_range'] ?? ''),
                  _ProfileRow(label: 'Status', value: vendor?['status']?.toString().toUpperCase() ?? ''),
                  _ProfileRow(label: 'Rating', value: '${vendor?['rating_avg'] ?? 0} (${vendor?['review_count'] ?? 0} reviews)'),
                ],
              ),
            ),
          ),
        ],
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
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
