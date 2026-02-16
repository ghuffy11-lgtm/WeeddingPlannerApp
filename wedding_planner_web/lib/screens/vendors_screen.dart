import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'home_screen.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  List<dynamic> _vendors = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    final categoriesResponse = await auth.api.getCategories();
    final vendorsResponse = await auth.api.getVendors(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      categoryId: _selectedCategory,
    );

    if (mounted) {
      setState(() {
        if (categoriesResponse.isSuccess) {
          _categories = categoriesResponse.responseData ?? [];
        }
        if (vendorsResponse.isSuccess) {
          _vendors = vendorsResponse.responseData ?? [];
        }
        _isLoading = false;
      });
    }
  }

  void _showVendorDetails(Map<String, dynamic> vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _VendorDetailsSheet(vendor: vendor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadData();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadData(),
            ),
          ),
          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                        _loadData();
                      },
                    ),
                  );
                }
                final category = _categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(_getCategoryIcon(category['icon']), size: 18),
                    label: Text(category['name'] ?? ''),
                    selected: _selectedCategory == category['id'],
                    onSelected: (_) {
                      setState(() => _selectedCategory = _selectedCategory == category['id'] ? null : category['id']);
                      _loadData();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Vendor Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vendors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No vendors found', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: _vendors.length,
                              itemBuilder: (context, index) {
                                final vendor = _vendors[index];
                                return _VendorCard(
                                  vendor: vendor,
                                  onTap: () => _showVendorDetails(vendor),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? icon) {
    switch (icon) {
      case 'camera_alt': return Icons.camera_alt;
      case 'videocam': return Icons.videocam;
      case 'restaurant': return Icons.restaurant;
      case 'cake': return Icons.cake;
      case 'music_note': return Icons.music_note;
      case 'local_florist': return Icons.local_florist;
      case 'palette': return Icons.palette;
      case 'location_on': return Icons.location_on;
      case 'event_note': return Icons.event_note;
      case 'face': return Icons.face;
      case 'checkroom': return Icons.checkroom;
      case 'directions_car': return Icons.directions_car;
      case 'mail': return Icons.mail;
      case 'diamond': return Icons.diamond;
      default: return Icons.store;
    }
  }
}

class _VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final VoidCallback onTap;

  const _VendorCard({required this.vendor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = double.tryParse(vendor['rating_avg']?.toString() ?? '0') ?? 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.pink[50],
              child: Center(
                child: Icon(
                  Icons.store,
                  size: 48,
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor['business_name'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (vendor['category'] != null)
                      Text(
                        vendor['category']['name'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' (${vendor['review_count'] ?? 0})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        const Spacer(),
                        Text(
                          vendor['price_range'] ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

class _VendorDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> vendor;

  const _VendorDetailsSheet({required this.vendor});

  @override
  State<_VendorDetailsSheet> createState() => _VendorDetailsSheetState();
}

class _VendorDetailsSheetState extends State<_VendorDetailsSheet> {
  List<dynamic> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getVendorPackages(widget.vendor['id']);
    if (response.isSuccess && mounted) {
      setState(() {
        _packages = response.responseData ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bookVendor(String? packageId) async {
    final auth = context.read<AuthProvider>();

    // Get wedding date from auth provider (set during onboarding)
    DateTime initialDate = DateTime.now().add(const Duration(days: 30));
    if (auth.wedding?['wedding_date'] != null) {
      final weddingDate = DateTime.tryParse(auth.wedding!['wedding_date'].toString());
      if (weddingDate != null && weddingDate.isAfter(DateTime.now())) {
        initialDate = weddingDate; // Use wedding date as default
      }
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );

    if (date == null) return;

    final response = await auth.api.createBooking({
      'vendorId': widget.vendor['id'],
      if (packageId != null) 'packageId': packageId,
      'bookingDate': date.toIso8601String().split('T')[0],
    });

    if (mounted) {
      Navigator.pop(context); // Close vendor details sheet
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request sent! Check Bookings tab.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to Bookings tab (index 5)
        Navigator.of(context).popUntil((route) => route.isFirst);
        HomeScreen.setTabIndex(context, 5);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Failed to book'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rating = double.tryParse(widget.vendor['rating_avg']?.toString() ?? '0') ?? 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.vendor['business_name'] ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(' (${widget.vendor['review_count'] ?? 0} reviews)'),
                const Spacer(),
                if (widget.vendor['is_verified'] == true)
                  Chip(
                    avatar: const Icon(Icons.verified, size: 16, color: Colors.blue),
                    label: const Text('Verified'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.vendor['description'] != null)
              Text(widget.vendor['description'], style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.vendor['location_city'] != null) ...[
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${widget.vendor['location_city']}, ${widget.vendor['location_country'] ?? ''}'),
                  const SizedBox(width: 16),
                ],
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(widget.vendor['price_range'] ?? ''),
              ],
            ),
            const SizedBox(height: 24),
            // Packages
            Text(
              'Packages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_packages.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('No packages available'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _bookVendor(null),
                        child: const Text('Contact Vendor'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_packages.map((pkg) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pkg['name'] ?? '',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${pkg['price'] ?? 0}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (pkg['description'] != null) ...[
                            const SizedBox(height: 8),
                            Text(pkg['description']),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _bookVendor(pkg['id']),
                              child: const Text('Book This Package'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))),
          ],
        ),
      ),
    );
  }
}
