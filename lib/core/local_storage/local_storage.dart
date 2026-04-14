import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ILocalStorage {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<bool?> getBool(String key);

  Future<void> setBool(String key, bool value);

  Future<int?> getInt(String key);

  Future<void> setInt(String key, int value);

  Future<double?> getDouble(String key);

  Future<void> setDouble(String key, double value);

  Future<Map<String, dynamic>?> getJson(String key);

  Future<void> setJson(String key, Map<String, dynamic> value);

  Future<void> remove(String key);

  Future<bool> containsKey(String key);

  Future<void> clear();

  Future<List<String>> getKeys();
}

abstract class ISecureStorage {
  Future<String?> get(String key);

  Future<void> set(String key, String value);

  Future<void> remove(String key);

  Future<void> clear();

  Future<bool> containsKey(String key);

  Future<List<String>> getKeys();
}

class SharedPreferencesStorage implements ILocalStorage {
  SharedPreferencesStorage(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<double?> getDouble(String key) async => _prefs.getDouble(key);

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _prefs.getString(key);
    if (value == null) {
      return null;
    }
    return json.decode(value) as Map<String, dynamic>;
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, json.encode(value));
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<List<String>> getKeys() async => _prefs.getKeys().toList();
}

class SecureStorageImpl implements ISecureStorage {
  SecureStorageImpl({AndroidOptions? androidOptions, IOSOptions? iosOptions})
    : _storage = FlutterSecureStorage(
        aOptions: androidOptions ?? const AndroidOptions(),
        iOptions: iosOptions ?? const IOSOptions(),
      );
  final FlutterSecureStorage _storage;

  @override
  Future<String?> get(String key) async => _storage.read(key: key);

  @override
  Future<void> set(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey(String key) async => _storage.containsKey(key: key);

  @override
  Future<List<String>> getKeys() async =>
      _storage.readAll().then((map) => map.keys.toList());
}

/// Hive-based storage for complex objects.
class HiveStorage {
  final Map<String, Box<dynamic>> _boxes = {};

  Future<void> initialize(List<String> boxNames) async {
    await Hive.initFlutter();

    for (final name in boxNames) {
      _boxes[name] = await Hive.openBox<dynamic>(name);
    }
  }

  Box<dynamic> box(String name) {
    final box = _boxes[name];
    if (box == null) {
      throw StateError(
        'Hive box "$name" not initialized. Call initialize() first.',
      );
    }
    return box;
  }

  Future<void> close() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
  }
}

class TokenStorage {
  TokenStorage(this._secureStorage);
  final ISecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  Future<String?> getAccessToken() async => _secureStorage.get(_accessTokenKey);

  Future<void> setAccessToken(String token) async {
    await _secureStorage.set(_accessTokenKey, token);
  }

  Future<String?> getRefreshToken() async =>
      _secureStorage.get(_refreshTokenKey);

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.set(_refreshTokenKey, token);
  }

  Future<DateTime?> getTokenExpiry() async {
    final value = await _secureStorage.get(_tokenExpiryKey);
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Future<void> setTokenExpiry(DateTime expiry) async {
    await _secureStorage.set(_tokenExpiryKey, expiry.toIso8601String());
  }

  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) {
      return true;
    }
    return DateTime.now().isAfter(expiry);
  }

  Future<void> clearTokens() async {
    await _secureStorage.remove(_accessTokenKey);
    await _secureStorage.remove(_refreshTokenKey);
    await _secureStorage.remove(_tokenExpiryKey);
  }

  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      return false;
    }
    if (await isTokenExpired()) {
      return false;
    }
    return true;
  }
}

class JsonObjectStorage<T> {
  JsonObjectStorage({
    required ILocalStorage storage,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  }) : _storage = storage,
       _fromJson = fromJson,
       _toJson = toJson;
  final ILocalStorage _storage;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;

  Future<T?> get(String key) async {
    final json = await _storage.getJson(key);
    if (json == null) {
      return null;
    }
    return _fromJson(json);
  }

  Future<void> set(String key, T value) async {
    await _storage.setJson(key, _toJson(value));
  }

  /// Removes a stored object.
  Future<void> remove(String key) async {
    await _storage.remove(key);
  }
}
