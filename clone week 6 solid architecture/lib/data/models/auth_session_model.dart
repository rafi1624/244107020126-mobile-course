import '../../domain/entities/auth_session.dart';

/// Data Model: AuthSessionModel (Clean Architecture - Data Layer)
/// Bertanggung jawab atas serialisasi / deserialisasi JSON respon REST API
class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.access,
    required super.refresh,
    super.userName,
    super.userEmail,
  });

  factory AuthSessionModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackEmail,
  }) {
    final payload = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final user = payload['user'] as Map<String, dynamic>?;

    final accessToken = payload['idToken'] as String? ??
        payload['access_token'] as String? ??
        '';
    final refreshToken = payload['refreshToken'] as String? ??
        payload['refresh_token'] as String? ??
        '';
    final userEmail = payload['email'] as String? ??
        user?['email'] as String? ??
        fallbackEmail;
    final userName = payload['displayName'] as String? ??
        user?['name'] as String? ??
        userEmail?.split('@').first;

    return AuthSessionModel(
      access: accessToken,
      refresh: refreshToken,
      userName: userName,
      userEmail: userEmail,
    );
  }
}
