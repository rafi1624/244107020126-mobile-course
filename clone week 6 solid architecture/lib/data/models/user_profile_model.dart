import '../../domain/entities/user_profile.dart';

/// Data Model: UserProfileModel
/// Bertanggung jawab mengonversi JSON respons endpoint /me ke Entity UserProfile
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.id,
    super.name,
    super.email,
    super.rawAttributes = const {},
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserProfileModel(
      id: data['id'],
      name: data['name'] as String?,
      email: data['email'] as String?,
      rawAttributes: Map<String, dynamic>.from(data),
    );
  }
}

