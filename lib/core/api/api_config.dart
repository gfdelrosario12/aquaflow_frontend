import 'api_errors.dart';

class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final int maxGetRetries;

  /// When true, allows `http:` base URLs for local/test builds only.
  /// Production and staging MUST leave this false and use HTTPS.
  final bool allowInsecureHttp;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 15),
    this.maxGetRetries = 2,
    this.allowInsecureHttp = false,
  });

  /// Loads base URL from `--dart-define=AQUASENSE_API_BASE_URL=<url>`.
  /// Optional `--dart-define=AQUASENSE_ALLOW_INSECURE_HTTP=true` permits HTTP for local tests.
  /// Do not embed production credentials or secrets in source; inject via dart-define only.
  factory ApiConfig.fromEnvironment() {
    const configuredBaseUrl = String.fromEnvironment(
      'AQUASENSE_API_BASE_URL',
      defaultValue: 'https://api.aquasense.local',
    );
    const allowInsecureHttp = bool.fromEnvironment(
      'AQUASENSE_ALLOW_INSECURE_HTTP',
      defaultValue: false,
    );
    return const ApiConfig(
      baseUrl: configuredBaseUrl,
      allowInsecureHttp: allowInsecureHttp,
    );
  }

  Uri? get baseUri => Uri.tryParse(baseUrl);

  bool get isSecureTransport {
    final uri = baseUri;
    if (uri == null || uri.host.isEmpty) return false;
    if (uri.scheme == 'https') return true;
    if (uri.scheme == 'http' && allowInsecureHttp) return true;
    return false;
  }

  void ensureSecureTransport() {
    final uri = baseUri;
    if (uri == null || uri.host.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.transportSecurity,
        message:
            'API base URL is invalid. Configure AQUASENSE_API_BASE_URL with an HTTPS URL.',
      );
    }
    if (uri.scheme == 'https') return;
    if (uri.scheme == 'http' && allowInsecureHttp) return;
    throw ApiException(
      kind: ApiErrorKind.transportSecurity,
      message:
          'Insecure API base URL rejected. Use HTTPS, or set AQUASENSE_ALLOW_INSECURE_HTTP only for local tests.',
    );
  }
}
