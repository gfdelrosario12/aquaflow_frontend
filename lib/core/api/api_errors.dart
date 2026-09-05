enum ApiErrorKind {
  timeout,
  connectivity,
  authentication,
  authorization,
  transportSecurity,
  validation,
  server,
  decoding,
  unexpected,
}

class ApiException implements Exception {
  final ApiErrorKind kind;
  final String message;
  final int? statusCode;
  final Object? cause;

  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.cause,
  });

  @override
  String toString() => 'ApiException(${kind.name}): $message';
}
