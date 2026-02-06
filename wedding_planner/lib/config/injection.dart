import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/home/data/datasources/home_remote_datasource.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/vendors/data/datasources/vendor_remote_datasource.dart';
import '../features/vendors/data/datasources/vendor_local_datasource.dart';
import '../features/vendors/data/repositories/vendor_repository_impl.dart';
import '../features/vendors/domain/repositories/vendor_repository.dart';
import '../features/vendors/presentation/bloc/vendor_bloc.dart';
import '../features/booking/data/datasources/booking_remote_datasource.dart';
import '../features/booking/data/repositories/booking_repository_impl.dart';
import '../features/booking/domain/repositories/booking_repository.dart';
import '../features/booking/presentation/bloc/booking_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Configure all dependencies
Future<void> configureDependencies() async {
  // External dependencies
  await _registerExternalDependencies();

  // Core services
  _registerCoreServices();

  // Data sources
  _registerDataSources();

  // Repositories
  _registerRepositories();

  // Use cases
  _registerUseCases();

  // BLoCs
  _registerBlocs();
}

Future<void> _registerExternalDependencies() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Secure Storage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Dio HTTP Client
  final dio = Dio(
    BaseOptions(
      // Use localhost for emulator, or your server IP for physical device
      // For remote development server, update this to your server address
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.1.13.98:3000/api/v1', // Server IP for physical device
      ),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors
  dio.interceptors.addAll([
    LogInterceptor(
      requestBody: true,
      responseBody: true,
    ),
    AuthInterceptor(getIt),
  ]);

  getIt.registerSingleton<Dio>(dio);
}

void _registerCoreServices() {
  // Core services are registered here
  // - NetworkInfo (connectivity checker)
  // - LocalStorage wrapper
  // etc.
}

void _registerDataSources() {
  // Auth Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Home Data Sources
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Vendor Data Sources
  getIt.registerLazySingleton<VendorRemoteDataSource>(
    () => VendorRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<VendorLocalDataSource>(
    () => VendorLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  // Booking Data Sources
  getIt.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
}

void _registerRepositories() {
  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Home Repository
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: getIt<HomeRemoteDataSource>(),
    ),
  );

  // Vendor Repository
  getIt.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(
      remoteDataSource: getIt<VendorRemoteDataSource>(),
      localDataSource: getIt<VendorLocalDataSource>(),
    ),
  );

  // Booking Repository
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: getIt<BookingRemoteDataSource>(),
    ),
  );
}

void _registerUseCases() {
  // Use cases can be registered here if needed
  // For simpler apps, you can call repository directly from BLoC
}

void _registerBlocs() {
  // Auth BLoC - Factory so each screen gets a fresh instance if needed
  // Using singleton here as auth state should be global
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  // Home BLoC - Factory so each navigation creates fresh state
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(homeRepository: getIt<HomeRepository>()),
  );

  // Vendor BLoC - Factory so each navigation creates fresh state
  getIt.registerFactory<VendorBloc>(
    () => VendorBloc(vendorRepository: getIt<VendorRepository>()),
  );

  // Booking BLoC - Factory so each navigation creates fresh state
  getIt.registerFactory<BookingBloc>(
    () => BookingBloc(repository: getIt<BookingRepository>()),
  );
}

/// Auth Interceptor for adding JWT token to requests
class AuthInterceptor extends Interceptor {
  final GetIt _getIt;

  AuthInterceptor(this._getIt);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints
    if (options.path.contains('/auth/')) {
      handler.next(options);
      return;
    }

    try {
      final localDataSource = _getIt<AuthLocalDataSource>();
      final tokens = await (localDataSource as AuthLocalDataSourceImpl)
          .getTokens();

      if (tokens != null && !tokens.isExpired) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    } catch (_) {
      // If we can't get token, proceed without it
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401) {
      try {
        final authRepo = _getIt<AuthRepository>();
        final result = await authRepo.refreshToken();

        if (result.isRight()) {
          // Retry the request with new token
          final localDataSource = _getIt<AuthLocalDataSource>();
          final tokens = await (localDataSource as AuthLocalDataSourceImpl)
              .getTokens();

          if (tokens != null) {
            err.requestOptions.headers['Authorization'] =
                'Bearer ${tokens.accessToken}';

            final dio = _getIt<Dio>();
            final response = await dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        }
      } catch (_) {
        // If refresh fails, continue with original error
      }
    }

    handler.next(err);
  }
}
