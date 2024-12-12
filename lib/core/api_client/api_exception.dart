class ApiException implements Exception {
  final String info;
  final String path;
  final int? statusCode;
  final String? method;
  final String? userId;
  final String? errorMessage;
  final dynamic response;

  ApiException({
    required this.info,
    required this.path,
    this.userId,
    this.method,
    this.statusCode,
    this.response,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'ApiException{message: $info, '
        'path: $path, '
        'statusCode: $statusCode, '
        'method: $method, '
        'userId: $userId, '
        'response: $response}';
  }
}
