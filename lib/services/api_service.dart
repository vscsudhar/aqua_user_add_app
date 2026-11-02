import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../app/app.locator.dart';
import 'storage_service.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final dynamic errors;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.errors,
  });
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}

class ApiService {
  final StorageService _storageService;
  late final Dio _dio;

  VoidCallback? onUnauthorized;

  static String resolveDefaultBaseUrl() {
    const envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost') {
        return 'http://$host:8000/api/v1';
      }
    }

    // Default to current machine Wi-Fi IP so connected mobile devices and network clients can connect
    return 'http://192.168.0.174:8000/api/v1';
  }

  ApiService([StorageService? storageService])
      : _storageService = storageService ?? locator<StorageService>() {
    final baseUrl = resolveDefaultBaseUrl();

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  String get baseUrl => _dio.options.baseUrl;

  void setBaseUrl(String url) {
    var formatted = url.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'http://$formatted';
    }
    if (!formatted.endsWith('/api/v1')) {
      if (formatted.endsWith('/')) {
        formatted = '${formatted}api/v1';
      } else {
        formatted = '$formatted/api/v1';
      }
    }
    _dio.options.baseUrl = formatted;
  }

  Future<void> init() async {
    final savedUrl = await _storageService.getBaseUrl();
    if (savedUrl != null && savedUrl.trim().isNotEmpty) {
      setBaseUrl(savedUrl);
    }
  }

  Future<void> updateAndSaveBaseUrl(String newUrl) async {
    setBaseUrl(newUrl);
    await _storageService.saveBaseUrl(_dio.options.baseUrl);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? fromData,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromData);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? fromData,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse<T>(response, fromData);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? fromData,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse<T>(response, fromData);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? fromData,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse<T>(response, fromData);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? fromData,
  }) async {
    try {
      final response = await _dio.delete(path, data: data);
      return _handleResponse<T>(response, fromData);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic data)? fromData,
  ) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final isSuccess = body['status'] == 'success' || (response.statusCode != null && response.statusCode! < 300);
      final message = body['message'] as String? ?? '';
      final rawData = body['data'];

      return ApiResponse<T>(
        isSuccess: isSuccess,
        message: message,
        data: rawData != null && fromData != null ? fromData(rawData) : rawData as T?,
        errors: body['errors'],
      );
    }

    return ApiResponse<T>(
      isSuccess: response.statusCode != null && response.statusCode! < 300,
      message: 'Success',
      data: fromData != null ? fromData(body) : body as T?,
    );
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    String message = 'A network error occurred. Please try again.';
    dynamic errors;

    if (e.response?.data is Map<String, dynamic>) {
      final body = e.response!.data as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
      errors = body['errors'];
    } else if (e.message != null && e.message!.isNotEmpty) {
      message = e.message!;
    }

    throw ApiException(
      message: message,
      statusCode: e.response?.statusCode,
      errors: errors,
    );
  }
}
