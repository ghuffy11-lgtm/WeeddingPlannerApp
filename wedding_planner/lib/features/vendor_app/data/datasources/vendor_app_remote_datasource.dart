import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../vendors/data/models/vendor_model.dart';
import '../../../vendors/data/models/vendor_package_model.dart';
import '../../domain/entities/vendor_booking.dart';
import '../../domain/repositories/vendor_app_repository.dart';
import '../models/vendor_dashboard_model.dart';
import '../models/vendor_booking_model.dart';

abstract class VendorAppRemoteDataSource {
  Future<VendorDashboardModel> getDashboard();
  Future<VendorEarningsModel> getEarnings();
  Future<PaginatedVendorBookings> getBookingRequests({int page, int limit});
  Future<PaginatedVendorBookings> getAllBookings(VendorBookingFilter filter);
  Future<VendorBookingModel> getBooking(String id);
  Future<VendorBookingModel> acceptBooking(String id, {String? vendorNotes});
  Future<VendorBookingModel> declineBooking(String id, String reason);
  Future<VendorBookingModel> completeBooking(String id);
  Future<List<VendorPackageModel>> getMyPackages();
  Future<VendorPackageModel> createPackage(CreatePackageRequest request);
  Future<VendorPackageModel> updatePackage(String id, UpdatePackageRequest request);
  Future<void> deletePackage(String id);
  Future<VendorModel> getMyProfile();
  Future<VendorModel> updateProfile(UpdateVendorProfileRequest request);
  Future<VendorModel> registerVendor(RegisterVendorRequest request);
  Future<List<DateTime>> getBookedDates({DateTime? fromDate, DateTime? toDate});
}

class VendorAppRemoteDataSourceImpl implements VendorAppRemoteDataSource {
  final Dio dio;

  VendorAppRemoteDataSourceImpl({required this.dio});

  @override
  Future<VendorDashboardModel> getDashboard() async {
    try {
      final response = await dio.get('/vendors/me/dashboard');
      return VendorDashboardModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load dashboard');
    }
  }

  @override
  Future<VendorEarningsModel> getEarnings() async {
    try {
      final response = await dio.get('/vendors/me/earnings');
      return VendorEarningsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load earnings');
    }
  }

