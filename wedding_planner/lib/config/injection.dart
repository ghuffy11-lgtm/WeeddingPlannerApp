import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Dio HTTP Client
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.weddingplanner.app/v1', // TODO: Use environment
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
    _AuthInterceptor(),
  ]);

  getIt.registerSingleton<Dio>(dio);
}

void _registerCoreServices() {
  // TODO: Register core services
  // - NetworkInfo
  // - LocalStorage
  // - AuthService
  // - NotificationService
}

void _registerDataSources() {
  // TODO: Register data sources
  // - AuthRemoteDataSource
  // - AuthLocalDataSource
  // - VendorRemoteDataSource
  // - etc.
}

void _registerRepositories() {
  // TODO: Register repositories
  // - AuthRepository
  // - VendorRepository
  // - TaskRepository
  // - etc.
}

void _registerUseCases() {
  // TODO: Register use cases
  // - LoginUseCase
  // - GetVendorsUseCase
  // - CreateBookingUseCase
  // - etc.
}

void _registerBlocs() {
  // TODO: Register BLoCs
  // - AuthBloc
  // - VendorBloc
  // - TaskBloc
  // - etc.
}

/// Auth Interceptor for adding JWT token
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO: Get token from secure storage
    // final token = await getIt<AuthService>().getToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - refresh token or logout
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic
    }
    handler.next(err);
  }
}
