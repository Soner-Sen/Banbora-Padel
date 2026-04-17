import 'package:equatable/equatable.dart';

import '../../../../core/error/error.dart';
import '../../domain/entities/guest_user.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated || this is AuthGuest;

  bool get isGuest => this is AuthGuest;

  User? get user => null;

  GuestUser? get guestUser => null;

  String? get errorMessage => null;

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading({this.message});
  final String? message;

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});
  @override
  final User user;

  @override
  List<Object?> get props => [user];
}

class AuthGuest extends AuthState {
  const AuthGuest({required this.guestUser});
  @override
  final GuestUser guestUser;

  @override
  List<Object?> get props => [guestUser];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError({required this.message, this.failure});
  final String message;
  final Failure? failure;

  @override
  List<Object?> get props => [message, failure];
}
