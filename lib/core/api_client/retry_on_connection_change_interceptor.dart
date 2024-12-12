import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  /// Dio instance to fetch refresh token.
  /// Main dio instance will be blocked by [RefreshTokenInterceptor].
  /// That's why creating a new dio instance
  late final Dio _alternateDio;

  final List<Interceptor> interceptors;

  /// Stores list of request failed during refreshing token
  /// These request are sent again after refresh token retrieval is successful
  final List<(DioException, ErrorInterceptorHandler)> _failedRequests = [];

  RetryOnConnectionChangeInterceptor({
    required this.interceptors,
  }) {
    _alternateDio = Dio()..interceptors.addAll(interceptors);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      if (_shouldRetry(err)) {
        _failedRequests.add((err, handler));
        await _navigateApiFailureScreen(isServerDown: _isServerDown(err));
      } else {
        handler.next(err);
      }
    } catch (e) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return _isServerDown(err);
  }

  bool _isServerDown(DioException err) =>
      (err.type == DioExceptionType.connectionTimeout) ||
      (err.type == DioExceptionType.connectionError);

  Future<void> _navigateApiFailureScreen({required bool isServerDown}) async {
    // final (currentPath, _) = getCurrentRounteAndArgs(App.router.navigatorKey);

    // if (currentPath == RouteName.noInternetConnectionView) return;
    // await App.router.navigatorKey.currentState!.pushNamed(
    //   RouteName.noInternetConnectionView,
    //   arguments: (
    //     isServerDown,
    //     () async {
    //       await _retryFailedRequests();
    //       final (currentRoute, _) =
    //           getCurrentRounteAndArgs(App.router.navigatorKey);
    //       if (currentRoute != RouteName.noInternetConnectionView) return;
    //       App.router.navigatorKey.currentState!.pop();
    //     }
    //   ),
    // );
  }

  Future<void> _retryFailedRequests() async {
    try {
      for (final (
            DioException err,
            ErrorInterceptorHandler handler,
          ) in _failedRequests) {
        final requestOptions = err.requestOptions;
        // Sending back the response with new auth token which will be added through interceptors
        final Response response = await _alternateDio.fetch(requestOptions);
        handler.resolve(response);
      }
      _failedRequests.clear();
    } on DioException catch (e) {
      log('retryFailedRequests failed --> ${e.toString()}');
    } catch (e) {
      log(e.toString());
    }
  }
}

(String?, Object?) getCurrentRouteAndArgs(
  GlobalKey<NavigatorState> navigatorKey,
) {
  String? currentPath;
  Object? args;
  navigatorKey.currentState?.popUntil((route) {
    currentPath = route.settings.name;
    args = route.settings.arguments;

    return true;
  });
  return (currentPath, args);
}
