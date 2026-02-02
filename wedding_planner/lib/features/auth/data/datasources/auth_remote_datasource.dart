import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/auth_tokens.dart';
import '../models/user_model.dart';

/// Auth Remote Data Source
/// Handles all authentication API calls
abstract class AuthRemoteDataSource {
  /// Register a new user
  Future<({UserModel user, AuthTokens tokens})> register({
    required String email,
    required String password,
    required String userType,
  });

  /// Login with email and password
  Future<({UserModel user, AuthTokens tokens})> login({
    required String email,
    required String password,
  });

  /// Refresh access token
  Future<AuthTokens> refreshToken(String refreshToken);

  /// Get current user profile
  Future<UserModel> getCurrentUser();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Logout (invalidate refresh token)
  Future<void> logout(String refreshToken);
}

/// Implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<({UserModel user, AuthTokens tokens})> register({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'user_type': userType,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>;
      final tokensData = data['tokens'] as Map<String, dynamic>? ?? data;

      return (
        user: UserModel.fromJson(userData),
        tokens: AuthTokens.fromJson(tokensData),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<({UserModel user, AuthTokens tokens})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>;
      final tokensData = data['tokens'] as Map<String, dynamic>? ?? data;

      return (
        user: UserModel.fromJson(userData),
        tokens: AuthTokens.fromJson(tokensData),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthTokens> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      return AuthTokens.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('/users/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        '/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      // Ignore logout errors - user is logged out locally anyway
      if (e.response?.statusCode != 401) {
        throw _handleDioError(e);
      }
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        return _handleResponseError(e.response);
      default:
        return ServerException(message: e.message ?? 'Unknown error');
    }
  }

  Exception _handleResponseError(Response? response) {
    if (response == null) {
      return ServerException(message: 'No response from server');
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data as Map<String, dynamic>?;
    final message = data?['message'] as String? ?? 'Server error';

    switch (statusCode) {
      case 400:
        return ValidationException(message: message);
      case 401:
        return AuthException(message: 'Invalid credentials');
      case 403:
        return AuthException(message: 'Access denied');
      case 404:
        return NotFoundException(message: message);
      case 409:
        return ConflictException(message: message);
      case 422:
        final errors = data?['errors'] as Map<String, dynamic>?;
        return ValidationException(message: message, errors: errors);
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }
}
