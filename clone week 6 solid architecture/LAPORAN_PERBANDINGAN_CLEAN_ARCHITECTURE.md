# Laporan Perbandingan Arsitektur: Week 6 Awal (Folder `JS`) vs Clean Architecture (Folder `clone`)

---

## 1. Ringkasan Eksekutif

Laporan ini menyajikan analisis komparatif menyeluruh antara implementasi awal **Week 6 (Authentication, Security & FCM)** yang berada di folder `JS` dengan implementasi **Clean Architecture** yang telah diterapkan pada folder `clone` (`06-week-6-authentication-security-fcm-clone`).

Refaktorisasi ini didasarkan pada materi kuliah mengenai **Clean Architecture** dan **Prinsip SOLID dalam Flutter**, dengan mematuhi aturan baku:
1. **Dependency Rule**: Arah dependensi mutlak mengarah ke dalam (**Presentation** $\rightarrow$ **Domain** $\leftarrow$ **Data**).
2. **Domain Purity**: Domain layer ditulis dalam **Dart murni (pure Dart)** tanpa ketergantungan pada Flutter SDK, Dio, SQLite, Firebase, atau pustaka eksternal lainnya.
3. **Pemisahan Tanggung Jawab (*Separation of Concerns*)**: Menghilangkan ketergantungan langsung widget UI terhadap pustaka jaringan (*network client*) dan pustaka penyimpanan perangkat keras.

---

## 2. Perbandingan Struktur Folder dan Berkas

### 2.1 Struktur Week 6 Awal (`JS/.../06-week-6-authentication-security-fcm`)
```
lib/
├── data/
│   ├── api_client.dart           <-- Dio client & refresh token interceptor
│   ├── auth_provider.dart        <-- Riverpod notifier + GoRouter (impor pages/)
│   ├── auth_repository.dart      <-- Dio network call langsung (tanpa interface)
│   ├── notification_provider.dart<-- Entity + StateNotifier bercampur di data/
│   └── token_store.dart          <-- FlutterSecureStorage langsung tanpa kontrak
├── messaging/
│   └── push_service.dart
├── pages/
│   ├── announcement_page.dart
│   ├── home_page.dart            <-- UI 907 baris, panggil Dio & Local Notification langsung
│   └── login_page.dart
└── main.dart
```

### 2.2 Struktur Clean Architecture Baru (`clone/...-clone`)
```
lib/
├── domain/                                  <-- LAYER DOMAIN (Pure Dart)
│   ├── entities/
│   │   ├── auth_session.dart                <-- Entity murni sesi login
│   │   ├── campus_notification.dart         <-- Entity murni notifikasi kampus
│   │   └── user_profile.dart                <-- Entity murni profil user
│   ├── failures/
│   │   └── failure.dart                     <-- Kelas Failure bisnis terstandar
│   ├── repositories/                        <-- Kontrak Interface / Abstraksi
│   │   ├── auth_repository.dart             <-- Abstract class AuthRepository
│   │   └── token_repository.dart            <-- Abstract class TokenRepository
│   └── usecases/                            <-- Logika Bisnis Aplikasi
│       ├── check_auth_status_usecase.dart   <-- Cek token aktif
│       ├── get_profile_usecase.dart         <-- Ambil data profil (/me)
│       ├── login_usecase.dart               <-- Eksekusi login & simpan token
│       └── logout_usecase.dart              <-- Eksekusi logout & pembersihan token
│
├── data/                                    <-- LAYER DATA (Implementasi & Pustaka Luar)
│   ├── datasources/
│   │   ├── local/
│   │   │   └── token_local_datasource.dart  <-- Pembungkus FlutterSecureStorage
│   │   └── remote/
│   │       └── auth_remote_datasource.dart  <-- Pemanggilan Dio & penanganan error HTTP
│   ├── models/
│   │   ├── auth_session_model.dart          <-- Mapping JSON login API ke Entity
│   │   └── user_profile_model.dart          <-- Mapping JSON profil ke Entity
│   ├── network/
│   │   └── api_client.dart                  <-- Konfigurasi Dio & Auto Bearer Interceptor
│   └── repositories/
│       ├── auth_repository_impl.dart        <-- Implementasi kontrak AuthRepository
│       └── token_repository_impl.dart       <-- Implementasi kontrak TokenRepository
│
├── presentation/                            <-- LAYER PRESENTATION (UI & State)
│   ├── pages/
│   │   ├── announcement_page.dart           <-- Tampilan detail pengumuman
│   │   ├── home_page.dart                   <-- Tampilan Dashboard (Bebas Dio!)
│   │   └── login_page.dart                  <-- Tampilan Form Login
│   └── providers/
│       ├── app_providers.dart               <-- Wiring DI Riverpod & Notifier
│       └── router_provider.dart             <-- GoRouter terisolasi dengan Auth Guard
│
├── messaging/
│   └── push_service.dart                    <-- Service background push FCM
└── main.dart                                <-- Inisialisasi & Composition Root
```

---

## 3. Analisis Pelanggaran pada Week 6 Awal (Folder `JS`)

