import 'crop_growth_stage.dart';

/// Configurable agronomic and data-quality parameters for Alternate Wetting and Drying.
class AwdThresholdConfig {
  final CropGrowthStage cropStage;
  final double safeDryThresholdCm;
  final double refloodTriggerCm;
  final double targetFloodDepthCm;
  final double criticalDrynessThresholdCm;

  // Data Quality & Aggregation thresholds
  final double minPhysicalDepthCm;
  final double maxPhysicalDepthCm;
  final int freshnessTimeoutMinutes;
  final double maxAllowedSpreadCm;
  final double minQuorumRatio;
  final int? minRequiredNodesOverride;

  const AwdThresholdConfig({
    this.cropStage = CropGrowthStage.vegetative,
    this.safeDryThresholdCm = -15.0,
    this.refloodTriggerCm = -15.0,
    this.targetFloodDepthCm = 5.0,
    this.criticalDrynessThresholdCm = -20.0,
    this.minPhysicalDepthCm = -35.0,
    this.maxPhysicalDepthCm = 35.0,
    this.freshnessTimeoutMinutes = 45,
    this.maxAllowedSpreadCm = 8.0,
    this.minQuorumRatio = 0.50,
    this.minRequiredNodesOverride,
  });

  /// Creates a configuration preset tailored to a specific crop growth stage.
  factory AwdThresholdConfig.forStage(
    CropGrowthStage stage, {
    double? safeDryThresholdCm,
    double? refloodTriggerCm,
    double? targetFloodDepthCm,
    double? criticalDrynessThresholdCm,
    int? freshnessTimeoutMinutes,
    double? maxAllowedSpreadCm,
  }) {
    return AwdThresholdConfig(
      cropStage: stage,
      safeDryThresholdCm: safeDryThresholdCm ?? stage.defaultSafeDryThresholdCm,
      refloodTriggerCm: refloodTriggerCm ?? stage.defaultRefloodTriggerCm,
      targetFloodDepthCm: targetFloodDepthCm ?? stage.defaultTargetFloodDepthCm,
      criticalDrynessThresholdCm: criticalDrynessThresholdCm ??
          (stage == CropGrowthStage.reproductive ? -10.0 : -20.0),
      freshnessTimeoutMinutes: freshnessTimeoutMinutes ?? 45,
      maxAllowedSpreadCm: maxAllowedSpreadCm ?? 8.0,
    );
  }

  AwdThresholdConfig copyWith({
    CropGrowthStage? cropStage,
    double? safeDryThresholdCm,
    double? refloodTriggerCm,
    double? targetFloodDepthCm,
    double? criticalDrynessThresholdCm,
    double? minPhysicalDepthCm,
    double? maxPhysicalDepthCm,
    int? freshnessTimeoutMinutes,
    double? maxAllowedSpreadCm,
    double? minQuorumRatio,
    int? minRequiredNodesOverride,
  }) {
    return AwdThresholdConfig(
      cropStage: cropStage ?? this.cropStage,
      safeDryThresholdCm: safeDryThresholdCm ?? this.safeDryThresholdCm,
      refloodTriggerCm: refloodTriggerCm ?? this.refloodTriggerCm,
      targetFloodDepthCm: targetFloodDepthCm ?? this.targetFloodDepthCm,
      criticalDrynessThresholdCm:
          criticalDrynessThresholdCm ?? this.criticalDrynessThresholdCm,
      minPhysicalDepthCm: minPhysicalDepthCm ?? this.minPhysicalDepthCm,
      maxPhysicalDepthCm: maxPhysicalDepthCm ?? this.maxPhysicalDepthCm,
      freshnessTimeoutMinutes:
          freshnessTimeoutMinutes ?? this.freshnessTimeoutMinutes,
      maxAllowedSpreadCm: maxAllowedSpreadCm ?? this.maxAllowedSpreadCm,
      minQuorumRatio: minQuorumRatio ?? this.minQuorumRatio,
      minRequiredNodesOverride:
          minRequiredNodesOverride ?? this.minRequiredNodesOverride,
    );
  }
}
