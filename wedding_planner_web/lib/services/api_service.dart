import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.1.13.98:3010/api/v1';
  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated => _accessToken != null;
  String? get token => _accessToken;

  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  Future<ApiResponse> _request(String method, String endpoint, {Map<String, dynamic>? body, bool auth = true}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = auth ? _headers : {'Content-Type': 'application/json'};

      http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported method');
      }

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      return ApiResponse(statusCode: response.statusCode, data: data);
    } catch (e) {
      return ApiResponse(statusCode: 0, data: {'error': e.toString()});
    }
  }

  // Auth
  Future<ApiResponse> register(String email, String password, String userType) async {
    return _request('POST', '/auth/register', body: {
      'email': email,
      'password': password,
      'userType': userType,
    }, auth: false);
  }

  Future<ApiResponse> login(String email, String password) async {
    return _request('POST', '/auth/login', body: {
      'email': email,
      'password': password,
    }, auth: false);
  }

  Future<ApiResponse> getProfile() async {
    return _request('GET', '/auth/me');
  }

  // Wedding
  Future<ApiResponse> getMyWedding() async {
    return _request('GET', '/weddings/me');
  }

  Future<ApiResponse> createWedding(Map<String, dynamic> data) async {
    return _request('POST', '/weddings', body: data);
  }

  Future<ApiResponse> updateWedding(String id, Map<String, dynamic> data) async {
    return _request('PUT', '/weddings/$id', body: data);
  }

  // Tasks
  Future<ApiResponse> getTasks() async {
    return _request('GET', '/weddings/me/tasks');
  }

  Future<ApiResponse> createTask(Map<String, dynamic> data) async {
    return _request('POST', '/weddings/me/tasks', body: data);
  }

  Future<ApiResponse> updateTask(String id, Map<String, dynamic> data) async {
    return _request('PUT', '/weddings/me/tasks/$id', body: data);
  }

  Future<ApiResponse> deleteTask(String id) async {
    return _request('DELETE', '/weddings/me/tasks/$id');
  }

  Future<ApiResponse> getTaskStats() async {
    return _request('GET', '/weddings/me/tasks/stats');
  }

  // Guests
  Future<ApiResponse> getGuests(String weddingId) async {
    return _request('GET', '/weddings/$weddingId/guests');
  }

  Future<ApiResponse> addGuest(String weddingId, Map<String, dynamic> data) async {
    return _request('POST', '/weddings/$weddingId/guests', body: data);
  }

  Future<ApiResponse> updateGuest(String weddingId, String guestId, Map<String, dynamic> data) async {
    return _request('PUT', '/weddings/$weddingId/guests/$guestId', body: data);
  }

  Future<ApiResponse> deleteGuest(String weddingId, String guestId) async {
    return _request('DELETE', '/weddings/$weddingId/guests/$guestId');
  }

  // Budget
  Future<ApiResponse> getBudget(String weddingId) async {
    return _request('GET', '/weddings/$weddingId/budget');
  }

  Future<ApiResponse> addExpense(String weddingId, Map<String, dynamic> data) async {
    return _request('POST', '/weddings/$weddingId/budget', body: data);
  }

  Future<ApiResponse> updateExpense(String weddingId, String itemId, Map<String, dynamic> data) async {
    return _request('PUT', '/weddings/$weddingId/budget/$itemId', body: data);
  }

  Future<ApiResponse> deleteExpense(String weddingId, String itemId) async {
    return _request('DELETE', '/weddings/$weddingId/budget/$itemId');
  }

  Future<ApiResponse> getBudgetSummary() async {
    return _request('GET', '/weddings/me/budget/summary');
  }

  // Vendors
  Future<ApiResponse> getCategories() async {
    return _request('GET', '/categories', auth: false);
  }

  Future<ApiResponse> getVendors({String? search, String? categoryId}) async {
    String query = '/vendors?';
    if (search != null) query += 'search=$search&';
    if (categoryId != null) query += 'categoryId=$categoryId&';
    return _request('GET', query, auth: false);
  }

  Future<ApiResponse> getVendor(String id) async {
    return _request('GET', '/vendors/$id', auth: false);
  }

  Future<ApiResponse> getVendorPackages(String id) async {
    return _request('GET', '/vendors/$id/packages', auth: false);
  }

  // Vendor Profile (for logged in vendors)
  Future<ApiResponse> getMyVendor() async {
    return _request('GET', '/vendors/me');
  }

  Future<ApiResponse> createVendor(Map<String, dynamic> data) async {
    return _request('POST', '/vendors', body: data);
  }

  Future<ApiResponse> updateMyVendor(Map<String, dynamic> data) async {
    return _request('PUT', '/vendors/me', body: data);
  }

  Future<ApiResponse> getVendorRequests() async {
    return _request('GET', '/bookings/vendor/requests');
  }

  Future<ApiResponse> getVendorBookings() async {
    return _request('GET', '/bookings/vendor/bookings');
  }

  Future<ApiResponse> acceptBooking(String id, {String? notes}) async {
    return _request('PUT', '/bookings/$id/accept', body: notes != null ? {'vendorNotes': notes} : null);
  }

  Future<ApiResponse> declineBooking(String id, {String? reason}) async {
    return _request('PUT', '/bookings/$id/decline', body: reason != null ? {'reason': reason} : null);
  }

  // Vendor Packages Management
  Future<ApiResponse> createPackage(Map<String, dynamic> data) async {
    return _request('POST', '/vendors/me/packages', body: data);
  }

  Future<ApiResponse> updatePackage(String id, Map<String, dynamic> data) async {
    return _request('PUT', '/vendors/me/packages/$id', body: data);
  }

  Future<ApiResponse> deletePackage(String id) async {
    return _request('DELETE', '/vendors/me/packages/$id');
  }

  // Bookings
  Future<ApiResponse> getMyBookings() async {
    return _request('GET', '/bookings/my-bookings');
  }

  Future<ApiResponse> createBooking(Map<String, dynamic> data) async {
    return _request('POST', '/bookings', body: data);
  }

  Future<ApiResponse> cancelBooking(String id) async {
    return _request('PUT', '/bookings/$id/cancel');
  }
}

class ApiResponse {
  final int statusCode;
  final dynamic data;

  ApiResponse({required this.statusCode, required this.data});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  String? get errorMessage {
    if (isSuccess) return null;
    if (data is Map) {
      return data['error']?['message'] ?? data['message'] ?? 'An error occurred';
    }
    return 'An error occurred';
  }

  dynamic get responseData => data['data'] ?? data;
}