| No | Gejala / Pelanggaran | Lokasi Berkas di `JS` | Dampak Negatif |
| :---: | :--- | :--- | :--- |
| **1** | **Presentation mengenal Dio & JSON mentah** | `lib/pages/home_page.dart` (baris 67-75) | Widget memanggil `final dio = ref.read(apiClientProvider); await dio.get('/me')`. Pelanggaran langsung terhadap aturan *"Presentation tidak boleh mengenal Dio/JSON mentah"*. Jika endpoint berubah atau Dio diganti Http, UI ikut rusak. |
| **2** | **Ketiadaan Layer Domain** | Seluruh proyek di `JS` | Tidak ada pemisahan antara entitas bisnis murni dan data model. Logika bisnis melekat pada dependensi pihak ketiga (*tight coupling*). |
| **3** | **Pelanggaran Arah Dependensi (*Circular Dependency Pattern*)** | `lib/data/auth_provider.dart` (baris 6-8) | Berkas di dalam folder `data/` mengimpor berkas di dalam `pages/` (`import '../pages/home_page.dart'`). Data layer semestinya **tidak boleh mengetahui apa pun tentang Presentation**. |
| **4** | **Repository tanpa Abstraksi (Pelanggaran DIP)** | `lib/data/auth_repository.dart` | `AuthRepository` dibuat sebagai kelas konkrit yang langsung memegang `Dio`. Klien tidak bergantung pada abstraksi melainkan pada pustaka Dio secara langsung. |
| **5** | **Widget God-Object (Pelanggaran SRP)** | `lib/pages/home_page.dart` (>900 baris) | Satu file widget mengurusi rendering UI, HTTP request manual, dialog rendering, local notification trigger manual, dan parsing format data. |

---

## 4. Perbandingan Kode Konkrit (*Before vs After*)

### 4.1 Pemanggilan API pada Halaman Dashboard (`home_page.dart`)

#### ❌ Sebelum (Folder `JS`):
```dart
// lib/pages/home_page.dart
// Pelanggaran: Widget mengimpor Dio dan menangani HTTP response langsung!
Future<void> _testProtectedApi() async {
  setState(() => _isTestingApi = true);
  try {
    final dio = ref.read(apiClientProvider); // <-- Langsung memanggil Dio!
    final response = await dio.get('/me');   // <-- HTTP mentah di dalam Widget!
    setState(() {
      _apiTestResult = 'HTTP ${response.statusCode}: ${response.data}';
      _isTestingApi = false;
    });
  } catch (e) {
    setState(() => _apiTestResult = 'Gagal memanggil API: $e');
  }
}
```

#### ✅ Sesudah (Folder `clone`):
```dart
// lib/presentation/pages/home_page.dart
// Bersih: Widget hanya memanggil Domain UseCase dan menerima Domain Entity!
Future<void> _testProtectedApi() async {
  setState(() => _isTestingApi = true);
  try {
    // Memanggil UseCase domain: Bebas dari import dio, http, atau json parsing
    final UserProfile profile = await ref.read(getProfileUseCaseProvider).execute();
    setState(() {
      _apiTestResult = 'Profil Diterima dari UseCase:\n'
          'Nama: ${profile.name}\nEmail: ${profile.email}';
      _isTestingApi = false;
    });
  } catch (e) {
    setState(() => _apiTestResult = 'Gagal memanggil API: $e');
  }
}
```

---

### 4.2 Abstraksi Repository & Dependency Inversion

#### ❌ Sebelum (Folder `JS`):
```dart
// lib/data/auth_repository.dart
// Kelas konkrit langsung; menyatukan HTTP call, parsing, dan bisnis logic
class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  Future<AuthSession> login({required String email, required String password}) async {
    final response = await _dio.post('/login', data: {...});
    // Parsing manual di dalam repository konkrit
  }
}
```

#### ✅ Sesudah (Folder `clone`):
```dart
// 1. KONTRAK ABSTRAKSI (lib/domain/repositories/auth_repository.dart) - Pure Dart
abstract class AuthRepository {
  String get baseUrl;
  set baseUrl(String url);
  Future<AuthSession> login({required String email, required String password});
  Future<String> refresh(String refreshToken);
  Future<void> logout();
  Future<UserProfile> fetchProfile(String accessToken);
}

// 2. IMPLEMENTASI KONTRAK (lib/data/repositories/auth_repository_impl.dart)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return _remoteDataSource.login(email: email, password: password);
  }
  // ...
}
```

---

### 4.3 Logika Autentikasi dan Notifier State Management

#### ❌ Sebelum (Folder `JS`):
```dart
// lib/data/auth_provider.dart
// Notifier bertanggung jawab mengorkestrasi repository konkrit dan token store
class AuthNotifier extends AsyncNotifier<bool> {
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final session = await ref.read(authRepositoryProvider).login(email: email, password: password);
    await ref.read(tokenStoreProvider).save(
      access: session.access,
      refresh: session.refresh,
    );
    state = const AsyncData(true);
  }
}
```

