import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';

/// Provider untuk CommentRepository menggunakan konfigurasi Dio terpusat
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProviderForComments)),
);

/// Provider instance Dio terpusat (Base URL, Timeout, Logging)
final dioProviderForComments = Provider<Dio>((ref) => createDio());

/// AsyncNotifier untuk mengelola state daftar komentar
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    // Membaca repository dan mengambil komentar untuk postId default (1).
    // Exception dari repository otomatis menjadi AsyncError di Riverpod.
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(1);
  }

  /// Mengambil komentar untuk [postId] tertentu
  Future<void> fetchForPost(int postId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Fungsi refresh untuk memuat ulang komentar
  Future<void> refresh([int postId = 1]) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider komentar berbasis AsyncNotifierProvider
final commentListProvider =
    AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
  CommentListNotifier.new,
  // Menonaktifkan retry otomatis agar error langsung final dan mudah diuji
  retry: (retryCount, error) => null,
);

/// Fungsi pesan error ramah pengguna (User-friendly Error Message)
/// Menangani timeout, connection error, bad response (404, 500), dll.
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout (10 detik). Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) {
          return 'Data komentar tidak ditemukan (Error 404).';
        }
        if (code != null && code >= 500) {
          return 'Server sedang mengalami gangguan internal (Error $code). Coba beberapa saat lagi.';
        }
        return 'Permintaan gagal dengan status kode $code.';
      default:
        return 'Terjadi masalah jaringan saat mengambil komentar.';
    }
  }
  return 'Terjadi kesalahan tidak terduga: $error';
}
