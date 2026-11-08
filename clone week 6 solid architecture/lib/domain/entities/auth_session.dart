/// Domain Entity: AuthSession
/// Murni Dart tanpa dependensi ke Flutter, Dio, atau pustaka luar.
class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
    this.userName,
    this.userEmail,
  });

  final String access;
  final String refresh;
  final String? userName;
  final String? userEmail;
}

