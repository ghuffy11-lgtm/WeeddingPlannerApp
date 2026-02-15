import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/guest.dart';
import '../../domain/repositories/guest_repository.dart';
import '../datasources/guest_remote_datasource.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteDataSource remoteDataSource;

  GuestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedGuests>> getGuests(
      String weddingId, GuestFilter filter) async {
    try {
      final result = await remoteDataSource.getGuests(weddingId, filter);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Guest>> getGuest(String weddingId, String id) async {
    try {
      final result = await remoteDataSource.getGuest(weddingId, id);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Guest>> createGuest(
      String weddingId, GuestRequest request) async {
    try {
      final result = await remoteDataSource.createGuest(weddingId, request);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Guest>> updateGuest(
      String weddingId, String id, GuestRequest request) async {
    try {
      final result =
          await remoteDataSource.updateGuest(weddingId, id, request);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGuest(
      String weddingId, String id) async {
    try {
      await remoteDataSource.deleteGuest(weddingId, id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Guest>> updateRsvpStatus(
      String weddingId, String id, RsvpStatus status) async {
    try {
      final result =
          await remoteDataSource.updateRsvpStatus(weddingId, id, status);
      return Right(result);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendInvitation(
      String weddingId, String id) async {
    try {
      await remoteDataSource.sendInvitation(weddingId, id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendBulkInvitations(
      String weddingId, List<String> guestIds) async {
    try {
      await remoteDataSource.sendBulkInvitations(weddingId, guestIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, GuestStats>> getGuestStats(String weddingId) async {
    try {
      final result = await remoteDataSource.getGuestStats(weddingId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Guest>>> importGuests(
      String weddingId, String csvData) async {
    try {
      final result = await remoteDataSource.importGuests(weddingId, csvData);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, String>> exportGuests(String weddingId) async {
    try {
      final result = await remoteDataSource.exportGuests(weddingId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'An unexpected error occurred'));
    }
  }
}
