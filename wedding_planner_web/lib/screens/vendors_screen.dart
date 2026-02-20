import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/vendor_card.dart';
import 'home_screen.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _selectedCategoryId;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    final results = await Future.wait([
      auth.api.getCategories(),
      auth.api.getVendors(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        categoryId: _selectedCategoryId,
      ),
    ]);

    if (mounted) {
      setState(() {
        if (results[0].isSuccess) {
          _categories = List<Map<String, dynamic>>.from(results[0].responseData ?? []);
        }
        if (results[1].isSuccess) {
          _vendors = List<Map<String, dynamic>>.from(results[1].responseData ?? []);
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadData();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
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
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
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
                          selected: _selectedCategoryId == null,
                          onSelected: (_) {
                            setState(() => _selectedCategoryId = null);
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
                        selected: _selectedCategoryId == category['id'],
                        onSelected: (_) {
                          setState(() {
                            _selectedCategoryId = _selectedCategoryId == category['id']
                                ? null
                                : category['id'];
                          });
                          _loadData();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            if (_isLoading)
              const SliverFillRemaining(child: LoadingState())
            else if (_vendors.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.store,
                  title: 'No vendors found',
                  subtitle: 'Try adjusting your search or filters',
                ),
              )
            else
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.crossAxisExtent > 1200
                      ? 4
                      : constraints.crossAxisExtent > 800
                          ? 3
                          : 2;
                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final vendor = _vendors[index];
                          return VendorCard(
                            vendor: vendor,
                            onTap: () => _showVendorDetails(vendor),
                          );
                        },
                        childCount: _vendors.length,
                      ),
                    ),
                  );
                },
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
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getVendorPackages(widget.vendor['id']);

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _packages = List<Map<String, dynamic>>.from(response.responseData ?? []);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _bookVendor(String? packageId) async {
    final auth = context.read<AuthProvider>();

    DateTime initialDate = DateTime.now().add(const Duration(days: 30));
    if (auth.wedding?['wedding_date'] != null) {
      final weddingDate = DateTime.tryParse(auth.wedding!['wedding_date'].toString());
      if (weddingDate != null && weddingDate.isAfter(DateTime.now())) {
        initialDate = weddingDate;
      }
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );

    if (date == null || !mounted) return;

    final response = await auth.api.createBooking({
      'vendorId': widget.vendor['id'],
      if (packageId != null) 'packageId': packageId,
      'bookingDate': date.toIso8601String().split('T')[0],
    });

    if (mounted) {
      Navigator.pop(context);
      if (response.isSuccess) {
        SnackBarHelper.showSuccess(context, 'Booking request sent!');
        HomeScreen.setTabIndex(context, 5);
      } else {
        SnackBarHelper.showError(context, response.errorMessage ?? 'Failed to book');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rating = double.tryParse(widget.vendor['rating_avg']?.toString() ?? '0') ?? 0;
    final category = widget.vendor['category'];
    final categoryName = category is Map ? category['name'] : category?.toString();

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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
            if (categoryName != null) ...[
              const SizedBox(height: 8),
              Text(
                categoryName,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            if (widget.vendor['description'] != null)
              Text(widget.vendor['description']),
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
            Text(
              'Packages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
              ..._packages.map((pkg) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pkg['name'] ?? '',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Text(
                                '\$${pkg['price'] ?? 0}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
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
                  )),
          ],
        ),
      ),
    );
  }
}
