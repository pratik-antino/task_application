import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:task_application/core/api_client/retry_on_connection_change_interceptor.dart';
import 'api_exception.dart';
import 'api_results.dart';
import 'header_interceptors.dart';

typedef JsonMap = Map<String, dynamic>;

enum ApiStatus {
  init,
  loading,
  success,
  failed,
}

extension ApiStatusExtension on ApiStatus {
  bool get isLoading {
    return this == ApiStatus.loading;
  }
}

class DioUtil {
  static final DioUtil _instance = DioUtil.internal();
  static late Dio _dio;
  static ApiResult apiResult = ApiResult();

  DioUtil.internal() {
    final authInterceptor = AuthInterceptor();
    final retryInterceptor = RetryOnConnectionChangeInterceptor(
      interceptors: [
        authInterceptor,
      ],
    );
    _dio = Dio()
      ..interceptors.add(authInterceptor)
      ..interceptors.add(retryInterceptor)
      ..interceptors.add(
        LogInterceptor(
          responseBody: true,
          logPrint: _log,
          requestBody: true,
        ),
      );
  }

  factory DioUtil() => _instance;

  final CancelToken _cancelToken = CancelToken();

  Future get(
    url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      url = url;
      Response response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
      );
      return response.data;
    } catch (error) {
      return _handleError(url, error);
    }
  }

  Future<dynamic> post(
    url, {
    JsonMap? body,
    FormData? formData,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
    Function(int, int)? onSendProgres,
  }) async {
    try {
      url = url;
      Response response = await _dio.post(
        url,
        data: formData ?? body,
        queryParameters: queryParams,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
        onSendProgress: onSendProgres,
      );
      return response.data;
    } catch (error) {
      return _handleError(url, error);
    }
  }

  Future update(
    String url, {
    JsonMap? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      url = url;
      Response response = await _dio.put(
        url,
        data: body,
        queryParameters: queryParams,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
      );
      return response.data;
    } catch (error) {
      return _handleError(url, error);
    }
  }

  Future delete(
    String url, {
    JsonMap? body,
    Map<String, dynamic>? header,
  }) async {
    try {
      url = url;
      Response response = await _dio.delete(
        url,
        data: body,
        options: Options(headers: header),
        cancelToken: _cancelToken,
      );
      return response.data;
    } catch (error) {
      return _handleError(url, error);
    }
  }

  Future<Map<String, dynamic>> _handleError(String path, Object error) {
    if (error is DioException) {
      final method = error.requestOptions.method;
      final response = error.response;

      apiResult.setStatusCode(response?.statusCode);
      final data = response?.data;
      int? statusCode = response?.statusCode;
      // if (statusCode == 403) {
      //   SecureStorage.instance.deleteAll();;

      // }
      String? errorMessage;
      try {
        errorMessage = data['message'] ?? '';
        if ((errorMessage ?? '').isEmpty) {
          errorMessage = data['error'];
        }
      } catch (e) {
        errorMessage = 'Something went wrong';
      }

      throw ApiException(
        errorMessage: errorMessage,
        path: path,
        info: 'received server error $statusCode while $method data',
        response: data,
        statusCode: statusCode,
        method: method,
      );
    } else {
      int errorCode = 0; //We will send a default error code as 0

      throw ApiException(
        path: path,
        info: 'received server error $errorCode',
        response: error.toString(),
        statusCode: errorCode,
        method: '',
      );
    }
  }

  void _log(Object object) {
    log('$object');
  }

  Future download(String url,
      {required String path,
      void Function(int, int)? onReceiveProgress}) async {
    try {
      await Dio().download(
        url,
        path,
        onReceiveProgress: onReceiveProgress,
        cancelToken: _cancelToken,
        options: Options(followRedirects: false),
      );
    } catch (error) {
      return _handleError(url, error);
    }
  }

  Future<dynamic> put(
    url, {
    JsonMap? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      url = url;
      Response response = await _dio.put(
        url,
        data: body,
        queryParameters: queryParams,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
      );
      return response.data;
    } catch (error) {
      return _handleError(url, error);
    }
  }

  Future<dynamic> patch(
    url, {
    JsonMap? body,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      url = url;
      Response response = await _dio.patch(
        url,
        data: body,
        queryParameters: queryParams,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
      );
      return response.data;
    } catch (error) {
      return _handleError(url, error);
    }
  }
}
