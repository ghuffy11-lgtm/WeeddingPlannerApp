import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/guest.dart';
import '../../domain/repositories/guest_repository.dart';
import '../bloc/guest_bloc.dart';
import '../bloc/guest_event.dart';
import '../bloc/guest_state.dart';
import '../widgets/guest_card.dart';

class GuestsPage extends StatefulWidget {
  const GuestsPage({super.key});

  @override
  State<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends State<GuestsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<GuestBloc>().add(const LoadGuests());
    context.read<GuestBloc>().add(const LoadGuestStats());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GuestBloc>().add(const LoadMoreGuests());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<GuestBloc, GuestState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == GuestActionStatus.success &&
              state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccessMessage!),
                backgroundColor: Colors.green,
              ),
            );
            context.read<GuestBloc>().add(const ClearGuestError());
          } else if (state.actionStatus == GuestActionStatus.error &&
              state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<GuestBloc>().add(const ClearGuestError());
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              _buildAppBar(state),

              // Stats Card
              if (state.stats != null)
                SliverToBoxAdapter(
                  child: GuestStatsCard(stats: state.stats!),
                ),

              // Search and Filter Bar
              SliverToBoxAdapter(
                child: _buildSearchAndFilter(state),
              ),

              // Filter Chips
              if (state.filter.hasFilters)
                SliverToBoxAdapter(
                  child: _buildActiveFilters(state),
                ),

              // Guest List
              _buildGuestList(state),

              // Loading more indicator
              if (state.listStatus == GuestListStatus.loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar(GuestState state) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'Guest List',
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.backgroundDark,
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (state.isSelectionMode) ...[
          TextButton(
            onPressed: () {
              context.read<GuestBloc>().add(const ClearSelections());
            },
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: state.hasSelectedGuests
                ? () {
                    _showBulkActionsSheet(context, state);
                  }
                : null,
            child: Text(
              '${state.selectedCount} selected',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ] else ...[
          IconButton(
            onPressed: () {
              // TODO: Import guests
            },
            icon: const Icon(Icons.upload_file_outlined),
            color: AppColors.textSecondary,
          ),
          IconButton(
            onPressed: () {
              // TODO: Export guests
            },
            icon: const Icon(Icons.download_outlined),
            color: AppColors.textSecondary,
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilter(GuestState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 12,
              child: TextField(
                controller: _searchController,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search guests...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textTertiary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          color: AppColors.textTertiary,
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<GuestBloc>()
                                .add(const SearchGuests(''));
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  context.read<GuestBloc>().add(SearchGuests(value));
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Filter button
          GlassIconButton(
            icon: Icons.filter_list_rounded,
            onTap: () => _showFilterSheet(context, state),
            hasBadge: state.filter.hasFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(GuestState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (state.filter.rsvpStatus != null)
            _buildFilterChip(
              label: state.filter.rsvpStatus!.displayName,
              onRemove: () {
                context.read<GuestBloc>().add(UpdateFilter(
                      state.filter.copyWith(clearRsvpStatus: true),
                    ));
              },
            ),
          if (state.filter.category != null)
            _buildFilterChip(
              label: state.filter.category!.displayName,
              onRemove: () {
                context.read<GuestBloc>().add(UpdateFilter(
                      state.filter.copyWith(clearCategory: true),
                    ));
              },
            ),
          if (state.filter.side != null)
            _buildFilterChip(
              label: state.filter.side!.displayName,
              onRemove: () {
                context.read<GuestBloc>().add(UpdateFilter(
                      state.filter.copyWith(clearSide: true),
                    ));
              },
            ),
          GestureDetector(
            onTap: () {
              context.read<GuestBloc>().add(const ClearFilter());
            },
            child: Text(
              'Clear all',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestList(GuestState state) {
    if (state.listStatus == GuestListStatus.loading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.listStatus == GuestListStatus.error) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                state.listError ?? 'Failed to load guests',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              GlassButton(
                onTap: () {
                  context.read<GuestBloc>().add(const RefreshGuests());
                },
                child: Text(
                  'Retry',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.guests.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final guest = state.guests[index];
          return GuestCard(
            guest: guest,
            isSelected: state.selectedGuestIds.contains(guest.id),
            showSelectionCheckbox: state.isSelectionMode,
            onTap: () {
              if (state.isSelectionMode) {
                context.read<GuestBloc>().add(ToggleGuestSelection(guest.id));
              } else {
                context.push('/guests/${guest.id}');
              }
            },
            onLongPress: () {
              context.read<GuestBloc>().add(ToggleGuestSelection(guest.id));
            },
          );
        },
        childCount: state.guests.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.accentPurple.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No guests yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your guest list by\nadding your first guest',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassButton(
              onTap: () {
                context.push('/guests/add');
              },
              isPrimary: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Add Guest',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<GuestBloc, GuestState>(
      builder: (context, state) {
        if (state.isSelectionMode) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: () {
            context.push('/guests/add');
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, GuestState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        currentFilter: state.filter,
        onApply: (filter) {
          context.read<GuestBloc>().add(UpdateFilter(filter));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showBulkActionsSheet(BuildContext context, GuestState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${state.selectedCount} guests selected',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.send_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Send Invitations',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<GuestBloc>().add(SendBulkInvitations(
                        state.selectedGuestIds.toList(),
                      ));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.select_all_outlined,
                  color: AppColors.textSecondary,
                ),
                title: Text(
                  'Select All',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<GuestBloc>().add(const SelectAllGuests());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final GuestFilter currentFilter;
  final Function(GuestFilter) onApply;

  const _FilterSheet({
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RsvpStatus? _rsvpStatus;
  late GuestCategory? _category;
  late GuestSide? _side;

  @override
  void initState() {
    super.initState();
    _rsvpStatus = widget.currentFilter.rsvpStatus;
    _category = widget.currentFilter.category;
    _side = widget.currentFilter.side;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter Guests',
              style: AppTypography.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // RSVP Status
            Text(
              'RSVP Status',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RsvpStatus.values.map((status) {
                final isSelected = _rsvpStatus == status;
                return GlassChip(
                  label: status.displayName,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _rsvpStatus = isSelected ? null : status;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category
            Text(
              'Category',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GuestCategory.values.map((category) {
                final isSelected = _category == category;
                return GlassChip(
                  label: category.displayName,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _category = isSelected ? null : category;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Side
            Text(
              'Side',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GuestSide.values.map((side) {
                final isSelected = _side == side;
                return GlassChip(
                  label: side.displayName,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _side = isSelected ? null : side;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onTap: () {
                      setState(() {
                        _rsvpStatus = null;
                        _category = null;
                        _side = null;
                      });
                    },
                    child: Text(
                      'Clear',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassButton(
                    onTap: () {
                      widget.onApply(GuestFilter(
                        rsvpStatus: _rsvpStatus,
                        category: _category,
                        side: _side,
                      ));
                    },
                    isPrimary: true,
                    child: Text(
                      'Apply',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
