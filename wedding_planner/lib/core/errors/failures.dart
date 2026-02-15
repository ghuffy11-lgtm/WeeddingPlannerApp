import 'package:equatable/equatable.dart';

/// Base Failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server-side failure
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

/// Network/Connection failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Cache/Local storage failure
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
  });
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Invalid credentials failure
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password',
  });
}

/// User not found failure
class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({
    super.message = 'User not found',
  });
}

/// Email already in use failure
class EmailInUseFailure extends AuthFailure {
  const EmailInUseFailure({
    super.message = 'Email is already in use',
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation error',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// Permission denied failure
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied',
    super.code,
  });
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code = 404,
  });
}

/// Conflict failure (409) - resource already exists
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'Resource already exists',
    super.code = 409,
  });
}

/// Timeout failure
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out',
  });
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
  });
}
