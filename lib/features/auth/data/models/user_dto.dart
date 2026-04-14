import 'dart:convert';

import '../../domain/entities/user.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.role = 'player',
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    phoneNumber: json['phone_number'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    isEmailVerified: json['is_email_verified'] as bool? ?? false,
    role: json['role'] as String? ?? 'player',
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  factory UserDto.fromJsonString(String jsonString) =>
      UserDto.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  factory UserDto.fromEntity(User user) => UserDto(
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    phoneNumber: user.phoneNumber,
    avatarUrl: user.avatarUrl,
    isEmailVerified: user.isEmailVerified,
    role: _roleToString(user.role),
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  );
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isEmailVerified;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'phone_number': phoneNumber,
    'avatar_url': avatarUrl,
    'is_email_verified': isEmailVerified,
    'role': role,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  String toJsonString() => json.encode(toJson());

  User toEntity() => User(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
    avatarUrl: avatarUrl,
    isEmailVerified: isEmailVerified,
    role: _parseRole(role),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static UserRole _parseRole(String role) => switch (role.toLowerCase()) {
    'admin' => UserRole.admin,
    'club_owner' || 'clubowner' => UserRole.clubOwner,
    _ => UserRole.player,
  };

  static String _roleToString(UserRole role) => switch (role) {
    UserRole.admin => 'admin',
    UserRole.clubOwner => 'club_owner',
    UserRole.player => 'player',
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is UserDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AuthResponseDto {
  const AuthResponseDto({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );
  final UserDto user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthResult toEntity() => AuthResult(
    user: user.toEntity(),
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresAt: expiresAt,
  );
}

class LoginRequestDto {
  const LoginRequestDto({required this.email, required this.password});
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'first_name': firstName,
    'last_name': lastName,
  };
}
