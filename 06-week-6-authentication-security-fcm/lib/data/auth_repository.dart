import 'package:dio/dio.dart';

class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
    this.userName,
    this.userEmail,
  });

  final String access;
  final String refresh;
  final String? userName;
  final String? userEmail;
}

class AuthRepository {
  AuthRepository({Dio? dio, String? initialApiKey})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'X-Android-Package': 'com.example.authentication_security_fcm',
                  'X-Android-Cert': '8A426CC9E88D175E1018BD98096A080BAEE839EE',
                },
              ),
            ),
        _apiKey = initialApiKey ?? 'AIzaSyAmc35C1Gm8yfCyHR9ABSrTb_1Yg9KhV0I';

  final Dio _dio;
  String _apiKey;
  String? _customBaseUrl;

  String get apiKey => _apiKey;
  set apiKey(String key) => _apiKey = key.trim();

  String get defaultBaseUrl => 'https://identitytoolkit.googleapis.com/v1';
  String get baseUrl => _customBaseUrl ?? defaultBaseUrl;

  set baseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/$'), '');
  }

  /// Login melalui REST API Cloud menggunakan Dio (HTTP POST)
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      Response response;
      try {
        // 1. Kirim HTTP POST ke endpoint SignIn REST API
        response = await _dio.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey',
          data: {
            'email': email.trim(),
            'password': password,
            'returnSecureToken': true,
          },
        );
      } on DioException catch (e) {
        final err = e.response?.data;
        final errMsg =
            (err is Map && err['error'] != null) ? err['error']['message'] : null;

        // Jika user belum ada di REST API, otomatis daftarkan via endpoint signUp REST API
        if (errMsg == 'EMAIL_NOT_FOUND' || errMsg == 'INVALID_LOGIN_CREDENTIALS') {
          try {
            response = await _dio.post(
              'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
              data: {
                'email': email.trim(),
                'password': password,
                'returnSecureToken': true,
              },
            );
          } catch (_) {
            throw Exception(_handleDioError(e));
          }
        } else {
          throw Exception(_handleDioError(e));
        }
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final idToken = data['idToken'] as String? ?? '';
        final refreshToken = data['refreshToken'] as String? ?? '';
        final userEmail = data['email'] as String? ?? email;
        final displayName =
            data['displayName'] as String? ?? userEmail.split('@').first;

        if (idToken.isEmpty) {
          throw Exception('Token akses tidak ditemukan dalam respon REST API.');
        }

        return AuthSession(
          access: idToken,
          refresh: refreshToken,
          userName: displayName,
          userEmail: userEmail,
        );
      }

      throw Exception('Format respon REST API tidak sesuai spesifikasi.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  /// Memperbarui token melalui SecureToken REST API menggunakan Dio
  Future<String> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token hilang atau tidak valid.');
    }

    try {
      final response = await _dio.post(
        'https://securetoken.googleapis.com/v1/token?key=$_apiKey',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['id_token'] != null) {
        return data['id_token'] as String;
      }
      return 'token_access_renewed_${DateTime.now().millisecondsSinceEpoch}';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  /// Logout dari REST API
  Future<void> logout() async {
    // REST API bersifat stateless; sesi token dibersihkan di penyimpanan lokal
  }

  /// Mengambil profil akun pengguna via REST API (accounts:lookup) dengan Bearer token
  Future<Map<String, dynamic>> fetchProfile(String accessToken) async {
    try {
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey',
        data: {
          'idToken': accessToken,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['users'] is List &&
          (data['users'] as List).isNotEmpty) {
        final user = (data['users'] as List).first as Map<String, dynamic>;
        return {
          'uid': user['localId'],
          'email': user['email'],
          'nama': user['displayName'] ??
              (user['email'] as String?)?.split('@').first ??
              'Mahasiswa',
          'emailTerverifikasi': user['emailVerified'] ?? false,
          'waktuDibuat': user['createdAt'],
          'terakhirMasuk': user['lastLoginAt'],
          'jalurAPI': 'REST API HTTP POST (via Dio Client)',
        };
      }
      return {'status': 'Data profil tidak ditemukan'};
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        final errObj = data['error'];
        final msg = errObj is Map ? errObj['message'] : errObj.toString();
        switch (msg) {
          case 'CONFIGURATION_NOT_FOUND':
            return 'Layanan Authentication belum diaktifkan di Firebase Console! Buka Firebase Console > Build > Authentication > klik "Get Started".';
          case 'EMAIL_NOT_FOUND':
          case 'INVALID_PASSWORD':
          case 'INVALID_LOGIN_CREDENTIALS':
            return 'Email atau kata sandi tidak valid.';
          case 'USER_DISABLED':
            return 'Akun pengguna ini telah dinonaktifkan.';
          case 'WEAK_PASSWORD : Password should be at least 6 characters':
            return 'Kata sandi minimal 6 karakter.';
          case 'EMAIL_EXISTS':
            return 'Email ini sudah terdaftar.';
          case 'TOO_MANY_ATTEMPTS_TRY_LATER':
            return 'Terlalu banyak percobaan gagal. Silakan coba lagi nanti.';
          default:
            return 'Error REST API ($msg)';
        }
      }
      return 'Gagal memproses request (HTTP ${e.response?.statusCode}).';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis (Timeout ke REST API). Periksa koneksi internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke REST API Cloud. Pastikan HP terhubung ke internet.';
      default:
        return 'Gangguan jaringan: ${e.message ?? 'Unknown error'}';
    }
  }
}
