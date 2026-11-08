import '../../domain/entities/user_profile.dart';

/// Data Model: UserProfileModel (Clean Architecture - Data Layer)
/// Bertanggung jawab mengonversi JSON respons endpoint profil REST API ke Entity UserProfile
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.id,
    super.name,
    super.email,
    super.rawAttributes = const {},
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    if (json['users'] is List && (json['users'] as List).isNotEmpty) {
      final user = (json['users'] as List).first as Map<String, dynamic>;
      return UserProfileModel(
        id: user['localId'] ?? user['uid'],
        name: user['displayName'] ??
            (user['email'] as String?)?.split('@').first ??
            'Mahasiswa',
        email: user['email'] as String?,
        rawAttributes: Map<String, dynamic>.from(user),
      );
    }

    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserProfileModel(
      id: data['id'] ?? data['uid'] ?? data['localId'],
      name: data['name'] ??
          data['displayName'] ??
          (data['email'] as String?)?.split('@').first,
      email: data['email'] as String?,
      rawAttributes: Map<String, dynamic>.from(data),
    );
  }
}
