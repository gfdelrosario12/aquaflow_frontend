import '../../../zones/domain/models/monitoring_zone.dart';
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
  final int totalNodes;
  final int activeNodes;
  final bool isInsufficientData;
  final bool isStaleData;
  final DateTime lastUpdated;

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
    required this.totalNodes,
    required this.activeNodes,
    this.isInsufficientData = false,
    this.isStaleData = false,
    required this.lastUpdated,
  });
}

