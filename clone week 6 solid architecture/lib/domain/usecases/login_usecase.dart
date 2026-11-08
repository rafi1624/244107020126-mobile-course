import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';
import '../repositories/token_repository.dart';

/// UseCase Login: Mengatur alur login dan persistensi token ke penyimpanan aman
class LoginUseCase {
  const LoginUseCase({
    required AuthRepository authRepository,
    required TokenRepository tokenRepository,
  })  : _authRepository = authRepository,
        _tokenRepository = tokenRepository;

  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) async {
    final session = await _authRepository.login(
      email: email,
      password: password,
    );

    await _tokenRepository.save(
      access: session.access,
      refresh: session.refresh,
      email: session.userEmail ?? email,
      name: session.userName,
    );

    return session;
  }
}

