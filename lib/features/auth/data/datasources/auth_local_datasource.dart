import '../../../../core/local_storage/local_storage.dart';
import '../models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  });

  Future<void> clearTokens();

  Future<UserDto?> getCachedUser();

  Future<void> cacheUser(UserDto user);

  Future<void> clearCachedUser();

  Future<bool> isAuthenticated();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required TokenStorage tokenStorage,
    required ILocalStorage localStorage,
  }) : _tokenStorage = tokenStorage,
       _localStorage = localStorage;
  final TokenStorage _tokenStorage;
  final ILocalStorage _localStorage;

  static const String _userCacheKey = 'cached_user';

  @override
  Future<String?> getAccessToken() async => _tokenStorage.getAccessToken();

  @override
  Future<String?> getRefreshToken() async => _tokenStorage.getRefreshToken();

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _tokenStorage.setAccessToken(accessToken);
    await _tokenStorage.setRefreshToken(refreshToken);
    await _tokenStorage.setTokenExpiry(expiresAt);
  }

  @override
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
  }

  @override
  Future<UserDto?> getCachedUser() async {
    final jsonString = await _localStorage.getString(_userCacheKey);
    if (jsonString == null) {
      return null;
    }

    try {
      return UserDto.fromJsonString(jsonString);
    } catch (_) {
      await clearCachedUser();
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserDto user) async {
    await _localStorage.setString(_userCacheKey, user.toJsonString());
  }

  @override
  Future<void> clearCachedUser() async {
    await _localStorage.remove(_userCacheKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      return false;
    }

    final isExpired = await _tokenStorage.isTokenExpired();
    return !isExpired;
  }
}
