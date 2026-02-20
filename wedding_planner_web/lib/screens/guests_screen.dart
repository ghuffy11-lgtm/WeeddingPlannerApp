import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/stat_card.dart';
import '../widgets/guest_card.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key});

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  List<Map<String, dynamic>> _guests = [];
  bool _isLoading = true;
  String _filter = 'All';

  static const List<String> _filterOptions = [
    'All',
    'Confirmed',
    'Pending',
    'Declined',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    if (auth.weddingId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await auth.api.getGuests(auth.weddingId!);

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _guests = List<Map<String, dynamic>>.from(response.responseData ?? []);
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredGuests {
    if (_filter == 'All') return _guests;
    return _guests
        .where((g) =>
            g['rsvp_status']?.toString().toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  int _countByStatus(String status) =>
      _guests.where((g) => g['rsvp_status'] == status).length;

  Future<void> _updateRsvp(String guestId, String status) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.updateGuest(
      auth.weddingId!,
      guestId,
      {'rsvpStatus': status},
    );

    if (response.isSuccess) {
      await _loadData();
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  Future<void> _deleteGuest(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.deleteGuest(auth.weddingId!, id);

    if (response.isSuccess) {
      await _loadData();
      if (mounted) SnackBarHelper.showSuccess(context, 'Guest removed');
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed');
    }
  }

  void _showGuestDialog([Map<String, dynamic>? existing]) {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: existing?['name']);
    final emailController = TextEditingController(text: existing?['email']);
    final phoneController = TextEditingController(text: existing?['phone']);
    String rsvpStatus = existing?['rsvp_status'] ?? 'pending';
    bool plusOne = existing?['plus_one'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Guest' : 'Add Guest'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: rsvpStatus,
                  decoration: const InputDecoration(labelText: 'RSVP Status'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(value: 'declined', child: Text('Declined')),
                  ],
                  onChanged: (v) => setDialogState(() => rsvpStatus = v!),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: plusOne,
                  onChanged: (v) => setDialogState(() => plusOne = v ?? false),
                  title: const Text('+1 Guest'),
                  contentPadding: EdgeInsets.zero,
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
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'rsvpStatus': rsvpStatus,
                  'plusOne': plusOne,
                };

                final response = isEdit
                    ? await auth.api.updateGuest(auth.weddingId!, existing['id'], data)
                    : await auth.api.addGuest(auth.weddingId!, data);

                if (response.isSuccess) {
                  await _loadData();
                  if (mounted) {
                    SnackBarHelper.showSuccess(
                        context, isEdit ? 'Guest updated' : 'Guest added');
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredGuests;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            label: 'Total',
                            value: _guests.length,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniStatCard(
                            label: 'Confirmed',
                            value: _countByStatus('confirmed'),
                            color: Colors.green,
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
                            label: 'Declined',
                            value: _countByStatus('declined'),
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
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
                  icon: Icons.people_outline,
                  title: 'No guests yet',
                  subtitle: 'Add guests to your wedding list',
                  actionLabel: 'Add Guest',
                  onAction: () => _showGuestDialog(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final guest = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GuestCard(
                          guest: guest,
                          onTap: () => _showGuestDialog(guest),
                          onStatusChange: (status) =>
                              _updateRsvp(guest['id'], status),
                          onDelete: () => _deleteGuest(guest['id']),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGuestDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Guest'),
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
