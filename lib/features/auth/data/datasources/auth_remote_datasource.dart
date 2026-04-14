import 'package:dio/dio.dart';

import '../../../../core/error/error.dart';
import '../../../../core/network/network.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> login(LoginRequestDto request);

  Future<AuthResponseDto> register(RegisterRequestDto request);

  Future<UserDto> getCurrentUser();

  Future<AuthResponseDto> refreshToken(String refreshToken);

  Future<void> sendPasswordResetEmail(String email);

  Future<UserDto> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;
  final ApiClient _apiClient;

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');

      return UserDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseDto> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      return AuthResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _apiClient.post<void>(
        '/auth/password-reset',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserDto> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) {
        data['first_name'] = firstName;
      }
      if (lastName != null) {
        data['last_name'] = lastName;
      }
      if (phoneNumber != null) {
        data['phone_number'] = phoneNumber;
      }

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/auth/me',
        data: data,
      );

      return UserDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please try again.',
          code: 'NETWORK_TIMEOUT',
        );

      case DioExceptionType.connectionError:
        return NetworkException.noConnection();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final data = e.response?.data;
        final message = data is Map ? data['message'] as String? : null;

        if (statusCode == 401) {
          return const AuthException(
            message: 'Invalid credentials.',
            code: 'AUTH_INVALID_CREDENTIALS',
          );
        }
        if (statusCode == 409) {
          return const AuthException(
            message: 'Email already exists.',
            code: 'AUTH_EMAIL_EXISTS',
          );
        }
        if (statusCode == 422) {
          return ValidationException(
            message: message ?? 'Validation error.',
            fieldErrors: data is Map
                ? _extractFieldErrors(data as Map<String, dynamic>)
                : null,
          );
        }

        return ServerException.fromStatusCode(statusCode, e);

      default:
        return UnknownException.fromObject(e);
    }
  }

  /// Extracts field errors from validation response.
  Map<String, List<String>>? _extractFieldErrors(Map<String, dynamic> data) {
    final errors = data['errors'];
    if (errors is! Map) {
      return null;
    }

    return errors.map<String, List<String>>((key, value) {
      final messages = value is List
          ? value.map((e) => e.toString()).toList()
          : <String>[value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }
}
