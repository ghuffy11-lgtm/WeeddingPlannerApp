import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../models/category_model.dart';
import '../models/vendor_model.dart';
import '../models/review_model.dart';

/// Remote data source for vendor-related API calls
abstract class VendorRemoteDataSource {
  Future<List<CategoryModel>> getCategories({String? lang});
  Future<CategoryModel> getCategoryById(String id);
  Future<PaginatedResult<VendorSummaryModel>> getVendors({
    VendorFilter filter = const VendorFilter(),
    int page = 1,
    int limit = 20,
  });
  Future<VendorModel> getVendorById(String id);
  Future<PaginatedResult<ReviewModel>> getVendorReviews(
    String vendorId, {
    int page = 1,
    int limit = 10,
  });
}

class VendorRemoteDataSourceImpl implements VendorRemoteDataSource {
  final Dio dio;

  VendorRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories({String? lang}) async {
    try {
      final response = await dio.get(
        '/categories',
        queryParameters: lang != null ? {'lang': lang} : null,
      );

      final data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await dio.get('/categories/$id');
      return CategoryModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResult<VendorSummaryModel>> getVendors({
    VendorFilter filter = const VendorFilter(),
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': filter.sortBy,
        'sortOrder': filter.sortOrder,
      };

      if (filter.categoryId != null) {
        queryParams['categoryId'] = filter.categoryId;
      }
      if (filter.city != null) {
        queryParams['city'] = filter.city;
      }
      if (filter.country != null) {
        queryParams['country'] = filter.country;
      }
      if (filter.priceRange != null) {
        queryParams['priceRange'] = filter.priceRange;
      }
      if (filter.minRating != null) {
        queryParams['minRating'] = filter.minRating.toString();
      }
      if (filter.search != null && filter.search!.isNotEmpty) {
        queryParams['search'] = filter.search;
      }
      if (filter.featured == true) {
        queryParams['featured'] = 'true';
      }

      final response = await dio.get(
        '/vendors',
        queryParameters: queryParams,
      );

      final data = response.data;
      final items = (data['data'] as List<dynamic>)
          .map((json) => VendorSummaryModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedResult<VendorSummaryModel>(
        items: items,
        page: data['page'] as int,
        limit: data['limit'] as int,
        total: data['total'] as int,
        totalPages: data['totalPages'] as int,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<VendorModel> getVendorById(String id) async {
    try {
      final response = await dio.get('/vendors/$id');
      return VendorModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResult<ReviewModel>> getVendorReviews(
    String vendorId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/vendors/$vendorId/reviews',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final data = response.data;
      final items = (data['data'] as List<dynamic>)
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return PaginatedResult<ReviewModel>(
        items: items,
        page: data['page'] as int,
        limit: data['limit'] as int,
        total: data['total'] as int,
        totalPages: data['totalPages'] as int,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException(message: 'Connection timed out');
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data?['message'] as String? ?? 'Unknown error';

      switch (statusCode) {
        case 400:
          return ValidationException(message: message);
        case 401:
          return const UnauthorizedException();
        case 403:
          return const ForbiddenException();
        case 404:
          return NotFoundException(message: message);
        case 500:
        default:
          return ServerException(message: message);
      }
    }

    return const NetworkException(message: 'No internet connection');
  }
}
