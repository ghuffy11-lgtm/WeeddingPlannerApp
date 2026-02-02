import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_remote_datasource.dart';
import '../datasources/vendor_local_datasource.dart';

class VendorRepositoryImpl implements VendorRepository {
  final VendorRemoteDataSource remoteDataSource;
  final VendorLocalDataSource localDataSource;

  VendorRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories({String? lang}) async {
    try {
      final categories = await remoteDataSource.getCategories(lang: lang);
      return Right(categories);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final category = await remoteDataSource.getCategoryById(id);
      return Right(category);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<VendorSummary>>> getVendors({
    VendorFilter filter = const VendorFilter(),
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.getVendors(
        filter: filter,
        page: page,
        limit: limit,
      );
      return Right(PaginatedResult<VendorSummary>(
        items: result.items,
        page: result.page,
        limit: result.limit,
        total: result.total,
        totalPages: result.totalPages,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vendor>> getVendorById(String id) async {
    try {
      final vendor = await remoteDataSource.getVendorById(id);
      return Right(vendor);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Review>>> getVendorReviews(
    String vendorId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getVendorReviews(
        vendorId,
        page: page,
        limit: limit,
      );
      return Right(PaginatedResult<Review>(
        items: result.items,
        page: result.page,
        limit: result.limit,
        total: result.total,
        totalPages: result.totalPages,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteVendorIds() async {
    try {
      final favorites = await localDataSource.getFavoriteVendorIds();
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String vendorId) async {
    try {
      await localDataSource.addToFavorites(vendorId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String vendorId) async {
    try {
      await localDataSource.removeFromFavorites(vendorId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String vendorId) async {
    try {
      final isFav = await localDataSource.isFavorite(vendorId);
      return Right(isFav);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