  @override
  Future<PaginatedVendorBookings> getBookingRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '/bookings/vendor/requests',
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data['data'];
      final bookings = (data['bookings'] as List? ?? [])
          .map((json) => VendorBookingSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedVendorBookings(
        bookings: bookings,
        currentPage: (data['currentPage'] ?? data['current_page'] ?? 1) as int,
        totalPages: (data['totalPages'] ?? data['total_pages'] ?? 1) as int,
        totalItems: (data['totalItems'] ?? data['total_items'] ?? bookings.length) as int,
        hasMore: (data['hasMore'] ?? data['has_more'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load booking requests');
    }
  }

  @override
  Future<PaginatedVendorBookings> getAllBookings(VendorBookingFilter filter) async {
    try {
      final queryParams = <String, dynamic>{
        'page': filter.page,
        'limit': filter.limit,
      };

      if (filter.status != null) {
        queryParams['status'] = filter.status!.name;
      }
      if (filter.fromDate != null) {
        queryParams['fromDate'] = filter.fromDate!.toIso8601String();
      }
      if (filter.toDate != null) {
        queryParams['toDate'] = filter.toDate!.toIso8601String();
      }

      final response = await dio.get(
        '/bookings/vendor/all',
        queryParameters: queryParams,
      );

      final data = response.data['data'];
      final bookings = (data['bookings'] as List? ?? [])
          .map((json) => VendorBookingSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedVendorBookings(
        bookings: bookings,
        currentPage: (data['currentPage'] ?? data['current_page'] ?? 1) as int,
        totalPages: (data['totalPages'] ?? data['total_pages'] ?? 1) as int,
        totalItems: (data['totalItems'] ?? data['total_items'] ?? bookings.length) as int,
        hasMore: (data['hasMore'] ?? data['has_more'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load bookings');
    }
  }

  @override
  Future<VendorBookingModel> getBooking(String id) async {
    try {
      final response = await dio.get('/bookings/$id');
      return VendorBookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(message: 'Booking not found');
      }
      throw _handleDioError(e, 'Failed to load booking');
    }
  }

  @override
  Future<VendorBookingModel> acceptBooking(String id, {String? vendorNotes}) async {
    try {
      final response = await dio.put(
        '/bookings/$id/accept',
        data: vendorNotes != null ? {'vendorNotes': vendorNotes} : null,
      );
      return VendorBookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(message: 'Booking not found');
      }
      throw _handleDioError(e, 'Failed to accept booking');
    }
  }

  @override
  Future<VendorBookingModel> declineBooking(String id, String reason) async {
    try {
      final response = await dio.put(
        '/bookings/$id/decline',
        data: {'reason': reason},
      );
      return VendorBookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(message: 'Booking not found');
      }
      throw _handleDioError(e, 'Failed to decline booking');
    }
  }

  @override
  Future<VendorBookingModel> completeBooking(String id) async {
    try {
      final response = await dio.put('/bookings/$id/complete');
      return VendorBookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(message: 'Booking not found');
      }
      throw _handleDioError(e, 'Failed to complete booking');
    }
  }

  @override
  Future<List<VendorPackageModel>> getMyPackages() async {
    try {
      final response = await dio.get('/vendors/me/packages');
      final data = response.data['data'] as List;
      return data
          .map((json) => VendorPackageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load packages');
    }
  }

  @override
  Future<VendorPackageModel> createPackage(CreatePackageRequest request) async {
    try {
      final response = await dio.post(
        '/vendors/me/packages',
        data: request.toJson(),
      );
      return VendorPackageModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid package data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw _handleDioError(e, 'Failed to create package');
    }
  }

  @override
  Future<VendorPackageModel> updatePackage(String id, UpdatePackageRequest request) async {
    try {
      final response = await dio.put(
        '/vendors/me/packages/$id',
        data: request.toJson(),
      );
      return VendorPackageModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(message: 'Package not found');
      }
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid package data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw _handleDioError(e, 'Failed to update package');
    }
  }

  @override
  Future<void> deletePackage(String id) async {
    try {
      await dio.delete('/vendors/me/packages/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException(message: 'Package not found');
      }
      throw _handleDioError(e, 'Failed to delete package');
    }
  }

  @override
  Future<VendorModel> getMyProfile() async {
    try {
      final response = await dio.get('/vendors/me');
      return VendorModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load profile');
    }
  }

  @override
  Future<VendorModel> updateProfile(UpdateVendorProfileRequest request) async {
    try {
      final response = await dio.put(
        '/vendors/me',
        data: request.toJson(),
      );
      return VendorModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid profile data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw _handleDioError(e, 'Failed to update profile');
    }
  }

  @override
  Future<VendorModel> registerVendor(RegisterVendorRequest request) async {
    try {
      final response = await dio.post(
        '/vendors/register',
        data: request.toJson(),
      );
      return VendorModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid vendor data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      if (e.response?.statusCode == 409) {
        throw ServerException(
          message: 'Vendor profile already exists',
          statusCode: 409,
        );
      }
      throw _handleDioError(e, 'Failed to register vendor');
    }
  }

  @override
  Future<List<DateTime>> getBookedDates({DateTime? fromDate, DateTime? toDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final response = await dio.get(
        '/vendors/me/availability',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data['data'] as List? ?? [];
      return data.map((dateStr) => DateTime.parse(dateStr as String)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to load booked dates');
    }
  }

  Exception _handleDioError(DioException e, String defaultMessage) {
    final message = (e.response?.data?['message'] ?? defaultMessage) as String;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException(message: 'Connection timed out');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException(message: 'No internet connection');
    }

    if (e.response?.statusCode == 401) {
      return const UnauthorizedException();
    }

    if (e.response?.statusCode == 403) {
      return const ForbiddenException();
    }

    return ServerException(
      message: message,
      statusCode: e.response?.statusCode,
    );
  }
}
