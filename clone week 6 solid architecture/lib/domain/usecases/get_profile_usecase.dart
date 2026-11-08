import '../entities/user_profile.dart';
import '../failures/failure.dart';
import '../repositories/auth_repository.dart';
import '../repositories/token_repository.dart';

/// UseCase GetProfile: Mengambil profil pengguna menggunakan access token aktif
class GetProfileUseCase {
  const GetProfileUseCase({
    required AuthRepository authRepository,
    required TokenRepository tokenRepository,
  })  : _authRepository = authRepository,
        _tokenRepository = tokenRepository;

  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  Future<UserProfile> execute() async {
    final access = await _tokenRepository.readAccess();
    if (access == null || access.isEmpty) {
      throw const AuthFailure('Tidak ada access token aktif.');
    }
    return await _authRepository.fetchProfile(access);
  }
}

