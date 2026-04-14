import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../error/error.dart';

class NetworkInfo {
  const NetworkInfo({
    required this.isConnectedToTheInternet,
    this.typeOfConnection,
  });

  final bool isConnectedToTheInternet;

  final ConnectionType? typeOfConnection;
}

enum ConnectionType { wifi, mobile, ethernet, none }

abstract class INetworkInfo {
  Future<NetworkInfo> getNetworkInfo();

  Stream<NetworkInfo> get onNetworkStatusChanged;

  Future<bool> get isConnected;

  Future<bool> get isConnectedOnWifi;
}

class NetworkInfoImpl implements INetworkInfo {
  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();
  final Connectivity _connectivity;

  @override
  Future<NetworkInfo> getNetworkInfo() async {
    final result = await _connectivity.checkConnectivity();
    return _mapConnectivityResult(result);
  }

  @override
  Stream<NetworkInfo> get onNetworkStatusChanged =>
      _connectivity.onConnectivityChanged.map(_mapConnectivityResult);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<bool> get isConnectedOnWifi async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  NetworkInfo _mapConnectivityResult(List<ConnectivityResult> result) {
    if (result.isEmpty || result.contains(ConnectivityResult.none)) {
      return const NetworkInfo(
        isConnectedToTheInternet: false,
        typeOfConnection: ConnectionType.none,
      );
    }

    final types = result.map((r) => _mapConnectionType(r)).toSet();
    final primaryType = types.contains(ConnectionType.wifi)
        ? ConnectionType.wifi
        : types.contains(ConnectionType.mobile)
        ? ConnectionType.mobile
        : types.first;

    return NetworkInfo(
      isConnectedToTheInternet: true,
      typeOfConnection: primaryType,
    );
  }

  ConnectionType _mapConnectionType(ConnectivityResult result) =>
      switch (result) {
        ConnectivityResult.wifi => ConnectionType.wifi,
        ConnectivityResult.mobile => ConnectionType.mobile,
        ConnectivityResult.ethernet => ConnectionType.ethernet,
        _ => ConnectionType.none,
      };
}

/// API client wrapper around Dio.
///
/// Provides:
/// - Automatic token injection
/// - Request/response logging
/// - Error handling
/// - Retry logic
/// - Timeout configuration
class ApiClient {
  ApiClient({
    required String baseUrl,
    required INetworkInfo networkInfo,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    this.onTokenRefresh,
    this.onError,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout ?? const Duration(seconds: 30),
           receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ),
       _networkInfo = networkInfo {
    _setupInterceptors();
  }
  final Dio _dio;
  final INetworkInfo _networkInfo;
  final void Function(String, String)? onTokenRefresh;
  final void Function(RequestOptions, Response?)? onError;

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              onTokenRefresh?.call('refresh', '');
              final response = await _retryRequest(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              handler.next(error);
              return;
            }
          }
          handler.next(error);
        },
      ),
      // Logging interceptor
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    ]);
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  String? get authToken => _dio.options.headers['Authorization'] as String?;

  Future<bool> _checkConnectivity() async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkException(
        message: 'No internet connection',
        code: 'NETWORK_NO_CONNECTION',
      );
    }
    return true;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> download(
    String path,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    return _dio.download(path, savePath, onReceiveProgress: onReceiveProgress);
  }

  Future<Response<T>> upload<T>(
    String path, {
    required FormData data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    await _checkConnectivity();
    return _dio.post<T>(
      path,
      data: data,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  void close() {
    _dio.close();
  }
}

extension ApiResponseExtension<T> on Response<T> {
  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  bool get isServerError => statusCode != null && statusCode! >= 500;
}
