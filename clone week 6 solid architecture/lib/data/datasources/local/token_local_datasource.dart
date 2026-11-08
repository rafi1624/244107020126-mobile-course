import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenLocalDataSource {
  Future<void> saveTokens({
    required String access,
    required String refresh,
    String? email,
    String? name,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getUserEmail();
  Future<String?> getUserName();
  Future<void> clearAll();
}

class TokenLocalDataSourceImpl implements TokenLocalDataSource {
  TokenLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_name';

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
    String? email,
    String? name,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    if (email != null) await _storage.write(key: _emailKey, value: email);
    if (name != null) await _storage.write(key: _nameKey, value: name);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<String?> getUserEmail() => _storage.read(key: _emailKey);

  @override
  Future<String?> getUserName() => _storage.read(key: _nameKey);

  @override
  Future<void> clearAll() => _storage.deleteAll();
}

