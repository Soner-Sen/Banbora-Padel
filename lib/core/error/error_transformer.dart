import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

typedef ErrorTransformer = Failure Function(Object error);

Failure defaultErrorTransformer(Object error) => switch (error) {
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

  final NetworkException e => NetworkFailure(
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

  final AuthException e => AuthFailure(
    message: e.message,
    code: e.code,
    originalError: e.originalError,
  ),

  final AppException e => UnknownFailure(
    message: e.message,
    code: e.code,
    originalError: e.originalError,
  ),

  final Exception e => UnknownFailure.fromException(e),
  final Error e => UnknownFailure.fromException(e),
  final Object e => UnknownFailure.fromException(e),
};

extension ResultTransform<E> on Either<Failure, E> {
  Either<Failure, E> transformFailure([ErrorTransformer? transformer]) {
    final fn = transformer ?? defaultErrorTransformer;
    return fold((failure) => Left(fn(failure)), (success) => Right(success));
  }

  Either<Failure, R> mapSuccess<R>(R Function(E value) mapper) =>
      fold((failure) => Left(failure), (success) => Right(mapper(success)));

  R foldMap<R>({
    required R Function(Failure failure) onFailure,
    required R Function(E value) onSuccess,
  }) => fold((failure) => onFailure(failure), (success) => onSuccess(success));

  E? getOrNull() => fold((_) => null, (value) => value);

  Failure? getFailureOrNull() => fold((failure) => failure, (_) => null);

  bool get isSuccess => isRight();

  bool get isFailure => isLeft();
}

// ignore: unintended_html_in_doc_comment
/// Helper to safely execute a function and return Either<Failure, T>.
///
/// Example:
/// ```dart
/// final result = await tryExecute(
///   () => api.getUser(id),
///   transformer: myCustomTransformer,
/// );
/// ```
Future<Either<Failure, T>> tryExecute<T>(
  Future<T> Function() execute, {
  ErrorTransformer? transformer,
}) async {
  try {
    final result = await execute();
    return Right(result);
  } catch (e) {
    final failure = (transformer ?? defaultErrorTransformer)(e);
    return Left(failure);
  }
}

Either<Failure, T> tryExecuteSync<T>(
  T Function() execute, {
  ErrorTransformer? transformer,
}) {
  try {
    final result = execute();
    return Right(result);
  } catch (e) {
    final failure = (transformer ?? defaultErrorTransformer)(e);
    return Left(failure);
  }
}
