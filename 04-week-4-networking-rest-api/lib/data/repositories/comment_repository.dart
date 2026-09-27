import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk mengelola akses data komentar dari remote API
class CommentRepository {
  /// Menerima instance Dio dari luar (Dependency Injection)
  CommentRepository(this._dio);
  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan [postId]
  /// Endpoint: GET /comments?postId={postId}
  /// Dilengkapi dengan timeout 10 detik sesuai requirements
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Ambil data respons dan pastikan tidak null
    final data = response.data ?? [];

    // Filter elemen yang berupa Map valid, lalu petakan ke model Comment
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
