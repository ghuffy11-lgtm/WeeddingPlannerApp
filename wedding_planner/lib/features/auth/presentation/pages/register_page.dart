import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Register Page
/// Allows new users to create an account
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserType _selectedUserType = UserType.couple;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          userType: _selectedUserType,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          // Navigate based on user type
          if (_selectedUserType == UserType.couple) {
            context.go(AppRoutes.onboarding);
          } else {
            // Vendor registration flow (to be implemented)
            context.go(AppRoutes.home);
          }
        } else if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed'),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<AuthBloc>().add(const AuthErrorCleared());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.blushRose,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.deepCharcoal),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Create Account',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      'Start planning your perfect wedding today',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.warmGray,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Account Type Selection
                    Text(
                      'I am a...',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.deepCharcoal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Row(
                      children: [
                        Expanded(
                          child: _AccountTypeCard(
                            title: 'Couple',
                            subtitle: 'Planning a wedding',
                            icon: Icons.favorite,
                            isSelected: _selectedUserType == UserType.couple,
                            onTap: () {
                              setState(() {
                                _selectedUserType = UserType.couple;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: _AccountTypeCard(
                            title: 'Vendor',
                            subtitle: 'Offering services',
                            icon: Icons.store,
                            isSelected: _selectedUserType == UserType.vendor,
                            onTap: () {
                              setState(() {
                                _selectedUserType = UserType.vendor;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Email Field
                    AppTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.warmGray),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // Password Field
                    AppTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.warmGray),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.warmGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.micro),
                    Text(
                      'Min 8 characters, 1 uppercase, 1 number',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmGray,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // Confirm Password Field
                    AppTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.warmGray),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.warmGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      onSubmitted: (_) => _onRegister(),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // Terms Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            activeColor: AppColors.roseGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.warmGray,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: AppColors.roseGold,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.roseGold,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Register Button
                    PrimaryButton(
                      text: 'Create Account',
                      onPressed: _onRegister,
                      isLoading: state.isLoading,
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                          child: Text(
                            'or sign up with',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.warmGray,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Social Signup Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.apple,
                            label: 'Apple',
                            onPressed: () {
                              context.read<AuthBloc>().add(const AuthAppleLoginRequested());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.warmGray,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.login),
                            child: Text(
                              'Sign In',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.roseGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Account Type Selection Card
class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roseGold.withOpacity(0.1) : AppColors.white,
          borderRadius: AppSpacing.borderRadiusMedium,
          border: Border.all(
            color: isSelected ? AppColors.roseGold : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.roseGold : AppColors.warmGray,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? AppColors.roseGold : AppColors.deepCharcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.micro),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.warmGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Social Signup Button
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSmall,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.deepCharcoal, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.buttonMedium.copyWith(
              color: AppColors.deepCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
