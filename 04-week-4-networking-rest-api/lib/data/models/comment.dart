/// Model Comment merepresentasikan data komentar dari endpoint GET /comments.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  /// Factory constructor fromJson dengan pengamanan null-safety:
  /// - Field angka (postId, id) di-cast ke num? terlebih dahulu lalu dikonversi ke toInt(),
  ///   dengan nilai default 0 jika null atau tidak ada di JSON.
  /// - Field teks (name, email, body) di-cast ke String? dengan nilai default string kosong ('')
  ///   agar tidak memicu TypeError saat API mengembalikan nilai null / field tidak ada.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  /// Mengonversi objek Comment kembali menjadi Map JSON
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