#### ✅ Sesudah (Folder `clone`):
```dart
// 1. USE CASE DI LAYER DOMAIN (lib/domain/usecases/login_usecase.dart)
class LoginUseCase {
  const LoginUseCase({
    required AuthRepository authRepository,
    required TokenRepository tokenRepository,
  }) : _authRepository = authRepository,
       _tokenRepository = tokenRepository;

  final AuthRepository _authRepository;
  final TokenRepository _tokenRepository;

  Future<AuthSession> execute({required String email, required String password}) async {
    final session = await _authRepository.login(email: email, password: password);
    await _tokenRepository.save(
      access: session.access,
      refresh: session.refresh,
      email: session.userEmail ?? email,
      name: session.userName,
    );
    return session;
  }
}

// 2. NOTIFIER DI LAYER PRESENTATION (lib/presentation/providers/app_providers.dart)
// Notifier kini hanya mendelegasikan perintah ke UseCase domain!
class AuthNotifier extends AsyncNotifier<bool> {
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(loginUseCaseProvider).execute(email: email, password: password);
      state = const AsyncData(true);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
```

---

## 5. Evaluasi Berdasarkan 5 Prinsip SOLID

```
+--------------------------------------------------------------------------------------------------+
| Prinsip SOLID         | Kondisi di Week 6 Awal (JS)             | Hasil Refactoring (clone)      |
+-----------------------+-----------------------------------------+--------------------------------+
| Single Responsibility | home_page.dart (>900 baris) mencampur   | UI hanya mengurus tampilan,    |
| (SRP)                 | logika HTTP, navigasi, dan rendering.   | UseCase mengurus alur bisnis,  |
|                       | Data layer mengurus routing UI.         | DataSource mengurus I/O.       |
+-----------------------+-----------------------------------------+--------------------------------+
| Open / Closed         | Menambah jenis storage baru (mis. Hive/ | Tambah datasource baru tanpa   |
| (OCP)                 | SharedPrefs) mengharuskan mengubah      | mengubah Domain UseCase atau   |
|                       | token_store.dart dan seluruh kliennya.  | Widget Presentation.           |
+-----------------------+-----------------------------------------+--------------------------------+
| Liskov Substitution   | Repository palsu sulit dibuat karena    | Semua implementasi dan fake    |
| (LSP)                 | tidak ada kontrak interface seragam.    | repository mematuhi kontrak    |
|                       |                                         | interface Domain yang sama.    |
+-----------------------+-----------------------------------------+--------------------------------+
| Interface Segregation | Satu file auth_repository konkrit       | Kontrak dipisah sesuai domain: |
| (ISP)                 | menampung segala hal tanpa pemisahan.   | AuthRepository &               |
|                       |                                         | TokenRepository mandiri.       |
+-----------------------+-----------------------------------------+--------------------------------+
| Dependency Inversion  | Widget dan Notifier bergantung langsung | Presentation hanya bergantung  |
| (DIP)                 | pada kelas konkret (Dio &               | pada abstraksi Use Case dan    |
|                       | FlutterSecureStorage).                  | Repository Interface.          |
+-----------------------+-----------------------------------------+--------------------------------+
```

---

## 6. Perbandingan Aspek Pengujian (*Testability*)

| Parameter Pengujian | Week 6 di Folder `JS` | Implementasi Clean Architecture di Folder `clone` |
| :--- | :--- | :--- |
| **Kebutuhan Emulator / Perangkat** | Logika bisnis sulit diuji tanpa mock HTTP adapter Dio dan dependensi native platform storage. | Logika bisnis di `domain/usecases/` diuji dengan **Pure Dart**; jalan dalam hitungan milidetik tanpa emulator atau platform channel. |
| **Mocking Dependensi** | Mengharuskan mocking instance pustaka `Dio` secara rumit. | Cukup membuat kelas sederhana yang mengimplementasikan interface `AuthRepository` atau `TokenRepository` (`FakeAuthRepository`, `MockTokenRepository`). |
| **Widget Testing** | Widget test rentan gagal karena dependensi jaringan yang terikat erat di dalam body widget. | Widget test dapat dengan mudah meng-override provider abstraksi (`tokenRepositoryProvider.overrideWithValue(...)`). |

---

## 7. Kesimpulan

Penerapan Clean Architecture pada folder `clone`:
1. **Memutus Ketergantungan Terlarang**: Tidak ada lagi widget yang mengenal `Dio`, `JSON mentah`, atau detail `FlutterSecureStorage`.
2. **Menjaga Kemurnian Domain**: Layer Domain sepenuhnya murni Dart sehingga aman dari perubahan teknologi framework/pustaka luar.
3. **Meningkatkan Skalabilitas & Kemudahan Pemeliharaan**: Kode tersusun modular dengan tanggung jawab terisolasi (*single responsibility*), mempermudah kerja tim dalam skala besar.
4. **Keutuhan Arsip Asli**: Seluruh berkas di folder `JS` tetap dipertahankan tanpa modifikasi sedikit pun sebagai pembanding autentik.
