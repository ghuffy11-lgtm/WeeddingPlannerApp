import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userId;
  String? _email;
  String? _userType;
  String? _weddingId;
  Map<String, dynamic>? _wedding;
  String? _vendorId;
  Map<String, dynamic>? _vendor;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get email => _email;
  String? get userType => _userType;
  String? get weddingId => _weddingId;
  Map<String, dynamic>? get wedding => _wedding;
  String? get vendorId => _vendorId;
  Map<String, dynamic>? get vendor => _vendor;
  String? get error => _error;
  ApiService get api => _api;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.login(email, password);

    if (response.isSuccess) {
      final data = response.responseData;
      _api.setTokens(data['accessToken'], data['refreshToken']);
      _userId = data['user']['id'];
      _email = data['user']['email'];
      _userType = data['user']['userType'];
      _isAuthenticated = true;

      // Fetch profile based on user type
      if (_userType == 'vendor') {
        await _fetchVendor();
      } else {
        await _fetchWedding();
      }
    } else {
      _error = response.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
    return response.isSuccess;
  }

  Future<bool> register(String email, String password, String userType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.register(email, password, userType);

    if (response.isSuccess) {
      final data = response.responseData;
      _api.setTokens(data['accessToken'], data['refreshToken']);
      _userId = data['user']['id'];
      _email = data['user']['email'];
      _userType = data['user']['userType'];
      _isAuthenticated = true;
    } else {
      _error = response.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
    return response.isSuccess;
  }

  Future<void> _fetchWedding() async {
    final response = await _api.getMyWedding();
    if (response.isSuccess && response.responseData != null) {
      _wedding = response.responseData;
      _weddingId = _wedding?['id'];
    }
    notifyListeners();
  }

  Future<void> _fetchVendor() async {
    final response = await _api.getMyVendor();
    if (response.isSuccess && response.responseData != null) {
      _vendor = response.responseData;
      _vendorId = _vendor?['id'];
    }
    notifyListeners();
  }

  Future<bool> createVendor(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.createVendor(data);

    if (response.isSuccess) {
      _vendor = response.responseData;
      _vendorId = _vendor?['id'];
    } else {
      _error = response.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
    return response.isSuccess;
  }

  Future<void> refreshVendor() async {
    await _fetchVendor();
    notifyListeners();
  }

  Future<bool> createWedding(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.createWedding(data);

    if (response.isSuccess) {
      _wedding = response.responseData;
      _weddingId = _wedding?['id'];
    } else {
      _error = response.errorMessage;
    }

    _isLoading = false;
    notifyListeners();
    return response.isSuccess;
  }

  Future<void> refreshWedding() async {
    await _fetchWedding();
    notifyListeners();
  }

  void logout() {
    _api.clearTokens();
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _userType = null;
    _weddingId = null;
    _wedding = null;
    _vendorId = null;
    _vendor = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
