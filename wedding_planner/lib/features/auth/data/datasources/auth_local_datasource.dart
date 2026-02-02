import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_tokens.dart';
import '../models/user_model.dart';

/// Auth Local Data Source
/// Handles local storage of auth data (tokens, cached user)
abstract class AuthLocalDataSource {
  /// Save auth tokens
  Future<void> saveTokens(AuthTokens tokens);

  /// Get saved tokens
  Future<AuthTokens?> getTokens();

  /// Delete tokens
  Future<void> deleteTokens();

  /// Save user data
  Future<void> saveUser(UserModel user);

  /// Get cached user
  Future<UserModel?> getUser();

  /// Delete user data
  Future<void> deleteUser();

  /// Clear all auth data
  Future<void> clearAll();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}

/// Implementation using SharedPreferences and FlutterSecureStorage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  static const String _tokenKey = 'auth_tokens';
  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    // Store tokens securely
    await secureStorage.write(
      key: _tokenKey,
      value: jsonEncode(tokens.toJson()),
    );
  }

  @override
  Future<AuthTokens?> getTokens() async {
    final tokensJson = await secureStorage.read(key: _tokenKey);
    if (tokensJson == null) return null;

    try {
      final data = jsonDecode(tokensJson) as Map<String, dynamic>;
      return AuthTokens.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteTokens() async {
    await secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    // User data can be stored in regular preferences (not sensitive)
    await sharedPreferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson == null) return null;

    try {
      final data = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<void> clearAll() async {
    await deleteTokens();
    await deleteUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    final tokens = await getTokens();
    if (tokens == null) return false;
    return !tokens.isExpired;
  }
}
