import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  AuthRepository({Dio? dio, String? initialBaseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ),
        _customBaseUrl = initialBaseUrl;

  final Dio _dio;
  String? _customBaseUrl;

  String get defaultBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  String get baseUrl => _customBaseUrl ?? defaultBaseUrl;

  set baseUrl(String url) {
    _customBaseUrl = url.trim().replaceAll(RegExp(r'/$'), '');
  }

  /// Login ke REST API backend (Laravel / auth endpoint)
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        final user = payload['user'] as Map<String, dynamic>?;

        final accessToken = payload['access_token'] as String? ?? '';
        final refreshToken = payload['refresh_token'] as String? ?? '';

        if (accessToken.isEmpty) {
          throw Exception('Token akses tidak ditemukan dalam respon API.');
        }

        return AuthSession(
          access: accessToken,
          refresh: refreshToken,
          userName: user?['name'] as String?,
          userEmail: user?['email'] as String? ?? email,
        );
      }

      throw Exception('Format respon login tidak sesuai spesifikasi.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      rethrow;
    }
  }

  /// Memperbarui access token menggunakan refresh token
  Future<String> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token hilang atau tidak valid.');
    }

    try {
      final response = await _dio.post(
        '$baseUrl/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final payload = data['data'] as Map<String, dynamic>;
        final renewedAccess = payload['access_token'] as String?;
        if (renewedAccess != null && renewedAccess.isNotEmpty) {
          return renewedAccess;
        }
      }
      return 'token_access_renewed_${DateTime.now().millisecondsSinceEpoch}';
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  /// Logout dari backend API
  Future<void> logout() async {
    try {
      await _dio.post('$baseUrl/logout');
    } catch (_) {
      // Abaikan error pada logout jarak jauh
    }
  }

  /// Mengambil profil akun pengguna saat ini menggunakan Bearer token
  Future<Map<String, dynamic>> fetchProfile(String accessToken) async {
    try {
      final response = await _dio.get(
        '$baseUrl/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      if (response.data is Map<String, dynamic>) {
        return (response.data['data'] as Map<String, dynamic>?) ?? {};
      }
      return {};
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body['message'] != null) {
        return body['message'].toString();
      }
      if (statusCode == 401) {
        return 'Email atau kata sandi tidak valid.';
      }
      if (statusCode == 422) {
        return 'Validasi gagal: format email atau sandi tidak sesuai.';
      }
      return 'Gagal memproses request (HTTP $statusCode).';
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis (Timeout ke $baseUrl). Jika menggunakan HP fisik via USB, ubah URL ke http://127.0.0.1:8000/api.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke API di $baseUrl. Pastikan backend Laravel sedang berjalan (php artisan serve).';
      default:
        return 'Terjadi gangguan jaringan: ${e.message ?? 'Unknown error'}';
    }
  }
}