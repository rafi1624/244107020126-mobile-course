import '../repositories/token_repository.dart';

/// UseCase CheckAuthStatus: Memeriksa apakah terdapat token akses aktif
class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase({
    required TokenRepository tokenRepository,
  }) : _tokenRepository = tokenRepository;

  final TokenRepository _tokenRepository;

  Future<bool> execute() async {
    final token = await _tokenRepository.readAccess();
    return token != null && token.isNotEmpty;
  }
}

