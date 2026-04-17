import 'package:dartz/dartz.dart';

import 'failures.dart';

abstract class UseCase<T, Return> {
  /// Executes this use case with the given input.
  ///
  // ignore: unintended_html_in_doc_comment
  /// Returns Either<Failure, Return> to represent success or failure.
  /// Override this in your use case implementation.
  Future<Either<Failure, Return>> call(T input);
}

/// Base class for use cases that don't require input.
///
/// Use this for use cases like "GetCurrentUser" or "Logout".
abstract class NoParamsUseCase<Return> {
  /// Executes this use case with no input.
  Future<Either<Failure, Return>> call();
}

/// Base class for use cases that stream results.
///
/// Use this for real-time updates like notifications or live data.
abstract class StreamUseCase<T, Return> {
  /// Returns a stream of results.
  Stream<Either<Failure, Return>> call(T input);
}

/// Base class for use cases that return immediately (synchronous).
///
/// Use this for simple computations that don't need async.
abstract class SyncUseCase<T, Return> {
  /// Executes synchronously and returns the result.
  Either<Failure, Return> call(T input);
}

/// Input wrapper for use cases with multiple parameters.
///
/// When a use case needs multiple parameters, create a dedicated
/// input class instead of using this wrapper.
///
/// Example:
/// ```dart
/// class LoginInput {
///   final String email;
///   final String password;
///   const LoginInput({required this.email, required this.password});
/// }
/// ```
class UseCaseInput<T> {
  const UseCaseInput(this.value);
  final T value;
}

/// Extension to convert values to UseCaseInput.
extension UseCaseInputX<T> on T {
  /// Wraps this value in a UseCaseInput.
  UseCaseInput<T> toInput() => UseCaseInput(this);
}

mixin CancellableUseCase<T, Return> on UseCase<T, Return> {
  void cancel();
}

mixin RetryableUseCase<T, Return> on UseCase<T, Return> {
  int get maxRetries => 3;

  int get retryDelayMs => 1000;

  bool shouldRetry(Failure failure) => failure is ServerFailure;
}
