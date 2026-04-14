import 'package:dartz/dartz.dart';

import '../../../../core/error/error.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;

  bool get isValid => email.isNotEmpty && password.isNotEmpty;
}

class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthResult>> call(LoginParams params) async {
    if (!params.isValid) {
      return const Left(
        ValidationFailure(
          message: 'Email and password are required.',
          code: 'AUTH_LOGIN_INVALID_INPUT',
        ),
      );
    }

    final email = Email.tryParse(params.email);
    if (email == null) {
      return const Left(
        ValidationFailure(
          message: 'Please enter a valid email address.',
          code: 'AUTH_LOGIN_INVALID_EMAIL',
        ),
      );
    }

    final password = Password.tryParse(params.password);
    if (password == null) {
      return const Left(
        ValidationFailure(
          message: 'Password must be at least 8 characters.',
          code: 'AUTH_LOGIN_INVALID_PASSWORD',
        ),
      );
    }

    return _repository.login(email: params.email, password: params.password);
  }
}
