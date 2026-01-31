import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Auth Repository Interface
/// Defines the contract for authentication operations
abstract class AuthRepository {
  /// Register a new user with email and password
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required UserType userType,
  });

  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Login with Google
  Future<Either<Failure, User>> loginWithGoogle();

  /// Login with Apple
  Future<Either<Failure, User>> loginWithApple();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Verify OTP code
  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String code,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Refresh auth token
  Future<Either<Failure, void>> refreshToken();
}
