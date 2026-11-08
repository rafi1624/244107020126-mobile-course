import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/token_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/network/api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/token_repository_impl.dart';
import '../../domain/entities/campus_notification.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/token_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// ==========================================
// DATA LAYER PROVIDERS
// ==========================================

final tokenLocalDataSourceProvider = Provider<TokenLocalDataSource>((ref) {
  return TokenLocalDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final tokenRepositoryProvider = Provider<TokenRepository>((ref) {
  return TokenRepositoryImpl(
    localDataSource: ref.watch(tokenLocalDataSourceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final apiClientProvider = Provider<Dio>((ref) {
  final tokenRepo = ref.watch(tokenRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return buildApiClient(tokenRepo, authRepo);
});

// ==========================================
// DOMAIN USE CASE PROVIDERS
// ==========================================

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  return CheckAuthStatusUseCase(
    tokenRepository: ref.watch(tokenRepositoryProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenRepository: ref.watch(tokenRepositoryProvider),
  );
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenRepository: ref.watch(tokenRepositoryProvider),
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenRepository: ref.watch(tokenRepositoryProvider),
  );
});

// ==========================================
// PRESENTATION STATE NOTIFIERS & PROVIDERS
// ==========================================

final fcmTokenProvider = Provider<String?>((ref) => null);

/// AuthNotifier: Mengelola state login aplikasi via Domain Use Cases
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final checkAuthStatus = ref.watch(checkAuthStatusUseCaseProvider);
    return await checkAuthStatus.execute();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      await loginUseCase.execute(email: email, password: password);
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final logoutUseCase = ref.read(logoutUseCaseProvider);
      await logoutUseCase.execute();
    } catch (_) {}
    state = const AsyncData(false);
  }
}

/// TokenInfo: Data state untuk tampilan dashboard profil keamanan
class TokenInfo {
  const TokenInfo({
    this.accessToken,
    this.refreshToken,
    this.name,
    this.email,
  });

  final String? accessToken;
  final String? refreshToken;
  final String? name;
  final String? email;
}

final tokenInfoProvider = FutureProvider.autoDispose<TokenInfo>((ref) async {
  final tokenRepo = ref.watch(tokenRepositoryProvider);
  final access = await tokenRepo.readAccess();
  final refresh = await tokenRepo.readRefresh();
  final name = await tokenRepo.readName();
  final email = await tokenRepo.readEmail();
  return TokenInfo(
    accessToken: access,
    refreshToken: refresh,
    name: name ?? 'Mahasiswa',
    email: email ?? 'user@kampus.id',
  );
});

/// NotificationNotifier: Mengelola daftar notifikasi kampus
class NotificationNotifier extends Notifier<List<CampusNotification>> {
  @override
  List<CampusNotification> build() {
    return [
      CampusNotification(
        id: 'notif-1',
        title: 'Materi Week 6 Terbit',
        body: 'Materi modul Authentication, Security & FCM sudah diunggah ke sistem.',
        receivedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        route: '/pengumuman/week-6',
      ),
      CampusNotification(
        id: 'notif-2',
        title: 'Pengingat Presensi Kuliah',
        body: 'Silakan isi presensi kehadiran untuk perkuliahan hari ini.',
        receivedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        route: '/pengumuman/presensi',
      ),
      CampusNotification(
        id: 'notif-3',
        title: 'Pengumuman Akademik',
        body: 'Jadwal Ujian Tengah Semester (UTS) telah dirilis.',
        receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
        route: '/pengumuman/uts',
      ),
    ];
  }

  void addNotification(CampusNotification notification) {
    state = [notification, ...state];
  }

  void markAsReadAndRemove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

final notificationListProvider =
    NotifierProvider<NotificationNotifier, List<CampusNotification>>(
  NotificationNotifier.new,
);

