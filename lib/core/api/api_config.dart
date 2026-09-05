class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final int maxGetRetries;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 15),
    this.maxGetRetries = 2,
  });

  factory ApiConfig.fromEnvironment() {
    const configuredBaseUrl = String.fromEnvironment(
      'AQUASENSE_API_BASE_URL',
      defaultValue: 'https://api.aquasense.local',
    );
    return const ApiConfig(baseUrl: configuredBaseUrl);
  }
}
