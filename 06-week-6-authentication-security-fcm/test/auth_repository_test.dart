import 'package:authentication_security_fcm/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository Unit Test', () {
    test('defaultBaseUrl returns valid URI', () {
      final repo = AuthRepository();
      expect(repo.baseUrl, isNotEmpty);
      expect(repo.baseUrl.startsWith('http'), isTrue);
    });

    test('customBaseUrl setter trims trailing slash', () {
      final repo = AuthRepository();
      repo.baseUrl = 'http://my-campus-api.com/api/';
      expect(repo.baseUrl, equals('http://my-campus-api.com/api'));
    });

    test('AuthSession contains access and refresh token', () {
      const session = AuthSession(
        access: 'test_access_token',
        refresh: 'test_refresh_token',
        userName: 'Budi',
        userEmail: 'budi@kampus.id',
      );

      expect(session.access, 'test_access_token');
      expect(session.refresh, 'test_refresh_token');
      expect(session.userName, 'Budi');
      expect(session.userEmail, 'budi@kampus.id');
    });
  });
}
