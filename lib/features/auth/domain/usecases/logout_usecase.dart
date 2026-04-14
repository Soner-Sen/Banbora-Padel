import 'package:dartz/dartz.dart';

import '../../../../core/error/error.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call() async => _repository.logout();
}
