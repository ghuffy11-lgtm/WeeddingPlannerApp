import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/guest.dart';
import '../bloc/guest_bloc.dart';
import '../bloc/guest_event.dart';
import '../bloc/guest_state.dart';

class GuestDetailPage extends StatefulWidget {
  final String guestId;

  const GuestDetailPage({super.key, required this.guestId});

  @override
  State<GuestDetailPage> createState() => _GuestDetailPageState();
}

class _GuestDetailPageState extends State<GuestDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<GuestBloc>().add(LoadGuestDetail(widget.guestId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<GuestBloc, GuestState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == GuestActionStatus.success) {
            if (state.actionSuccessMessage == 'Guest deleted') {
              context.pop();
            } else if (state.actionSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccessMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
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
          if (state.detailStatus == GuestDetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.detailStatus == GuestDetailStatus.error) {
            return Center(
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
                    state.detailError ?? 'Failed to load guest',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassButton(
                    onTap: () => context.pop(),
                    child: Text(
                      'Go Back',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final guest = state.selectedGuest;
          if (guest == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(guest, state),
              SliverToBoxAdapter(
                child: _buildContent(guest),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(Guest guest, GuestState state) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      expandedHeight: 200,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios_rounded),
        color: AppColors.textPrimary,
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.push('/guests/${widget.guestId}/edit');
          },
          icon: const Icon(Icons.edit_outlined),
          color: AppColors.textSecondary,
        ),
        IconButton(
          onPressed: () => _showDeleteConfirmation(context),
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getAvatarColor(guest.side).withValues(alpha: 0.3),
                AppColors.backgroundDark,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getAvatarColor(guest.side),
                        _getAvatarColor(guest.side).withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      guest.initials,
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  guest.fullName,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Category and side
                Text(
                  '${guest.category.icon} ${guest.category.displayName} • ${guest.side.displayName}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(GuestSide side) {
    switch (side) {
      case GuestSide.bride:
        return AppColors.primary;
      case GuestSide.groom:
        return AppColors.accentPurple;
      case GuestSide.both:
        return AppColors.accent;
    }
  }

  Widget _buildContent(Guest guest) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RSVP Status Card
          _buildRsvpCard(guest),
          const SizedBox(height: 16),

          // Contact Info
          _buildInfoSection(
            title: 'Contact Information',
            children: [
              if (guest.email != null)
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: guest.email!,
                ),
              if (guest.phone != null)
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: guest.phone!,
                ),
              if (guest.address != null)
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: guest.address!,
                ),
              if (guest.email == null &&
                  guest.phone == null &&
                  guest.address == null)
                Text(
                  'No contact information provided',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Guest Details
          _buildInfoSection(
            title: 'Guest Details',
            children: [
              _buildInfoRow(
                icon: Icons.group_add_outlined,
                label: 'Plus Ones',
                value: guest.plusOnes > 0
                    ? '+${guest.plusOnes} guest${guest.plusOnes > 1 ? 's' : ''}'
                    : 'None',
              ),
              _buildInfoRow(
                icon: Icons.restaurant_outlined,
                label: 'Meal Preference',
                value: guest.mealPreference.displayName,
              ),
              if (guest.dietaryNotes != null)
                _buildInfoRow(
                  icon: Icons.info_outline,
                  label: 'Dietary Notes',
                  value: guest.dietaryNotes!,
                ),
              if (guest.tableAssignment != null)
                _buildInfoRow(
                  icon: Icons.table_restaurant_outlined,
                  label: 'Table',
                  value: guest.tableAssignment!,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Invitation Status
          _buildInfoSection(
            title: 'Invitation',
            children: [
              _buildInfoRow(
                icon: guest.invitationSent
                    ? Icons.check_circle_outline
                    : Icons.schedule,
                label: 'Status',
                value: guest.invitationSent ? 'Sent' : 'Not sent',
                valueColor:
                    guest.invitationSent ? Colors.green : AppColors.textTertiary,
              ),
              if (guest.invitationSentAtFormatted != null)
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Sent On',
                  value: guest.invitationSentAtFormatted!,
                ),
              if (guest.rsvpRespondedAtFormatted != null)
                _buildInfoRow(
                  icon: Icons.reply_outlined,
                  label: 'Responded On',
                  value: guest.rsvpRespondedAtFormatted!,
                ),
            ],
          ),

          // Notes
          if (guest.notes != null) ...[
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Notes',
              children: [
                Text(
                  guest.notes!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Actions
          if (!guest.invitationSent)
            GlassButton(
              onTap: () {
                context.read<GuestBloc>().add(SendInvitation(guest.id));
              },
              isPrimary: true,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_outlined, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Send Invitation',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRsvpCard(Guest guest) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RSVP Status',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              _buildRsvpBadge(guest.rsvpStatus),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Update RSVP',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: RsvpStatus.values.map((status) {
              final isSelected = guest.rsvpStatus == status;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GlassButton(
                    onTap: isSelected
                        ? null
                        : () {
                            context.read<GuestBloc>().add(UpdateRsvpStatus(
                                  guestId: guest.id,
                                  status: status,
                                ));
                          },
                    height: 36,
                    backgroundColor: isSelected
                        ? _getRsvpColor(status).withValues(alpha: 0.3)
                        : null,
                    borderColor: isSelected ? _getRsvpColor(status) : null,
                    child: Text(
                      status.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpBadge(RsvpStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRsvpColor(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: AppTypography.labelMedium.copyWith(
              color: _getRsvpColor(status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRsvpColor(RsvpStatus status) {
    switch (status) {
      case RsvpStatus.confirmed:
        return Colors.green;
      case RsvpStatus.declined:
        return Colors.red;
      case RsvpStatus.maybe:
        return Colors.orange;
      case RsvpStatus.pending:
        return AppColors.textSecondary;
    }
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Guest?',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently remove this guest from your list.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GuestBloc>().add(DeleteGuest(widget.guestId));
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
