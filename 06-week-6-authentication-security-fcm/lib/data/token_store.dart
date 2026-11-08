import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_name';

  Future<void> save({
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

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);
  Future<String?> readEmail() => _storage.read(key: _emailKey);
  Future<String?> readName() => _storage.read(key: _nameKey);

  Future<void> clear() => _storage.deleteAll();
}