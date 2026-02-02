/// Base Exception class
abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server Exception
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    super.message = 'Server error occurred',
    super.code,
    this.statusCode,
  });
}

/// Network Exception
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Cache Exception
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.code,
  });
}

/// Auth Exception
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication error',
    super.code,
  });
}

/// Validation Exception
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    super.message = 'Validation error',
    this.errors,
  });
}

/// Conflict Exception (e.g., email already exists)
class ConflictException extends AppException {
  const ConflictException({
    super.message = 'Resource conflict',
    super.code = 409,
  });
}

/// Not Found Exception
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code = 404,
  });
}

/// Unauthorized Exception
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.code = 401,
  });
}

/// Forbidden Exception
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Access forbidden',
    super.code = 403,
  });
}
