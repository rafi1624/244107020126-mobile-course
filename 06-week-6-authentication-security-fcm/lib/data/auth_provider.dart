import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/announcement_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import 'api_client.dart';
import 'auth_repository.dart';
import 'token_store.dart';

// Provider untuk TokenStore (FlutterSecureStorage)
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

// Provider untuk AuthRepository (panggilan login, refresh, logout ke API)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provider untuk Dio Client terpusat dengan Auto Bearer Token dan Refresh Interceptor
final apiClientProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);
  final auth = ref.watch(authRepositoryProvider);
  return buildApiClient(store, auth);
});

// Provider untuk menampung token FCM (dapat dioverride di ProviderScope)
final fcmTokenProvider = Provider<String?>((ref) => null);

// Notifier status autentikasi berbasis Riverpod AsyncNotifier
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null && token.isNotEmpty;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);

      await ref.read(tokenStoreProvider).save(
            access: session.access,
            refresh: session.refresh,
            email: session.userEmail ?? email,
            name: session.userName,
          );

      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}

// RouterNotifier untuk memicu re-evaluasi route GoRouter saat state auth berubah
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<AsyncValue<bool>>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref ref;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

// GoRouter Provider terintegrasi dengan Auth State Guard
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final loggedIn = authState.value ?? false;
      final goingLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) => AnnouncementPage(
          id: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
});