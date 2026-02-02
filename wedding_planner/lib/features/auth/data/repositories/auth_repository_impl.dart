import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    try {
      final result = await remoteDataSource.register(
        email: email,
        password: password,
        userType: userType.name,
      );

      // Save tokens and user locally
      await localDataSource.saveTokens(result.tokens);
      await localDataSource.saveUser(result.user);

      return Right(result.user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ConflictException catch (e) {
      return Left(EmailInUseFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save tokens and user locally
      await localDataSource.saveTokens(result.tokens);
      await localDataSource.saveUser(result.user);

      return Right(result.user.toEntity());
    } on AuthException catch (e) {
      return Left(InvalidCredentialsFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    // TODO: Implement Google sign-in
    return const Left(UnknownFailure(message: 'Google sign-in not implemented yet'));
  }

  @override
  Future<Either<Failure, User>> loginWithApple() async {
    // TODO: Implement Apple sign-in
    return const Left(UnknownFailure(message: 'Apple sign-in not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    // TODO: Implement OTP verification
    return const Left(UnknownFailure(message: 'OTP verification not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final tokens = await localDataSource.getTokens();
      if (tokens != null) {
        await remoteDataSource.logout(tokens.refreshToken);
      }
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      // Even if remote logout fails, clear local data
      await localDataSource.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First check local cache
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // If not cached, fetch from server
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return localDataSource.isLoggedIn();
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final tokens = await localDataSource.getTokens();
      if (tokens == null) {
        return const Left(AuthFailure(message: 'No refresh token available'));
      }

      final newTokens = await remoteDataSource.refreshToken(tokens.refreshToken);
      await localDataSource.saveTokens(newTokens);
      return const Right(null);
    } on AuthException catch (e) {
      // If refresh fails, clear local data (user needs to log in again)
      await localDataSource.clearAll();
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// Get current access token (for API requests)
  Future<String?> getAccessToken() async {
    final tokens = await localDataSource.getTokens();
    if (tokens == null) return null;

    // Check if token needs refresh
    if (tokens.needsRefresh) {
      final result = await refreshToken();
      if (result.isLeft()) return null;

      final newTokens = await localDataSource.getTokens();
      return newTokens?.accessToken;
    }

    return tokens.accessToken;
  }
}
