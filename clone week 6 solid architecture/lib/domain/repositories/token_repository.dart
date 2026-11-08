/// Kontrak Interface Repository Penyimpanan Token (Domain Layer)
/// Memisahkan kontrak penyimpanan aman dari pustaka FlutterSecureStorage (Dependency Inversion)
abstract class TokenRepository {
  Future<void> save({
    required String access,
    required String refresh,
    String? email,
    String? name,
  });

  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<String?> readEmail();
  Future<String?> readName();
  Future<void> clear();
}

