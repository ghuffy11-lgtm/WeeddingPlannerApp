import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/booking_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _filter = 'All';

  static const List<String> _filterOptions = [
    'All',
    'Pending',
    'Accepted',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getMyBookings();

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _bookings = List<Map<String, dynamic>>.from(response.responseData ?? []);
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_filter == 'All') return _bookings;
    return _bookings
        .where((b) => b['status']?.toString().toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  int _countByStatus(String status) =>
      _bookings.where((b) => b['status'] == status).length;

  Future<void> _cancelBooking(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final auth = context.read<AuthProvider>();
    final response = await auth.api.cancelBooking(id);

    if (response.isSuccess) {
      await _loadData();
      if (mounted) SnackBarHelper.showSuccess(context, 'Booking cancelled');
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBookings;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Total',
                        value: _bookings.length,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Pending',
                        value: _countByStatus('pending'),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Accepted',
                        value: _countByStatus('accepted'),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStatCard(
                        label: 'Completed',
                        value: _countByStatus('completed'),
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilterChipRow(
                  options: _filterOptions,
                  selected: _filter,
                  onSelected: (v) => setState(() => _filter = v),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: LoadingState())
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.calendar_month,
                  title: 'No bookings yet',
                  subtitle: 'Find vendors and book services for your wedding',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final booking = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BookingCard(
                          booking: booking,
                          onCancel: booking['status'] == 'pending'
                              ? () => _cancelBooking(booking['id'])
                              : null,
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
