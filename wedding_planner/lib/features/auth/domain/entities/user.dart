import 'package:equatable/equatable.dart';

/// User Entity
/// Core domain model representing a user
class User extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final UserType userType;
  final DateTime createdAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    this.phone,
    required this.userType,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, email, phone, userType, createdAt, isActive];
}

enum UserType {
  couple,
  vendor,
  guest,
}
