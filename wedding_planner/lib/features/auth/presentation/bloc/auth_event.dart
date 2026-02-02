import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Base class for all Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is already logged in (on app start)
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Register new user
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final UserType userType;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, userType];
}

/// Logout current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Login with Google
class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

/// Login with Apple
class AuthAppleLoginRequested extends AuthEvent {
  const AuthAppleLoginRequested();
}

/// Send password reset email
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Clear any error state
class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
