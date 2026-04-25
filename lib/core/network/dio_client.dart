/// Dio Client
/// HTTP Client configuration with Interceptors for Auth and Logging
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'network_exceptions.dart';

class DioClient {
  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }
  final SecureStorageService _storage;
  late final Dio _dio;

  // --- Interceptors ---

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      print('🌐 [DIO REQUEST] ${options.method} ${options.path}');
      // print('Headers: ${options.headers}');
      // print('Body: ${options.data}');
    }

    return handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      print(
          '✅ [DIO RESPONSE] ${response.statusCode} - ${response.requestOptions.path}');
    }
    return handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      print('❌ [DIO ERROR] ${err.type} : ${err.message}');
      print('Response: ${err.response?.data}');
    }

    // Handle 401 Unauthorized globally
    if (err.response?.statusCode == 401) {
      // Clear token via storage
      await _storage.clear();
      // Logic to redirect to Login should be handled by watching auth state in Router
      // Here we just ensure local data is cleared so next check fails
    }

    // Transform DioException to custom NetworkException
    // We forward the error to be handled by the repository
    return handler.next(err);
  }

  // Public Getters
  Dio get dio => _dio;

  // --- HTTP Methods Helpers (Optional, or access dio directly) ---

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  NetworkException _handleDioError(DioException error) {
    var message = 'Une erreur inconnue est survenue';
    var statusCode = error.response?.statusCode;

    // Attempt to extract error message from backend response
    if (error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      if (data.containsKey('detail')) {
        message = data['detail'].toString();
      } else if (data.containsKey('message')) {
        message = data['message'].toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.cancel:
        return NetworkException('Requête annulée', statusCode: statusCode);
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException("Délai d'attente dépassé",
            statusCode: statusCode);
      case DioExceptionType.connectionError:
        return NoInternetException('Pas de connexion internet');
      case DioExceptionType.badResponse:
        switch (statusCode) {
          case 400:
            return BadRequestException(message, statusCode: statusCode);
          case 401:
          case 403:
            return UnauthorizedException(message, statusCode: statusCode);
          case 404:
            return NotFoundException('Ressource non trouvée',
                statusCode: statusCode);
          case 409:
            return NetworkException('Conflit: $message',
                statusCode: statusCode);
          case 500:
          case 502:
          case 503:
            return ServerException('Erreur serveur interne',
                statusCode: statusCode);
          default:
            return NetworkException('Erreur HTTP: $statusCode - $message',
                statusCode: statusCode);
        }
      case DioExceptionType.unknown:
        if (error.message != null &&
            error.message!.contains('SocketException')) {
          return NoInternetException('Pas de connexion internet');
        }
        return NetworkException('Erreur inattendue', statusCode: statusCode);
      default:
        return NetworkException('Erreur réseau générique',
            statusCode: statusCode);
    }
  }
}
