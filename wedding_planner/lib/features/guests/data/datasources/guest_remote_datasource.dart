import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/guest.dart';
import '../../domain/repositories/guest_repository.dart';
import '../models/guest_model.dart';

abstract class GuestRemoteDataSource {
  Future<PaginatedGuests> getGuests(String weddingId, GuestFilter filter);
  Future<GuestModel> getGuest(String weddingId, String id);
  Future<GuestModel> createGuest(String weddingId, GuestRequest request);
  Future<GuestModel> updateGuest(String weddingId, String id, GuestRequest request);
  Future<void> deleteGuest(String weddingId, String id);
  Future<GuestModel> updateRsvpStatus(String weddingId, String id, RsvpStatus status);
  Future<void> sendInvitation(String weddingId, String id);
  Future<void> sendBulkInvitations(String weddingId, List<String> guestIds);
  Future<GuestStatsModel> getGuestStats(String weddingId);
  Future<List<GuestModel>> importGuests(String weddingId, String csvData);
  Future<String> exportGuests(String weddingId);
}

class GuestRemoteDataSourceImpl implements GuestRemoteDataSource {
  final Dio dio;

  GuestRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedGuests> getGuests(String weddingId, GuestFilter filter) async {
    try {
      final queryParams = <String, dynamic>{
        'page': filter.page,
        'limit': filter.limit,
      };

      if (filter.rsvpStatus != null) {
        queryParams['rsvpStatus'] = filter.rsvpStatus!.name;
      }
      if (filter.category != null) {
        queryParams['category'] = filter.category!.name;
      }
      if (filter.side != null) {
        queryParams['side'] = filter.side!.name;
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        queryParams['search'] = filter.searchQuery;
      }

      final response = await dio.get(
        '/weddings/$weddingId/guests',
        queryParameters: queryParams,
      );

      final data = response.data['data'];
      final guests = (data['guests'] as List)
          .map((json) => GuestSummaryModel.fromJson(json))
          .toList();

      return PaginatedGuests(
        guests: guests,
        currentPage: (data['currentPage'] ?? data['current_page'] ?? 1) as int,
        totalPages: (data['totalPages'] ?? data['total_pages'] ?? 1) as int,
        totalItems: (data['totalItems'] ?? data['total_items'] ?? guests.length) as int,
        hasMore: (data['hasMore'] ?? data['has_more'] ?? false) as bool,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load guests') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<GuestModel> getGuest(String weddingId, String id) async {
    try {
      final response = await dio.get('/weddings/$weddingId/guests/$id');
      return GuestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Guest not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load guest') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<GuestModel> createGuest(String weddingId, GuestRequest request) async {
    try {
      final response = await dio.post(
        '/weddings/$weddingId/guests',
        data: request.toJson(),
      );
      return GuestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid guest data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to create guest') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<GuestModel> updateGuest(String weddingId, String id, GuestRequest request) async {
    try {
      final response = await dio.put(
        '/weddings/$weddingId/guests/$id',
        data: request.toJson(),
      );
      return GuestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Guest not found');
      }
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid guest data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update guest') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteGuest(String weddingId, String id) async {
    try {
      await dio.delete('/weddings/$weddingId/guests/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Guest not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to delete guest') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<GuestModel> updateRsvpStatus(String weddingId, String id, RsvpStatus status) async {
    try {
      final response = await dio.patch(
        '/weddings/$weddingId/guests/$id/rsvp',
        data: {'rsvpStatus': status.name},
      );
      return GuestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Guest not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to update RSVP status') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> sendInvitation(String weddingId, String id) async {
    try {
      await dio.post('/weddings/$weddingId/guests/$id/invite');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Guest not found');
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to send invitation') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> sendBulkInvitations(String weddingId, List<String> guestIds) async {
    try {
      await dio.post(
        '/weddings/$weddingId/guests/invite-bulk',
        data: {'guestIds': guestIds},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to send invitations') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<GuestStatsModel> getGuestStats(String weddingId) async {
    try {
      final response = await dio.get('/weddings/$weddingId/guests/stats');
      return GuestStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      // If 404, return empty stats instead of throwing
      if (e.response?.statusCode == 404) {
        return GuestStatsModel.empty();
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to load guest stats') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<GuestModel>> importGuests(String weddingId, String csvData) async {
    try {
      final response = await dio.post(
        '/weddings/$weddingId/guests/import',
        data: {'csvData': csvData},
      );
      final data = response.data['data'] as List;
      return data.map((json) => GuestModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: (e.response?.data?['message'] ?? 'Invalid CSV data') as String,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      }
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to import guests') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> exportGuests(String weddingId) async {
    try {
      final response = await dio.get('/weddings/$weddingId/guests/export');
      return response.data['data'] as String;
    } on DioException catch (e) {
      throw ServerException(
        message: (e.response?.data?['message'] ?? 'Failed to export guests') as String,
        statusCode: e.response?.statusCode,
      );
    }
  }
}
