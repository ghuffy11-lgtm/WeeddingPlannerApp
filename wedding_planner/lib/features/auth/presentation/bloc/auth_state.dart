import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// Auth status enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth State
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isPasswordResetSent;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isPasswordResetSent = false,
  });

  /// Initial state
  const AuthState.initial() : this();

  /// Loading state
  const AuthState.loading()
      : this(status: AuthStatus.loading);

  /// Authenticated state
  AuthState.authenticated(User user)
      : this(
          status: AuthStatus.authenticated,
          user: user,
        );

  /// Unauthenticated state
  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  /// Error state
  AuthState.error(String message)
      : this(
          status: AuthStatus.error,
          errorMessage: message,
        );

  /// Password reset sent state
  const AuthState.passwordResetSent()
      : this(
          status: AuthStatus.unauthenticated,
          isPasswordResetSent: true,
        );

  /// Copy with method
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isPasswordResetSent,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
    );
  }

  /// Check if loading
  bool get isLoading => status == AuthStatus.loading;

  /// Check if authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Check if has error
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, user, errorMessage, isPasswordResetSent];
}
