import '../../domain/entities/auth_session.dart';

/// Data Model: AuthSessionModel
/// Bertanggung jawab atas serialisasi / deserialisasi JSON dari respon API
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

    final accessToken = payload['access_token'] as String? ?? '';
    final refreshToken = payload['refresh_token'] as String? ?? '';

    return AuthSessionModel(
      access: accessToken,
      refresh: refreshToken,
      userName: user?['name'] as String?,
      userEmail: user?['email'] as String? ?? fallbackEmail,
    );
  }
}

