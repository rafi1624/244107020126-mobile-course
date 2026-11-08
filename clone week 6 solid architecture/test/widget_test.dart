import 'package:authentication_security_fcm/domain/repositories/token_repository.dart';
import 'package:authentication_security_fcm/main.dart';
import 'package:authentication_security_fcm/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenRepository implements TokenRepository {
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

void main() {
  testWidgets('App renders login page by default when unauthenticated (Clean Architecture)',
      (WidgetTester tester) async {
    final fakeRepo = FakeTokenRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Pastikan halaman login dan elemen form muncul
    expect(find.text('Autentikasi API Kampus'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Masuk ke Sistem API'), findsOneWidget);
  });
}
