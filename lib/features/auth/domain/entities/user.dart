import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.role = UserRole.player,
  });

  final String id;

  final String email;

  final String firstName;

  final String lastName;

  final String? phoneNumber;

  final String? avatarUrl;

  final bool isEmailVerified;

  final UserRole role;

  final DateTime createdAt;

  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  bool get isAdmin => role == UserRole.admin;

  bool get isClubOwner => role == UserRole.clubOwner;

  bool get isPlayer => role == UserRole.player;

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    bool? isEmailVerified,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    role: role ?? this.role,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phoneNumber,
    avatarUrl,
    isEmailVerified,
    role,
    createdAt,
    updatedAt,
  ];
}

enum UserRole { player, clubOwner, admin }

class Email extends Equatable {
  factory Email(String value) {
    if (!_isValidEmail(value)) {
      throw ArgumentError('Invalid email format: $value');
    }
    return Email._(value);
  }

  const Email._(this.value);

  final String value;

  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static Email? tryParse(String value) {
    if (!_isValidEmail(value)) {
      return null;
    }
    return Email._(value);
  }

  @override
  List<Object?> get props => [value];
}

class Password extends Equatable {
  factory Password(String value) {
    if (!_isValidPassword(value)) {
      throw ArgumentError('Password must be at least $minLength characters');
    }
    return Password._(value);
  }

  const Password._(this.value);

  final String value;

  static const int minLength = 8;

  static bool _isValidPassword(String password) => password.length >= minLength;

  static Password? tryParse(String value) {
    if (!_isValidPassword(value)) {
      return null;
    }
    return Password._(value);
  }

  @override
  List<Object?> get props => [value.hashCode];
}

class AuthResult extends Equatable {
  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final User user;

  final String accessToken;

  final String refreshToken;

  final DateTime expiresAt;

  bool get isTokenExpired => DateTime.now().isAfter(expiresAt);

  Duration get tokenTimeRemaining => expiresAt.difference(DateTime.now());

  @override
  List<Object?> get props => [user, accessToken, refreshToken, expiresAt];
}
