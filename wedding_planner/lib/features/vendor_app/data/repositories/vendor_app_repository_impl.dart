import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../vendors/domain/entities/vendor.dart';
import '../../../vendors/domain/entities/vendor_package.dart';
import '../../domain/entities/vendor_dashboard.dart';
import '../../domain/entities/vendor_booking.dart';
import '../../domain/repositories/vendor_app_repository.dart';
import '../datasources/vendor_app_remote_datasource.dart';

class VendorAppRepositoryImpl implements VendorAppRepository {
  final VendorAppRemoteDataSource remoteDataSource;

  VendorAppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VendorDashboard>> getDashboard() async {
    try {
      final dashboard = await remoteDataSource.getDashboard();
      return Right(dashboard);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorEarnings>> getEarnings() async {
    try {
      final earnings = await remoteDataSource.getEarnings();
      return Right(earnings);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedVendorBookings>> getBookingRequests({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.getBookingRequests(
        page: page,
        limit: limit,
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedVendorBookings>> getAllBookings({
    VendorBookingFilter filter = const VendorBookingFilter(),
  }) async {
    try {
      final result = await remoteDataSource.getAllBookings(filter);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorBooking>> getBooking(String id) async {
    try {
      final booking = await remoteDataSource.getBooking(id);
      return Right(booking);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorBooking>> acceptBooking(
    String id, {
    String? vendorNotes,
  }) async {
    try {
      final booking = await remoteDataSource.acceptBooking(
        id,
        vendorNotes: vendorNotes,
      );
      return Right(booking);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorBooking>> declineBooking(
    String id,
    String reason,
  ) async {
    try {
      final booking = await remoteDataSource.declineBooking(id, reason);
      return Right(booking);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorBooking>> completeBooking(String id) async {
    try {
      final booking = await remoteDataSource.completeBooking(id);
      return Right(booking);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VendorPackage>>> getMyPackages() async {
    try {
      final packages = await remoteDataSource.getMyPackages();
      return Right(packages);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorPackage>> createPackage(
    CreatePackageRequest request,
  ) async {
    try {
      final package = await remoteDataSource.createPackage(request);
      return Right(package);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorPackage>> updatePackage(
    String id,
    UpdatePackageRequest request,
  ) async {
    try {
      final package = await remoteDataSource.updatePackage(id, request);
      return Right(package);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePackage(String id) async {
    try {
      await remoteDataSource.deletePackage(id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vendor>> getMyProfile() async {
    try {
      final profile = await remoteDataSource.getMyProfile();
      return Right(profile);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vendor>> updateProfile(
    UpdateVendorProfileRequest request,
  ) async {
    try {
      final profile = await remoteDataSource.updateProfile(request);
      return Right(profile);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vendor>> registerVendor(
    RegisterVendorRequest request,
  ) async {
    try {
      final vendor = await remoteDataSource.registerVendor(request);
      return Right(vendor);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getBookedDates({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final dates = await remoteDataSource.getBookedDates(
        fromDate: fromDate,
        toDate: toDate,
      );
      return Right(dates);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
