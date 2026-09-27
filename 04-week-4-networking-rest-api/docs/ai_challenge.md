# Laporan AI Challenge - Week 4 (Networking & REST API)

## 1. Prompt yang Digunakan
```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. File Hasil Implementasi
1. **Model**: [`lib/data/models/comment.dart`](../lib/data/models/comment.dart)
2. **Repository**: [`lib/data/repositories/comment_repository.dart`](../lib/data/repositories/comment_repository.dart)
3. **Provider**: [`lib/data/comment_providers.dart`](../lib/data/comment_providers.dart)
4. **Unit Test**: [`test/comment_test.dart`](../test/comment_test.dart)

---

## 3. AI Verification Checklist

| Pertanyaan Checklist | Hasil Verifikasi | Penjelasan & Bukti |
| :--- | :---: | :--- |
| **Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository?** | ✅ **Sesuai** | UI berinteraksi lewat `commentListProvider`, yang memanggil `CommentRepository`. Tidak ada pemanggilan instance Dio langsung di UI. |
| **Apakah fromJson aman null, atau masih memakai cast langsung yang bisa crash?** | ✅ **Sesuai** | Menggunakan `(json['postId'] as num?)?.toInt() ?? 0` dan `json['name'] as String? ?? ''`. Aman dari `TypeError` jika API mengembalikan null / field absen. |
| **Apakah semua tipe DioExceptionType dipetakan ke pesan pengguna?** | ✅ **Sesuai** | `friendlyCommentErrorMessage` menangani `connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`, dan `badResponse` (404, 500+). |
| **Apakah baseUrl/timeout terpusat di satu client, bukan tersebar di tiap method?** | ✅ **Sesuai** | Menggunakan `createDio()` dari `lib/data/api_client.dart` sebagai konfigurasi terpusat. |
| **Apakah test AI benar-benar menguji kasus field hilang, atau hanya happy path?** | ✅ **Sesuai** | Test menguji kasus field `postId` dan `name` bernilai null, serta `id` dan `body` hilang dari payload JSON. Ditambahkan juga edge case Map kosong `{}`. |
| **Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?** | ✅ **Sesuai** | `flutter analyze` menghasilkan **0 issues (No issues found)** dan `flutter test` menghasilkan **All tests passed (5/5 tests passed)**. |

---

## 4. Perbaikan dan Penyesuaian yang Dilakukan
1. **Penyelarasan Provider**: Memastikan `CommentListNotifier` mewarisi `AsyncNotifier<List<Comment>>` standar Riverpod 3 agar kompatibel dengan arsitektur `providers.dart` yang sudah ada di proyek tanpa error type mismatch.
2. **Pengamanan Widget Test**: Melakukan mocking pada unit/widget test agar tidak memicu HTTP request asli di lingkungan pengujian tanpa koneksi internet.
