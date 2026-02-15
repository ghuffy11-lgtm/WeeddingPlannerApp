import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Budget>> getBudget(String weddingId) async {
    try {
      final budget = await remoteDataSource.getBudget(weddingId);
      return Right(budget);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateTotalBudget(
      String weddingId, double amount) async {
    try {
      final budget = await remoteDataSource.updateTotalBudget(weddingId, amount);
      return Right(budget);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BudgetStats>> getBudgetStats(String weddingId) async {
    try {
      final stats = await remoteDataSource.getBudgetStats(weddingId);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedExpenses>> getExpenses(
      String weddingId, ExpenseFilter filter) async {
    try {
      final result = await remoteDataSource.getExpenses(weddingId, filter);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(
      String weddingId, BudgetCategory category) async {
    try {
      final expenses =
          await remoteDataSource.getExpensesByCategory(weddingId, category);
      return Right(expenses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> getExpense(
      String weddingId, String id) async {
    try {
      final expense = await remoteDataSource.getExpense(weddingId, id);
      return Right(expense);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> createExpense(
      String weddingId, ExpenseRequest request) async {
    try {
      final expense =
          await remoteDataSource.createExpense(weddingId, request);
      return Right(expense);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense(
      String weddingId, String id, ExpenseRequest request) async {
    try {
      final expense =
          await remoteDataSource.updateExpense(weddingId, id, request);
      return Right(expense);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(
      String weddingId, String id) async {
    try {
      await remoteDataSource.deleteExpense(weddingId, id);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> updatePaymentStatus(
    String weddingId,
    String id,
    PaymentStatus status,
    double paidAmount,
  ) async {
    try {
      final expense = await remoteDataSource.updatePaymentStatus(
          weddingId, id, status, paidAmount);
      return Right(expense);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryBudget>> updateCategoryAllocation(
    String weddingId,
    CategoryAllocationRequest request,
  ) async {
    try {
      final category =
          await remoteDataSource.updateCategoryAllocation(weddingId, request);
      return Right(category);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getUpcomingPayments(String weddingId,
      {int days = 30}) async {
    try {
      final expenses =
          await remoteDataSource.getUpcomingPayments(weddingId, days: days);
      return Right(expenses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getOverduePayments(
      String weddingId) async {
    try {
      final expenses = await remoteDataSource.getOverduePayments(weddingId);
      return Right(expenses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
