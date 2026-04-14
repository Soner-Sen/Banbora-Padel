import 'package:equatable/equatable.dart';

import '../../../../core/error/error.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;

  User? get user => null;

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
