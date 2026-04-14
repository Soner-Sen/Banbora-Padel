import 'package:equatable/equatable.dart';

/// Base failure class for all domain failures.
///
/// All failures should extend this class to provide a consistent
/// error handling interface across the application.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code, this.originalError});

  final String message;

  final String? code;

  final Object? originalError;

  @override
  List<Object?> get props => [message, code, originalError];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message =
        'Network connection error. Please check your internet connection.',
    super.code,
    super.originalError,
  });

  factory NetworkFailure.noConnection() => const NetworkFailure(
    message: 'No internet connection. Please check your network.',
    code: 'no_connection',
  );

  factory NetworkFailure.timeout() => const NetworkFailure(
    message: 'Request timed out. Please try again.',
    code: 'timeout',
  );

  bool get isNoConnection =>
      code == 'no_connection' || message.contains('connection');

  bool get isTimeout => code == 'timeout' || message.contains('timed out');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out. Please try again.',
    super.code,
    super.originalError,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error. Please try again later.',
    super.code,
    super.originalError,
    this.statusCode,
  });
  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

class ServiceUnavailableFailure extends ServerFailure {
  const ServiceUnavailableFailure({
    super.message =
        'Service is temporarily unavailable. Please try again later.',
    super.code,
    super.originalError,
  }) : super(statusCode: 503);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  factory ValidationFailure.multipleFields(Map<String, List<String>> errors) {
    final messages = errors.entries
        .map((e) => "${e.key}: ${e.value.join(', ')}")
        .join('; ');
    return ValidationFailure(
      message: messages.isNotEmpty ? messages : 'Validation failed',
      fieldErrors: errors,
    );
  }
  final Map<String, List<String>>? fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class EmailValidationFailure extends ValidationFailure {
  const EmailValidationFailure({
    super.message = 'Invalid email format',
    super.code = 'invalid_email',
    super.originalError,
  });
}

class PasswordValidationFailure extends ValidationFailure {
  const PasswordValidationFailure({
    super.message = 'Password does not meet requirements',
    super.code = 'invalid_password',
    super.originalError,
  });
}

// ============================================================================
// Authentication Failures
// ============================================================================

/// Authentication failure (401).
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please check your credentials.',
    super.code,
    super.originalError,
  });
}

/// Invalid credentials failure.
class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password.',
    super.code = 'invalid_credentials',
    super.originalError,
  });
}

/// Token expired failure.
class TokenExpiredFailure extends AuthFailure {
  const TokenExpiredFailure({
    super.message = 'Session expired. Please sign in again.',
    super.code = 'token_expired',
    super.originalError,
  });
}

/// Not authenticated (no valid session).
class NotAuthenticatedFailure extends AuthFailure {
  const NotAuthenticatedFailure({
    super.message = 'Please sign in to continue.',
    super.code = 'not_authenticated',
    super.originalError,
  });
}

/// Insufficient permissions (403).
class ForbiddenFailure extends AuthFailure {
  const ForbiddenFailure({
    super.message = "You don't have permission to perform this action.",
    super.code = 'forbidden',
    super.originalError,
  });
}

// ============================================================================
// Cache Failures
// ============================================================================

/// Local storage/cache failure.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
    super.code,
    super.originalError,
  });
}

/// Cache read failure.
class CacheReadFailure extends CacheFailure {
  const CacheReadFailure({
    super.message = 'Failed to read from cache.',
    super.code = 'cache_read_error',
    super.originalError,
  });
}

/// Cache write failure.
class CacheWriteFailure extends CacheFailure {
  const CacheWriteFailure({
    super.message = 'Failed to save to cache.',
    super.code = 'cache_write_error',
    super.originalError,
  });
}

// ============================================================================
// Resource Failures
// ============================================================================

/// Resource not found (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'not_found',
    super.originalError,
    this.resourceId,
    this.resourceType,
  });
  final String? resourceId;
  final String? resourceType;

  @override
  List<Object?> get props => [...super.props, resourceId, resourceType];
}

/// Conflict failure (409).
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'The request conflicts with the current state.',
    super.code = 'conflict',
    super.originalError,
  });
}

// ============================================================================
// Unknown Failures
// ============================================================================

/// Unknown/unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'unknown',
    super.originalError,
  });

  /// Factory constructor for creating from any exception.
  factory UnknownFailure.fromException(Object error) =>
      UnknownFailure(message: error.toString(), originalError: error);
}
