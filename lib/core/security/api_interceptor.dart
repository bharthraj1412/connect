import 'package:dio/dio.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import '../encryption/secure_storage.dart';
import '../config/app_config.dart';
import 'package:logger/logger.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Logger _logger = Logger();

  ApiInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Add auth token if available
      final authToken = await _secureStorage.getAuthToken();
      if (authToken != null && authToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $authToken';
      }
      // Add required headers
      options.headers['Content-Type'] = 'application/json';
      options.headers['X-API-Version'] = '1.0';
      options.headers['User-Agent'] = 'ShareNetEarn/1.0';
      // Add security headers
      options.headers['X-Requested-With'] = 'XMLHttpRequest';
      options.headers['X-Content-Type-Options'] = 'nosniff';
      _logger.i('API Request: ${options.method} ${options.path}');
      return handler.next(options);
    } catch (e) {
      _logger.e('Request interceptor error: $e');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    _logger.i(
        'API Response: ${response.statusCode} ${response.requestOptions.path}');
    // Log suspicious responses
    if (response.statusCode! >= 500) {
      _logger.w('Server error: ${response.statusCode}');
    }
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _logger.e('API Error: ${err.message}');
    // Handle 401 - Token expired
    if (err.response?.statusCode == 401) {
      await _handleTokenExpired();
    }
    return handler.next(err);
  }

  Future<void> _handleTokenExpired() async {
    _logger.w('Auth token expired');
    await _secureStorage.deleteKey('auth_token');
    // Trigger re-login
  }

  /// Verify SSL certificate pinning
  Future<bool> verifySSLCertificatePinning(String url) async {
    try {
      // In production, pin your Firebase certificate
      await HttpCertificatePinning.check(
        serverURL: url,
        headerHttp: {},
        isLocalHost: false,
        pinnedSslCertificate: '''-----BEGIN CERTIFICATE-----
# Firebase SSL Certificate here-----END CERTIFICATE-----
        ''',
        timeout: 30,
      );
      return true;
    } catch (e) {
      _logger.e('SSL Certificate pinning failed: $e');
      return false;
    }
  }
}

/// Configure Dio with security settings
Dio configureDioClient({
  required SecureStorageService secureStorage,
  Duration connectionTimeout = const Duration(seconds: 30),
}) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: connectionTimeout,
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
      validateStatus: (status) => status! < 500,
    ),
  );
  // Add interceptors
  dio.interceptors.add(ApiInterceptor(secureStorage));
  // Add logging interceptor (dev only)
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
    ),
  );
  return dio;
}
