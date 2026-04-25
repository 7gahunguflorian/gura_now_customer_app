/// Dio-based API client used by the Clean Architecture data layer.
///
/// Wraps [DioClient] so that data sources follow the docs (Dio, not http):
///
/// - Methods return decoded `Map<String, dynamic>` JSON.
/// - Errors use `core/errors/exceptions.dart` (ServerException, etc).
///
/// See docs/ARCHITECTURE_GUIDE.md – API Client (Dio).

import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../errors/exceptions.dart' as core_exceptions;
import 'dio_client.dart';
import 'network_exceptions.dart' as net_exceptions;

class ApiClient {
  ApiClient(this._dioClient);

  final DioClient _dioClient;

  /// GET request.
  ///
  /// [path] should be a relative path like `/auth/login` (see `ApiEndpoints`).
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        path,
        queryParameters: queryParams,
        options: _mergeOptions(options),
      );
      return _decodeJson(response);
    } on net_exceptions.NetworkException catch (e) {
      throw _mapNetworkException(e);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST request with JSON body.
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        path,
        data: body,
        queryParameters: queryParams,
        options: _mergeOptions(options),
      );
      return _decodeJson(response);
    } on net_exceptions.NetworkException catch (e) {
      throw _mapNetworkException(e);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PUT request with JSON body.
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        path,
        data: body,
        queryParameters: queryParams,
        options: _mergeOptions(options),
      );
      return _decodeJson(response);
    } on net_exceptions.NetworkException catch (e) {
      throw _mapNetworkException(e);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PATCH request with optional JSON body.
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        path,
        data: body,
        queryParameters: queryParams,
        options: _mergeOptions(options),
      );
      return _decodeJson(response);
    } on net_exceptions.NetworkException catch (e) {
      throw _mapNetworkException(e);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST request with multipart form data (for file uploads).
  Future<Map<String, dynamic>> postMultipart(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final mergedOptions = _mergeOptions(options);
      final finalOptions = mergedOptions.copyWith(
        contentType: 'multipart/form-data',
      );
      final response = await _dioClient.dio.post(
        path,
        data: formData,
        queryParameters: queryParams,
        options: finalOptions,
      );
      return _decodeJson(response);
    } on net_exceptions.NetworkException catch (e) {
      throw _mapNetworkException(e);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// DELETE request.
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dioClient.dio.delete(
        path,
        queryParameters: queryParams,
        options: _mergeOptions(options),
      );
      return _decodeJson(response);
    } on net_exceptions.NetworkException catch (e) {
      throw _mapNetworkException(e);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  // ═════════════════════════════════════════════════════════════════
  // Helpers
  // ═════════════════════════════════════════════════════════════════

  Options _mergeOptions(Options? options) {
    final base = Options(
      sendTimeout: ApiConfig.sendTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: ApiConfig.defaultHeaders,
    );

    if (options == null) return base;

    return base.copyWith(
      method: options.method,
      sendTimeout: options.sendTimeout,
      receiveTimeout: options.receiveTimeout,
      headers: {
        ...?base.headers,
        ...?options.headers,
      },
      responseType: options.responseType,
      contentType: options.contentType,
      validateStatus: options.validateStatus,
      followRedirects: options.followRedirects,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError,
      extra: {
        ...?base.extra,
        ...?options.extra,
      },
    );
  }

  Map<String, dynamic> _decodeJson(Response response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        // fall through to generic error
      }
    }

    // Fallback: wrap non-map payloads
    return <String, dynamic>{
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  core_exceptions.ServerException _mapNetworkException(
    net_exceptions.NetworkException e,
  ) {
    final statusCode = e.statusCode;

    if (e is net_exceptions.BadRequestException) {
      return core_exceptions.BadRequestException(e.message);
    }
    if (e is net_exceptions.UnauthorizedException) {
      return core_exceptions.UnauthorizedException(e.message);
    }
    if (e is net_exceptions.NotFoundException) {
      return core_exceptions.NotFoundException(e.message);
    }
    if (e is net_exceptions.TimeoutException) {
      return core_exceptions.ServerException(
        e.message,
        statusCode: statusCode,
      );
    }
    if (e is net_exceptions.ServerException) {
      return core_exceptions.ServerException(
        e.message,
        statusCode: statusCode,
      );
    }

    // Generic mapping
    return core_exceptions.ServerException(
      e.message,
      statusCode: statusCode,
    );
  }

  core_exceptions.ServerException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.message ?? 'Network error';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return core_exceptions.ServerException(
          "Request timeout: $message",
          statusCode: statusCode,
        );
      case DioExceptionType.badResponse:
        if (statusCode == 400) {
          return core_exceptions.BadRequestException(message);
        }
        if (statusCode == 401) {
          return core_exceptions.UnauthorizedException(message);
        }
        if (statusCode == 404) {
          return core_exceptions.NotFoundException(message);
        }
        return core_exceptions.ServerException(
          message,
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return core_exceptions.ServerException(
          "Connection error: $message",
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return core_exceptions.ServerException(
          "Unexpected network error: $message",
          statusCode: statusCode,
        );
    }
  }
}
