import 'package:dartz/dartz.dart';

import '../../../../core/error/error.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  bool get isValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      firstName.isNotEmpty &&
      lastName.isNotEmpty;

  Map<String, List<String>>? getValidationErrors() {
    final errors = <String, List<String>>{};

    if (email.isEmpty) {
      errors['email'] = ['Email is required'];
    } else if (Email.tryParse(email) == null) {
      errors['email'] = ['Please enter a valid email address'];
    }

    if (password.isEmpty) {
      errors['password'] = ['Password is required'];
    } else if (Password.tryParse(password) == null) {
      errors['password'] = ['Password must be at least 8 characters'];
    }

    if (firstName.isEmpty) {
      errors['firstName'] = ['First name is required'];
    }

    if (lastName.isEmpty) {
      errors['lastName'] = ['Last name is required'];
    }

    return errors.isEmpty ? null : errors;
  }
}

class RegisterUseCase {
  const RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthResult>> call(RegisterParams params) async {
    if (!params.isValid) {
      return Left(
        ValidationFailure.multipleFields(params.getValidationErrors()!),
      );
    }

    return _repository.register(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}
