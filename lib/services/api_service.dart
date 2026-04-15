import 'dart:io';

import 'package:dio/dio.dart';

class ApiResult<T> {
  const ApiResult({
    required this.success,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  final bool success;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  factory ApiResult.success(T data, {int? statusCode}) {
    return ApiResult<T>(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResult.failure(String message, {int? statusCode}) {
    return ApiResult<T>(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}

class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  static final ApiService instance = ApiService._internal();

  late final Dio _dio;

  Dio get client => _dio;

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }

    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<ApiResult<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResult<dynamic>.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiResult<dynamic>.failure(
        _mapDioError(error),
        statusCode: error.response?.statusCode,
      );
    } catch (_) {
      return ApiResult<dynamic>.failure('Unexpected error occurred.');
    }
  }

  Future<ApiResult<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResult<dynamic>.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiResult<dynamic>.failure(
        _mapDioError(error),
        statusCode: error.response?.statusCode,
      );
    } catch (_) {
      return ApiResult<dynamic>.failure('Unexpected error occurred.');
    }
  }

  Future<ApiResult<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response<dynamic> response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResult<dynamic>.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiResult<dynamic>.failure(
        _mapDioError(error),
        statusCode: error.response?.statusCode,
      );
    } catch (_) {
      return ApiResult<dynamic>.failure('Unexpected error occurred.');
    }
  }

  Future<ApiResult<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final Response<dynamic> response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResult<dynamic>.success(
        response.data,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return ApiResult<dynamic>.failure(
        _mapDioError(error),
        statusCode: error.response?.statusCode,
      );
    } catch (_) {
      return ApiResult<dynamic>.failure('Unexpected error occurred.');
    }
  }

  String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Could not verify secure connection.';
      case DioExceptionType.badResponse:
        final dynamic payload = error.response?.data;
        if (payload is Map<String, dynamic>) {
          final dynamic message = payload['message'] ?? payload['error'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
        return 'Server responded with an error.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Could not reach server.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection. Could not reach server.';
        }
        return 'Network error occurred. Please try again.';
    }
  }
}
