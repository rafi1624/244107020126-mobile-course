/// Domain Entity: UserProfile
/// Murni Dart untuk merepresentasikan data profil pengguna.
class UserProfile {
  const UserProfile({
    this.id,
    this.name,
    this.email,
    this.rawAttributes = const {},
  });

  final dynamic id;
  final String? name;
  final String? email;
  final Map<String, dynamic> rawAttributes;
}

