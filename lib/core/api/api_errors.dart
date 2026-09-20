enum ApiErrorKind {
  timeout,
  connectivity,

  /// HTTP 401 — token missing, expired, or refresh failed.
  /// The session MUST be cleared and the user redirected to login.
  authentication,

  /// HTTP 403 — the authenticated session has insufficient role for this
  /// operation. The session is preserved; show a role-insufficient warning.
  insufficientRole,

  /// HTTP 403 — legacy alias kept so existing callers that switch on
  /// `authorization` continue to compile. Prefer [insufficientRole] for new
  /// code. Both map to the same HTTP 403 behaviour.
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

  /// Convenience: true when this exception indicates a role/permission denial
  /// (HTTP 403) rather than an unauthenticated (HTTP 401) failure.
  bool get isInsufficientRole =>
      kind == ApiErrorKind.insufficientRole ||
      kind == ApiErrorKind.authorization;

  /// Convenience: true when this exception indicates the session has expired
  /// or authentication is missing entirely.
  bool get isUnauthenticated => kind == ApiErrorKind.authentication;

  @override
  String toString() => 'ApiException(${kind.name}): $message';
}
