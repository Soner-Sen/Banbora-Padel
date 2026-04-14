sealed class AppException implements Exception {
  const AppException({required this.message, this.code, this.originalError});
  final String message;
  final String? code;
  final Object? originalError;

  @override
  String toString() => 'AppException: $code - $message';
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  factory ServerException.fromStatusCode(
    int statusCode, [
    Object? originalError,
  ]) => ServerException(
    message: 'Server error: $statusCode',
    code: 'SERVER_$statusCode',
    originalError: originalError,
    statusCode: statusCode,
  );
  final int? statusCode;
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory CacheException.notFound([String? key]) => CacheException(
    message: key != null ? 'Cache not found: $key' : 'Cache not found',
    code: 'CACHE_NOT_FOUND',
  );

  factory CacheException.expired([String? key]) => CacheException(
    message: key != null ? 'Cache expired: $key' : 'Cache expired',
    code: 'CACHE_EXPIRED',
  );

  factory CacheException.corrupted([String? key]) => CacheException(
    message: key != null ? 'Corrupted cache: $key' : 'Corrupted cache',
    code: 'CACHE_CORRUPTED',
  );
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory NetworkException.noConnection() => const NetworkException(
    message: 'No internet connection',
    code: 'NETWORK_NO_CONNECTION',
  );

  factory NetworkException.timeout() => const NetworkException(
    message: 'Connection timed out',
    code: 'NETWORK_TIMEOUT',
  );
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });
  final Map<String, List<String>>? fieldErrors;
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthException.invalidCredentials() => const AuthException(
    message: 'Invalid email or password',
    code: 'AUTH_INVALID_CREDENTIALS',
  );

  factory AuthException.tokenExpired() => const AuthException(
    message: 'Session expired',
    code: 'AUTH_TOKEN_EXPIRED',
  );

  factory AuthException.unauthorized() =>
      const AuthException(message: 'Unauthorized', code: 'AUTH_UNAUTHORIZED');
}

class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred.',
    super.code,
    super.originalError,
  });

  factory UnknownException.fromObject(Object error) => UnknownException(
    message: error.toString(),
    code: 'UNKNOWN',
    originalError: error,
  );
}
