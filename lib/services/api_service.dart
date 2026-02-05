import 'package:dio/dio.dart';
import 'package:bizly/app/constants/app_urls.dart';
import 'package:bizly/models/api_response.dart';
import 'local_storage.dart';

class ApiService {
  ApiService({String? baseUrl, Duration? timeout})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppUrls.baseUrl,
            connectTimeout: timeout ?? AppUrls.timeout,
            receiveTimeout: timeout ?? AppUrls.timeout,
            sendTimeout: timeout ?? AppUrls.timeout,
          ),
        );

  final Dio _dio;

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isAuth = false,
  }) async {
    final Map<String, String> requestHeaders =
        await _buildHeaders(headers, isAuth);
    return _request(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: requestHeaders),
      ),
    );
  }

  Future<ApiResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isAuth = false,
  }) async {
    final Map<String, String> requestHeaders =
        await _buildHeaders(headers, isAuth);
    return _request(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: requestHeaders),
      ),
    );
  }

  Future<ApiResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isAuth = false,
  }) async {
    final Map<String, String> requestHeaders =
        await _buildHeaders(headers, isAuth);
    return _request(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: requestHeaders),
      ),
    );
  }

  Future<ApiResponse> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isAuth = false,
  }) async {
    final Map<String, String> requestHeaders =
        await _buildHeaders(headers, isAuth);
    return _request(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: requestHeaders),
      ),
    );
  }

  Future<ApiResponse> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final Response<dynamic> response = await request();
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Something went wrong',
      );
    }
  }

  ApiResponse _handleResponse(Response<dynamic> response) {
    final dynamic body = response.data;
    final int? statusCode = response.statusCode;

    bool success = statusCode != null && statusCode >= 200 && statusCode < 300;
    String message = success ? 'Request successful' : 'Request failed';
    Map<String, dynamic>? errors;
    dynamic data;

    if (body is Map<String, dynamic>) {
      if (body.containsKey('status')) {
        success = body['status'] == true;
      }
      if (body['message'] != null) {
        message = body['message'].toString();
      }
      if (body['errors'] is Map<String, dynamic>) {
        errors = body['errors'] as Map<String, dynamic>;
      }
      data = body['data'] ?? body;
    } else {
      data = body;
    }

    return ApiResponse(
      success: success,
      message: message,
      data: data,
      errors: errors,
      statusCode: statusCode,
    );
  }

  ApiResponse _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiResponse(
        success: false,
        message: 'Request timed out. Please try again.',
      );
    }

    if (error.response != null) {
      return _handleResponse(error.response!);
    }

    return ApiResponse(
      success: false,
      message: 'Network error. Please check your connection.',
    );
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
    bool isAuth,
  ) async {
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (isAuth) {
      final String? token = await LocalStorage.getAuthToken();
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    return requestHeaders;
  }
}
