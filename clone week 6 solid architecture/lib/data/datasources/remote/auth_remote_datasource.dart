import 'package:dio/dio.dart';

import '../../../domain/failures/failure.dart';
import '../../models/auth_session_model.dart';
import '../../models/user_profile_model.dart';

abstract class AuthRemoteDataSource {
  String get baseUrl;
  set baseUrl(String url);

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<String> refresh(String refreshToken);

  Future<void> logout();

  Future<UserProfileModel> fetchProfile(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({Dio? dio, String? initialApiKey})
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

  String get defaultBaseUrl => 'https://identitytoolkit.googleapis.com/v1';

  @override
  String get baseUrl => _customBaseUrl ?? defaultBaseUrl;

  @override
  set baseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/$'), '');
  }

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      Response response;
      try {
        // 1. Eksekusi HTTP POST ke endpoint SignIn REST API via Dio
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

        // Jika akun belum ada di REST API, otomatis daftarkan via signUp endpoint
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
            throw _mapDioError(e);
          }
        } else {
          throw _mapDioError(e);
        }
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final session = AuthSessionModel.fromJson(data, fallbackEmail: email);
        if (session.access.isEmpty) {
          throw const AuthFailure('Token akses tidak ditemukan dalam respon REST API.');
        }
        return session;
      }
      throw const ServerFailure('Format respon REST API tidak sesuai spesifikasi.');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<String> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) {
      throw const AuthFailure('Refresh token hilang atau tidak valid.');
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
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    // REST API bersifat stateless
  }

  @override
  Future<UserProfileModel> fetchProfile(String accessToken) async {
    try {
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey',
        data: {
          'idToken': accessToken,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
      }
      return const UserProfileModel();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['error'] != null) {
        final errObj = data['error'];
        final msg = errObj is Map ? errObj['message'] : errObj.toString();
        switch (msg) {
          case 'CONFIGURATION_NOT_FOUND':
            return const AuthFailure(
              'Layanan Authentication belum diaktifkan di Firebase Console! Buka Firebase Console > Security > Authentication > klik "Get Started".',
            );
          case 'EMAIL_NOT_FOUND':
          case 'INVALID_PASSWORD':
          case 'INVALID_LOGIN_CREDENTIALS':
            return const AuthFailure('Email atau kata sandi tidak valid.');
          case 'USER_DISABLED':
            return const AuthFailure('Akun pengguna ini telah dinonaktifkan.');
          case 'WEAK_PASSWORD : Password should be at least 6 characters':
            return const AuthFailure('Kata sandi minimal 6 karakter.');
          case 'EMAIL_EXISTS':
            return const AuthFailure('Email ini sudah terdaftar.');
          case 'TOO_MANY_ATTEMPTS_TRY_LATER':
            return const AuthFailure('Terlalu banyak percobaan gagal. Silakan coba lagi nanti.');
          default:
            return AuthFailure('Error REST API: $msg');
        }
      }
      return ServerFailure('Gagal memproses request (HTTP ${e.response?.statusCode}).');
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Waktu koneksi habis (Timeout ke Cloud REST API). Periksa koneksi internet Anda.',
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Tidak dapat terhubung ke REST API Cloud. Pastikan HP terhubung ke internet.',
        );
      default:
        return NetworkFailure('Terjadi gangguan jaringan: ${e.message ?? 'Unknown error'}');
    }
  }
}
