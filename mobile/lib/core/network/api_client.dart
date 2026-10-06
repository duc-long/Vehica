import 'package:dio/dio.dart';
import 'package:vehica_mobile/core/config/app_config.dart';
import 'package:vehica_mobile/core/error/exceptions.dart';
import 'package:vehica_mobile/core/network/auth_interceptor.dart';
import 'package:vehica_mobile/core/storage/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({
    required SecureStorageService storageService,
    void Function()? onUnauthorized,
    Dio? customDio,
  }) {
    dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            validateStatus: (status) =>
                status != null && status >= 200 && status < 300,
          ),
        );

    dio.interceptors.add(
      AuthInterceptor(
        storageService: storageService,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      String message = 'Đã xảy ra lỗi (${statusCode ?? 0})';

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map['data'] is Map<String, dynamic>) {
          final fieldErrors = map['data'] as Map<String, dynamic>;
          if (fieldErrors.isNotEmpty) {
            message = fieldErrors.values.first.toString();
          } else if (map.containsKey('message') && map['message'] != null) {
            message = map['message'].toString();
          }
        } else if (map.containsKey('message') && map['message'] != null) {
          message = map['message'].toString();
        }
      }

      if (statusCode == 401) {
        return UnauthorizedException(message: message);
      }
      return ServerException(message: message, statusCode: statusCode);
    }

    return ServerException(message: error.message ?? 'Lỗi không xác định');
  }
}
