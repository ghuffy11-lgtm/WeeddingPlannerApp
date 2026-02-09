import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../config/routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../home/presentation/bloc/home_state.dart';

/// Profile Page for couple users
/// Displays user info, wedding summary, and account options with logout
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load wedding data when profile page opens
    context.read<HomeBloc>().add(const HomeLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 24),
                  _buildWeddingInfoSection(context),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(context),
                  const SizedBox(height: 24),
                  _buildAccountSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      expandedHeight: 60,
      title: Text(
        'Profile',
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon')),
            );
          },
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? 'Wedding Planner',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Couple Account',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeddingInfoSection(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        final wedding = homeState.wedding;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wedding Details',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Wedding Date',
                    wedding?.weddingDate != null
                        ? _formatDate(wedding!.weddingDate!)
                        : 'Not set',
                    Icons.calendar_today,
                  ),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildInfoRow(
                    'Days Remaining',
                    wedding?.daysUntilWedding != null
                        ? '${wedding!.daysUntilWedding} days'
                        : '-',
                    Icons.hourglass_empty,
                  ),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildInfoRow(
                    'Total Budget',
                    wedding?.totalBudget != null
                        ? '\$${wedding!.totalBudget.toStringAsFixed(0)}'
                        : 'Not set',
                    Icons.account_balance_wallet,
                  ),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildInfoRow(
                    'Expected Guests',
                    wedding?.guestCountExpected?.toString() ?? 'Not set',
                    Icons.people,
                  ),
                  if (wedding?.styleDisplay != null) ...[
                    const Divider(color: AppColors.divider, height: 24),
                    _buildInfoRow(
                      'Wedding Style',
                      wedding!.styleDisplay!,
                      Icons.style,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
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
              Text(
                value,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          context,
          icon: Icons.people_outline,
          title: 'Guest List',
          subtitle: 'Manage your guests',
          onTap: () => context.push(AppRoutes.guests),
        ),
        _buildMenuItem(
          context,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Budget',
          subtitle: 'Track your expenses',
          onTap: () => context.push(AppRoutes.budget),
        ),
        _buildMenuItem(
          context,
          icon: Icons.book_outlined,
          title: 'Bookings',
          subtitle: 'Your vendor bookings',
          onTap: () => context.push(AppRoutes.bookings),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'App preferences',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon')),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get assistance',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon')),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Log Out',
          subtitle: 'Sign out of your account',
          iconColor: AppColors.error,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
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
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(AppRoutes.welcome);
            },
            child: Text(
              'Log Out',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
