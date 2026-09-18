enum TransmissionMode {
  fixed,
  adaptive,
}

class TransmissionConfig {
  /// Active interval in seconds between telemetry transmissions
  final int intervalSeconds;

  /// Whether adaptive interval adjustment is active
  final bool isAdaptive;

  /// Dynamic reason for current adaptive interval (e.g., "Rapid soil dry-down detected")
  final String? adaptiveReason;

  /// Timestamp when interval was last configured or adaptively changed
  final DateTime lastConfiguredAt;

  const TransmissionConfig({
    required this.intervalSeconds,
    this.isAdaptive = false,
    this.adaptiveReason,
    required this.lastConfiguredAt,
  });

  TransmissionMode get mode =>
      isAdaptive ? TransmissionMode.adaptive : TransmissionMode.fixed;

  TransmissionConfig copyWith({
    int? intervalSeconds,
    bool? isAdaptive,
    String? adaptiveReason,
    DateTime? lastConfiguredAt,
  }) {
    return TransmissionConfig(
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      isAdaptive: isAdaptive ?? this.isAdaptive,
      adaptiveReason: adaptiveReason ?? this.adaptiveReason,
      lastConfiguredAt: lastConfiguredAt ?? this.lastConfiguredAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'intervalSeconds': intervalSeconds,
        'isAdaptive': isAdaptive,
        if (adaptiveReason != null) 'adaptiveReason': adaptiveReason,
        'lastConfiguredAt': lastConfiguredAt.toIso8601String(),
      };

  factory TransmissionConfig.fromJson(Map<String, dynamic> json) {
    return TransmissionConfig(
      intervalSeconds: int.tryParse(json['intervalSeconds']?.toString() ??
              json['transmissionIntervalSeconds']?.toString() ??
              '') ??
          300,
      isAdaptive: json['isAdaptive'] as bool? ?? false,
      adaptiveReason:
          json['adaptiveReason']?.toString() ?? json['reason']?.toString(),
      lastConfiguredAt: DateTime.tryParse(
              json['lastConfiguredAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

