import '../repositories/auth_repository.dart';
import '../repositories/token_repository.dart';

/// UseCase Logout: Melakukan pembersihan token lokal dan memanggil endpoint logout API
class LogoutUseCase {
  const LogoutUseCase({
    required AuthRepository authRepository,
    required TokenRepository tokenRepository,
  })  : _authRepository = authRepository,
        _tokenRepository = tokenRepository;

  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  Future<void> execute() async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Mengabaikan kegagalan jaringan saat logout server
    }
    await _tokenRepository.clear();
  }
}

