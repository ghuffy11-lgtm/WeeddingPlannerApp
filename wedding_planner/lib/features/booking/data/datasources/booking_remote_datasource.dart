import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<PaginatedBookings> getMyBookings(BookingFilter filter);
  Future<BookingModel> getBooking(String id);
  Future<BookingSummaryModel> createBooking(CreateBookingRequest request);
  Future<void> cancelBooking(String id);
  Future<void> addReview({
    required String bookingId,
    required int rating,
    required String reviewText,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedBookings> getMyBookings(BookingFilter filter) async {
    try {
      final queryParams = <String, dynamic>{
        'page': filter.page,
        'limit': filter.limit,
      };

      if (filter.status != null) {
        queryParams['status'] = filter.status!.name;
      }

      final response = await dio.get(
        '/bookings/my-bookings',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as List<dynamic>;
      final pagination = response.data['pagination'] as Map<String, dynamic>;

      final bookings = data
          .map((e) => BookingSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return PaginatedBookings(
        bookings: bookings,
        currentPage: pagination['page'] as int,
        totalPages: pagination['totalPages'] as int,
        totalItems: pagination['total'] as int,
        hasMore: pagination['page'] < pagination['totalPages'],
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BookingModel> getBooking(String id) async {
    try {
      final response = await dio.get('/bookings/$id');
      return BookingModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<BookingSummaryModel> createBooking(CreateBookingRequest request) async {
    try {
      final response = await dio.post(
        '/bookings',
        data: request.toJson(),
      );
      return BookingSummaryModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> cancelBooking(String id) async {
    try {
      await dio.put('/bookings/$id/cancel');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> addReview({
    required String bookingId,
    required int rating,
    required String reviewText,
  }) async {
    try {
      await dio.post(
        '/bookings/$bookingId/review',
        data: {
          'rating': rating,
          'reviewText': reviewText,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data?['message'] as String? ?? 'An error occurred';

      switch (statusCode) {
        case 400:
          return ValidationException(message: message);
        case 401:
          return UnauthorizedException(message: message);
        case 403:
          return ForbiddenException(message: message);
        case 404:
          return NotFoundException(message: message);
        case 409:
          return ConflictException(message: message);
        default:
          return ServerException(message: message, statusCode: statusCode);
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(message: 'Connection timeout');
    }

    return NetworkException(message: 'No internet connection');
  }
}
