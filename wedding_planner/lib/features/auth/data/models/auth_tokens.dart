import 'package:equatable/equatable.dart';

/// Auth Tokens Model
class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Create from JSON
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    // Calculate expiration from expiresIn (seconds) if provided
    final expiresIn = json['expires_in'] as int? ?? 3600;
    final expiresAt = json['expires_at'] != null
        ? DateTime.parse(json['expires_at'] as String)
        : DateTime.now().add(Duration(seconds: expiresIn));

    return AuthTokens(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String,
      refreshToken: json['refresh_token'] as String? ?? json['refreshToken'] as String,
      expiresAt: expiresAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if token needs refresh (5 minutes before expiration)
  bool get needsRefresh => DateTime.now().isAfter(
        expiresAt.subtract(const Duration(minutes: 5)),
      );

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}
