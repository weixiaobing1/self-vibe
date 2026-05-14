import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();

  /// Global callback for non-401 network errors (set from UI layer)
  static void Function(String message)? onNetworkError;

  factory ApiService() => _instance;

  ApiService._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final token = await _storage.read(key: 'accessToken');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final retryResponse = await dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
        // Notify UI of network errors (except 401 which is handled above)
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          onNetworkError?.call('网络连接失败，请检查网络后重试');
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: ApiConfig.baseUrl))
          .post('/api/user/refresh-token', data: {'refreshToken': refreshToken});

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> saveToken(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  /// Extract a human-readable error message from a [DioException].
  /// Backend returns JSON: {"code": N, "message": "中文错误信息", "data": null}
  static String extractError(DioException e) {
    // Try to parse the backend's JSON error response
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'];
    }

    // Fallback for connection-level errors
    switch (e.type) {
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络后重试';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return '请求超时，请重试';
      default:
        break;
    }

    // Fallback based on HTTP status code
    final code = e.response?.statusCode;
    if (code == 401) return '登录已过期，请重新登录';
    if (code == 403) return '无权限访问';
    if (code == 404) return '请求的资源不存在';
    if (code != null && code >= 500) return '服务器内部错误，请稍后重试';

    return '网络错误，请重试';
  }
}