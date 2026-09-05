class AwdThresholdConfig {
  final double safeDryThresholdCm;
  final double refloodTriggerCm;
  final double targetFloodDepthCm;
  final double criticalDrynessThresholdCm;

  const AwdThresholdConfig({
    this.safeDryThresholdCm = -15.0,
    this.refloodTriggerCm = -15.0,
    this.targetFloodDepthCm = 5.0,
    this.criticalDrynessThresholdCm = -20.0,
  });

  AwdThresholdConfig copyWith({
    double? safeDryThresholdCm,
    double? refloodTriggerCm,
    double? targetFloodDepthCm,
    double? criticalDrynessThresholdCm,
  }) {
    return AwdThresholdConfig(
      safeDryThresholdCm: safeDryThresholdCm ?? this.safeDryThresholdCm,
      refloodTriggerCm: refloodTriggerCm ?? this.refloodTriggerCm,
      targetFloodDepthCm: targetFloodDepthCm ?? this.targetFloodDepthCm,
      criticalDrynessThresholdCm:
          criticalDrynessThresholdCm ?? this.criticalDrynessThresholdCm,
    );
  }
}

