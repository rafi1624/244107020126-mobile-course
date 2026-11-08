import 'package:authentication_security_fcm/data/datasources/remote/auth_remote_datasource.dart';
import 'package:authentication_security_fcm/data/repositories/auth_repository_impl.dart';
import 'package:authentication_security_fcm/domain/entities/auth_session.dart';
import 'package:authentication_security_fcm/domain/repositories/auth_repository.dart';
import 'package:authentication_security_fcm/domain/usecases/login_usecase.dart';
import 'package:authentication_security_fcm/domain/repositories/token_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MockTokenRepository implements TokenRepository {
  String? access;
  String? refresh;
  String? email;
  String? name;

  @override
  Future<void> save({
    required String access,
    required String refresh,
    String? email,
    String? name,
  }) async {
    this.access = access;
    this.refresh = refresh;
    this.email = email;
    this.name = name;
  }

  @override
  Future<String?> readAccess() async => access;
  @override
  Future<String?> readRefresh() async => refresh;
  @override
  Future<String?> readEmail() async => email;
  @override
  Future<String?> readName() async => name;
  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    email = null;
    name = null;
  }
}

class FakeAuthRepository implements AuthRepository {
  String _baseUrl = 'http://127.0.0.1:8000/api';

  @override
  String get baseUrl => _baseUrl;

  @override
  set baseUrl(String url) => _baseUrl = url;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    return const AuthSession(
      access: 'fake_access_123',
      refresh: 'fake_refresh_456',
      userName: 'Test User',
      userEmail: 'test@example.com',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async => 'fake_access_renewed';

  @override
  Future<void> logout() async {}

  @override
  Future<dynamic> fetchProfile(String accessToken) async {
    throw UnimplementedError();
  }
}

void main() {
  group('Clean Architecture - Domain & Data Layer Unit Tests', () {
    test('AuthRemoteDataSource and AuthRepositoryImpl manage baseUrl correctly', () {
      final remoteSource = AuthRemoteDataSourceImpl();
      final AuthRepository repo = AuthRepositoryImpl(remoteDataSource: remoteSource);

      expect(repo.baseUrl, isNotEmpty);
      expect(repo.baseUrl.startsWith('http'), isTrue);

      repo.baseUrl = 'http://my-campus-api.com/api/';
      expect(repo.baseUrl, equals('http://my-campus-api.com/api'));
    });

    test('Domain Entity AuthSession contains expected values', () {
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

    test('Domain LoginUseCase executes login and saves token to TokenRepository', () async {
      final fakeAuthRepo = FakeAuthRepository();
      final mockTokenRepo = MockTokenRepository();

      final useCase = LoginUseCase(
        authRepository: fakeAuthRepo,
        tokenRepository: mockTokenRepo,
      );

      final result = await useCase.execute(
        email: 'test@example.com',
        password: 'password',
      );

      expect(result.access, equals('fake_access_123'));
      expect(mockTokenRepo.access, equals('fake_access_123'));
      expect(mockTokenRepo.refresh, equals('fake_refresh_456'));
      expect(mockTokenRepo.userEmail, equals('test@example.com'));
    });
  });
}
