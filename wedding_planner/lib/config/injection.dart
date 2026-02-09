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
import '../features/chat/data/datasources/chat_firestore_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';
import '../features/guests/data/datasources/guest_remote_datasource.dart';
import '../features/guests/data/repositories/guest_repository_impl.dart';
import '../features/guests/domain/repositories/guest_repository.dart';
import '../features/guests/presentation/bloc/guest_bloc.dart';
import '../features/budget/data/datasources/budget_remote_datasource.dart';
import '../features/budget/data/repositories/budget_repository_impl.dart';
import '../features/budget/domain/repositories/budget_repository.dart';
import '../features/budget/presentation/bloc/budget_bloc.dart';
import '../features/tasks/data/datasources/task_remote_datasource.dart';
import '../features/tasks/data/repositories/task_repository_impl.dart';
import '../features/tasks/domain/repositories/task_repository.dart';
import '../features/tasks/presentation/bloc/task_bloc.dart';
import '../features/vendor_app/data/datasources/vendor_app_remote_datasource.dart';
import '../features/vendor_app/data/repositories/vendor_app_repository_impl.dart';
import '../features/vendor_app/domain/repositories/vendor_app_repository.dart';
import '../features/vendor_app/presentation/bloc/vendor_dashboard_bloc.dart';
import '../features/vendor_app/presentation/bloc/vendor_bookings_bloc.dart';
import '../features/vendor_app/presentation/bloc/vendor_packages_bloc.dart';

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

  // Chat Data Sources
  getIt.registerLazySingleton<ChatFirestoreDataSource>(
    () => ChatFirestoreDataSourceImpl(),
  );

  // Guest Data Sources
  getIt.registerLazySingleton<GuestRemoteDataSource>(
    () => GuestRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Budget Data Sources
  getIt.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Task Data Sources
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Vendor App Data Sources
  getIt.registerLazySingleton<VendorAppRemoteDataSource>(
    () => VendorAppRemoteDataSourceImpl(dio: getIt<Dio>()),
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

  // Chat Repository
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      dataSource: getIt<ChatFirestoreDataSource>(),
    ),
  );

  // Guest Repository
  getIt.registerLazySingleton<GuestRepository>(
    () => GuestRepositoryImpl(
      remoteDataSource: getIt<GuestRemoteDataSource>(),
    ),
  );

  // Budget Repository
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(
      remoteDataSource: getIt<BudgetRemoteDataSource>(),
    ),
  );

  // Task Repository
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: getIt<TaskRemoteDataSource>(),
    ),
  );

  // Vendor App Repository
  getIt.registerLazySingleton<VendorAppRepository>(
    () => VendorAppRepositoryImpl(
      remoteDataSource: getIt<VendorAppRemoteDataSource>(),
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

  // Chat BLoC - Singleton for real-time updates across screens
  getIt.registerLazySingleton<ChatBloc>(
    () => ChatBloc(
      repository: getIt<ChatRepository>(),
      dataSource: getIt<ChatFirestoreDataSource>(),
    ),
  );

  // Guest BLoC - Factory so each navigation creates fresh state
  getIt.registerFactory<GuestBloc>(
    () => GuestBloc(repository: getIt<GuestRepository>()),
  );

  // Budget BLoC - Factory so each navigation creates fresh state
  getIt.registerFactory<BudgetBloc>(
    () => BudgetBloc(repository: getIt<BudgetRepository>()),
  );

  // Task BLoC - Factory so each navigation creates fresh state
  getIt.registerFactory<TaskBloc>(
    () => TaskBloc(repository: getIt<TaskRepository>()),
  );

  // Vendor App BLoCs - Factory so each navigation creates fresh state
  getIt.registerFactory<VendorDashboardBloc>(
    () => VendorDashboardBloc(repository: getIt<VendorAppRepository>()),
  );

  getIt.registerFactory<VendorBookingsBloc>(
    () => VendorBookingsBloc(repository: getIt<VendorAppRepository>()),
  );

  getIt.registerFactory<VendorPackagesBloc>(
    () => VendorPackagesBloc(repository: getIt<VendorAppRepository>()),
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
