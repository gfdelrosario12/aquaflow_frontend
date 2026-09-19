import '../../../zones/domain/models/monitoring_zone.dart';
import 'awd_automation_eligibility.dart';
import 'awd_confidence.dart';
import 'awd_recommendation.dart';
import 'awd_threshold_config.dart';

enum FieldAwdStatus { flooded, safeDry, refloodNeeded, criticalDryness }

class ZoneDryingRate {
  final String zoneCode;
  final String zoneName;
  final double currentDepthCm;
  final double dryingRateCmPerDay;
  final TrendDirection trendDirection;

  const ZoneDryingRate({
    required this.zoneCode,
    required this.zoneName,
    required this.currentDepthCm,
    required this.dryingRateCmPerDay,
    required this.trendDirection,
  });
}

class AwdAnalyticsSummary {
  final FieldAwdStatus fieldStatus;
  final double averageWaterDepthCm;
  final double minWaterDepthCm;
  final double maxWaterDepthCm;
  final double averageSoilMoisturePercent;
  final List<ZoneDryingRate> zoneDryingRates;
  final AwdThresholdConfig activeThresholdConfig;
  final AwdRecommendation recommendation;
  final List<MonitoringZone> reportingZones;
  final List<MonitoringZone> usableReportingZones;
  final int totalNodes;
  final int activeNodes;
  final bool isInsufficientData;
  final bool isStaleData;
  final AwdConfidence confidence;
  final bool hasConflictingConditions;
  final double waterDepthSpreadCm;
  final List<String> flaggedOutlierZoneCodes;
  final DateTime lastUpdated;
  final AwdAutomationEligibility? autoEligibility;

  const AwdAnalyticsSummary({
    required this.fieldStatus,
    required this.averageWaterDepthCm,
    required this.minWaterDepthCm,
    required this.maxWaterDepthCm,
    required this.averageSoilMoisturePercent,
    required this.zoneDryingRates,
    required this.activeThresholdConfig,
    required this.recommendation,
    required this.reportingZones,
    this.usableReportingZones = const [],
    required this.totalNodes,
    required this.activeNodes,
    this.isInsufficientData = false,
    this.isStaleData = false,
    this.confidence = const AwdConfidence(
      level: AwdConfidenceLevel.insufficient,
      score: 0.0,
      coverageRatio: 0.0,
      freshnessScore: 0.0,
      validityRatio: 0.0,
      contributingFactors: [],
      summaryMessage: 'Evaluating data completeness...',
    ),
    this.hasConflictingConditions = false,
    this.waterDepthSpreadCm = 0.0,
    this.flaggedOutlierZoneCodes = const [],
    required this.lastUpdated,
    this.autoEligibility,
  });
}
