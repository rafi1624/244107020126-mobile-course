import '../entities/auth_session.dart';
import '../entities/user_profile.dart';

/// Kontrak Interface Repository Autentikasi (Domain Layer)
/// Presentation dan UseCase hanya bergantung pada abstraksi ini (Dependency Inversion)
abstract class AuthRepository {
  String get baseUrl;
  set baseUrl(String url);

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<String> refresh(String refreshToken);

  Future<void> logout();

  Future<UserProfile> fetchProfile(String accessToken);
}

