import 'package:dartz/dartz.dart';

import '../../../../core/error/error.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResult>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<Either<Failure, AuthResult>> refreshToken();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });
}
