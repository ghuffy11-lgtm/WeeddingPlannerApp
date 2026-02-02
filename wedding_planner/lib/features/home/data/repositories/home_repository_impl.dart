import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/budget_item.dart';
import '../../domain/entities/wedding.dart';
import '../../domain/entities/wedding_task.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/wedding_model.dart';

/// Home Repository Implementation
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Wedding?>> getWedding() async {
    try {
      final wedding = await remoteDataSource.getWedding();
      return Right(wedding);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WeddingTask>>> getUpcomingTasks({
    int limit = 5,
  }) async {
    try {
      final tasks = await remoteDataSource.getUpcomingTasks(limit: limit);
      return Right(tasks);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BudgetCategorySummary>>> getBudgetSummary() async {
    try {
      final data = await remoteDataSource.getBudgetSummary();
      final summaries = data.map((json) {
        return BudgetCategorySummary(
          category: json['category'] as String? ?? 'Other',
          allocated: (json['allocated'] as num?)?.toDouble() ?? 0,
          spent: (json['spent'] as num?)?.toDouble() ?? 0,
          itemCount: json['item_count'] as int? ?? 0,
        );
      }).toList();
      return Right(summaries);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getRecentBookings({
    int limit = 3,
  }) async {
    try {
      final bookings = await remoteDataSource.getRecentBookings(limit: limit);
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskStats>> getTaskStats() async {
    try {
      final stats = await remoteDataSource.getTaskStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wedding>> updateWedding(Wedding wedding) async {
    try {
      final model = WeddingModel.fromEntity(wedding);
      final updated = await remoteDataSource.updateWedding(model.toJson());
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeddingTask>> completeTask(String taskId) async {
    try {
      final task = await remoteDataSource.completeTask(taskId);
      return Right(task);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
