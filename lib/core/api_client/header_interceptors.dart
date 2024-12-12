import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_application/core/config/storage_utils.dart';
///1. Create default header
///2. Add token if exists
///3. Add other header params if passed
///4. Refresh the token if [_authErrorCode]
class AuthInterceptor extends QueuedInterceptor {
  /// Dio instance to fetch refresh token.
  /// Main dio instance will be blocked by [AuthInterceptor].
  /// That's why creating a new dio instance
  final Dio _alternateDio = Dio(BaseOptions(
      // baseUrl: Const.apiUrl,
      ))
    ..interceptors.add(LogInterceptor(
        responseBody: true,
        logPrint: (Object object) {
          log("$object");
        }));

  static const int _authErrorCode = 401;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (await _hasRequestTokenExpired()) {
        options = options.copyWith(
          headers: await _createHeader(options.headers),
        );
        handler.next(options);
      } else {
        _sendAuthError(handler, options);
      }
    } catch (_) {
      _sendAuthError(handler, options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != _authErrorCode) {
      return super.onError(err, handler);
    }
    try {
      // In case of [_authErrorCode] trying to get new token.
      // Retrying the existing request.
      final requestOptions = err.requestOptions.copyWith(
        headers: await _createHeader(
          err.requestOptions.headers,
        ),
      );
      // Sending back the response with new auth token
      final Response response = await _alternateDio.fetch(requestOptions);
      handler.resolve(response);
    } catch (_) {}
    super.onError(err, handler);
  }

  Future<Map<String, dynamic>> _createHeader(
      Map<String, dynamic>? headers) async {
    //Create default header

    Map<String, dynamic> tempHeader = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (headers != null) {
      tempHeader.addAll(headers);
    }
    final _pref = await SharedPreferences.getInstance();
    final accessToken = _pref.getString('token');
    // navigatorKey.currentState!.context.read<AuthCubit>().state.accessToken;

    final token = accessToken?.isNotEmpty == true ? accessToken : null;

    //Add token if exists
    if (token != null) {
      tempHeader['authorization'] = 'Bearer $token';
    } else {
      tempHeader.remove('authorization');
    }

    return tempHeader;
  }

  ///Checks validity of refresh token and access token
  ///Also updates the access token if it is expired.
  ///<br>
  ///Returns false if refreshToken is expired
  ///Returns true if all tokens are valid.
  ///Returns true if both tokens are null because on this case no auth is required.
  ///Returns true if token is refreshed
  Future<bool> _hasRequestTokenExpired() async {
    const refreshToken = null;
    final token = await SecureStorage.instance.read('accessToken');
    // final token = await SecureStorage.instance.read('accessToken');

    final accessToken = token?.isNotEmpty == true ? token : null;
    if (refreshToken == null && accessToken == null) {
      return true;
    }
    if (refreshToken == null || accessToken == null) {
      return true;
    }
    return false;
  }

  /// All tokens have expired. Throwing [DioException] with
  /// status code [_authErrorCode] so that the app logs out.
  void _sendAuthError(
    RequestInterceptorHandler handler,
    RequestOptions options,
  ) {
    handler.reject(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: _authErrorCode,
        ),
      ),
    );
  }
}
