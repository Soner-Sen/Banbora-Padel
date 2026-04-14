import 'package:dartz/dartz.dart';

import '../../../../core/error/error.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, User>> call() async {
    final isAuthenticated = await _repository.isAuthenticated();
    if (!isAuthenticated) {
      return const Left(
        AuthFailure(
          message: 'User is not authenticated.',
          code: 'AUTH_NOT_AUTHENTICATED',
        ),
      );
    }

    return _repository.getCurrentUser();
  }
}
