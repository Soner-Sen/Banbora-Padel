import 'package:dartz/dartz.dart';

import '../../../../core/error/error.dart';
import '../../../../core/network/network.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required INetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final INetworkInfo _networkInfo;

  @override
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure.noConnection());
    }

    try {
      final request = LoginRequestDto(email: email, password: password);
      final response = await _remoteDataSource.login(request);

      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt,
      );

      await _localDataSource.cacheUser(response.user);

      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure.noConnection());
    }

    try {
      final request = RegisterRequestDto(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      final response = await _remoteDataSource.register(request);

      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt,
      );

      await _localDataSource.cacheUser(response.user);

      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localDataSource.clearTokens();
      await _localDataSource.clearCachedUser();

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      if (!await _localDataSource.isAuthenticated()) {
        return const Left(
          AuthFailure(
            message: 'User is not authenticated.',
            code: 'AUTH_NOT_AUTHENTICATED',
          ),
        );
      }

      final userDto = await _remoteDataSource.getCurrentUser();

      await _localDataSource.cacheUser(userDto);

      return Right(userDto.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async => _localDataSource.isAuthenticated();

  @override
  Future<Either<Failure, AuthResult>> refreshToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(
          AuthFailure(
            message: 'No refresh token available.',
            code: 'AUTH_NO_REFRESH_TOKEN',
          ),
        );
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);

      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt,
      );

      return Right(response.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure.noConnection());
    }

    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure.noConnection());
    }

    try {
      final userDto = await _remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      await _localDataSource.cacheUser(userDto);

      return Right(userDto.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnknownFailure.fromException(e));
    }
  }

  Failure _mapExceptionToFailure(AppException e) => switch (e) {
    NetworkException _ when e.code == 'NETWORK_NO_CONNECTION' =>
      NetworkFailure.noConnection(),
    NetworkException _ when e.code == 'NETWORK_TIMEOUT' =>
      NetworkFailure.timeout(),
    NetworkException _ => NetworkFailure(
      message: e.message,
      code: e.code,
      originalError: e.originalError,
    ),

    AuthException _ => AuthFailure(
      message: e.message,
      code: e.code,
      originalError: e.originalError,
    ),

    final ValidationException e => ValidationFailure(
      message: e.message,
      code: e.code,
      originalError: e.originalError,
      fieldErrors: e.fieldErrors,
    ),

    final ServerException e => ServerFailure(
      message: e.message,
      code: e.code,
      originalError: e.originalError,
    ),

    final CacheException e => CacheFailure(
      message: e.message,
      code: e.code,
      originalError: e.originalError,
    ),

    _ => UnknownFailure.fromException(e),
  };
}
