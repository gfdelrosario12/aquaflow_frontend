class RealtimeConfig {
  final Uri endpoint;
  final List<String> topics;
  final Duration reconnectBaseDelay;
  final Duration reconnectMaxDelay;
  final int maxReconnectAttempts;
  final Duration staleAfter;
  final int maxRecentEventIds;

  const RealtimeConfig({
    required this.endpoint,
    this.topics = const [
      'measurements',
      'sensor-status',
      'gateway-status',
      'irrigation',
      'controllers',
      'alerts',
    ],
    this.reconnectBaseDelay = const Duration(seconds: 1),
    this.reconnectMaxDelay = const Duration(minutes: 1),
    this.maxReconnectAttempts = 5,
    this.staleAfter = const Duration(minutes: 2),
    this.maxRecentEventIds = 500,
  });

  factory RealtimeConfig.fromEnvironment() {
    const configuredEndpoint = String.fromEnvironment(
      'AQUASENSE_REALTIME_URL',
      defaultValue: 'wss://api.aquasense.local/realtime',
    );
    return RealtimeConfig(endpoint: Uri.parse(configuredEndpoint));
  }
}
