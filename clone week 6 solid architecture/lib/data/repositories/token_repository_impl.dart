import '../../domain/repositories/token_repository.dart';
import '../datasources/local/token_local_datasource.dart';

/// Implementasi TokenRepository (Data Layer)
/// Mengimplementasikan kontrak domain menggunakan local data source (FlutterSecureStorage)
class TokenRepositoryImpl implements TokenRepository {
  TokenRepositoryImpl({required TokenLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final TokenLocalDataSource _localDataSource;

  @override
  Future<void> save({
    required String access,
    required String refresh,
    String? email,
    String? name,
  }) {
    return _localDataSource.saveTokens(
      access: access,
      refresh: refresh,
      email: email,
      name: name,
    );
  }

  @override
  Future<String?> readAccess() => _localDataSource.getAccessToken();

  @override
  Future<String?> readRefresh() => _localDataSource.getRefreshToken();

  @override
  Future<String?> readEmail() => _localDataSource.getUserEmail();

  @override
  Future<String?> readName() => _localDataSource.getUserName();

  @override
  Future<void> clear() => _localDataSource.clearAll();
}

