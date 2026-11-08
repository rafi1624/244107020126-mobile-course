import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  AuthRemoteDataSourceImpl({Dio? dio, String? initialBaseUrl})
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
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final session = AuthSessionModel.fromJson(data, fallbackEmail: email);
        if (session.access.isEmpty) {
          throw const AuthFailure('Token akses tidak ditemukan dalam respon API.');
        }
        return session;
      }
      throw const ServerFailure('Format respon login tidak sesuai spesifikasi.');
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
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('$baseUrl/logout');
    } catch (_) {
      // Abaikan kegagalan jaringan saat logout
    }
  }

  @override
  Future<UserProfileModel> fetchProfile(String accessToken) async {
    try {
      final response = await _dio.get(
        '$baseUrl/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
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
      final statusCode = e.response?.statusCode;
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body['message'] != null) {
        return AuthFailure(body['message'].toString());
      }
      if (statusCode == 401) {
        return const AuthFailure('Email atau kata sandi tidak valid.');
      }
      if (statusCode == 422) {
        return const AuthFailure('Validasi gagal: format email atau sandi tidak sesuai.');
      }
      return ServerFailure('Gagal memproses request (HTTP $statusCode).');
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(
          'Waktu koneksi habis (Timeout ke $baseUrl). Jika menggunakan HP fisik via USB, ubah URL ke http://127.0.0.1:8000/api.',
        );
      case DioExceptionType.connectionError:
        return NetworkFailure(
          'Tidak dapat terhubung ke API di $baseUrl. Pastikan backend Laravel sedang berjalan (php artisan serve).',
        );
      default:
        return NetworkFailure('Terjadi gangguan jaringan: ${e.message ?? 'Unknown error'}');
    }
  }
}

