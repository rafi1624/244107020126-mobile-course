import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

/// Implementasi AuthRepository (Data Layer)
/// Menghubungkan Domain ke Data Source Remote (Dio)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  String get baseUrl => _remoteDataSource.baseUrl;

  @override
  set baseUrl(String url) {
    _remoteDataSource.baseUrl = url;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<String> refresh(String refreshToken) {
    return _remoteDataSource.refresh(refreshToken);
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  Future<UserProfile> fetchProfile(String accessToken) {
    return _remoteDataSource.fetchProfile(accessToken);
  }
}

