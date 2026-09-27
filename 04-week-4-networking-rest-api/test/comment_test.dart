import 'package:flutter_test/flutter_test.dart';
import 'package:networking_rest_api/data/models/comment.dart';

void main() {
  group('Comment Model Tests', () {
    test('fromJson berhasil mem-parsing data lengkap (Happy Path)', () {
      final json = {
        'postId': 1,
        'id': 101,
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'body': 'Artikel ini sangat bermanfaat.',
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 1);
      expect(comment.id, 101);
      expect(comment.name, 'Budi Santoso');
      expect(comment.email, 'budi@example.com');
      expect(comment.body, 'Artikel ini sangat bermanfaat.');
    });

    test('fromJson aman dari field yang hilang atau bernilai null (AI Requirement)', () {
      // Simulasi JSON di mana beberapa field bernilai null atau tidak ada sama sekali
      final json = {
        'postId': null,
        // 'id' dihilangkan sama sekali
        'name': null,
        'email': 'user@example.com',
        // 'body' dihilangkan sama sekali
      };

      final comment = Comment.fromJson(json);

      // Verifikasi bahwa nilai fallback default diterapkan tanpa memicu TypeError / crash
      expect(comment.postId, 0); // fallback default int
      expect(comment.id, 0);     // fallback default int
      expect(comment.name, '');  // fallback default String
      expect(comment.email, 'user@example.com');
      expect(comment.body, '');  // fallback default String
    });

    test('Edge Case: fromJson menangani Map kosong {} dan tipe num (double/int)', () {
      // 1. Edge Case: Map kosong total
      final emptyJson = <String, dynamic>{};
      final emptyComment = Comment.fromJson(emptyJson);

      expect(emptyComment.postId, 0);
      expect(emptyComment.id, 0);
      expect(emptyComment.name, '');
      expect(emptyComment.email, '');
      expect(emptyComment.body, '');

      // 2. Edge Case: postId/id berupa num (misal 5.0 dari parser)
      final numJson = {
        'postId': 5.0,
        'id': 12.0,
        'name': 'Test',
        'email': 'test@test.com',
        'body': 'Test body',
      };
      final numComment = Comment.fromJson(numJson);
      expect(numComment.postId, 5);
      expect(numComment.id, 12);
    });

    test('toJson mengembalikan Map yang sesuai', () {
      const comment = Comment(
        postId: 1,
        id: 10,
        name: 'Ani',
        email: 'ani@test.com',
        body: 'Komentar contoh',
      );

      final json = comment.toJson();

      expect(json['postId'], 1);
      expect(json['id'], 10);
      expect(json['name'], 'Ani');
      expect(json['email'], 'ani@test.com');
      expect(json['body'], 'Komentar contoh');
    });
  });
}
