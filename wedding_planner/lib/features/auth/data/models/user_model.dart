import '../../domain/entities/user.dart';

/// User Model for API serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.phone,
    required super.userType,
    required super.createdAt,
    super.isActive,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      userType: _parseUserType(json['user_type'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'user_type': userType.name,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Convert to entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      phone: phone,
      userType: userType,
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  /// Create from entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      phone: user.phone,
      userType: user.userType,
      createdAt: user.createdAt,
      isActive: user.isActive,
    );
  }

  static UserType _parseUserType(String? type) {
    switch (type?.toLowerCase()) {
      case 'couple':
        return UserType.couple;
      case 'vendor':
        return UserType.vendor;
      case 'guest':
        return UserType.guest;
      default:
        return UserType.couple;
    }
  }
}
