import 'dart:math' as math;
import '../../../zones/domain/models/monitoring_zone.dart';
import '../models/awd_analytics_summary.dart';
import '../models/awd_recommendation.dart';
import '../models/awd_threshold_config.dart';

class AwdRuleEngine {
  static AwdAnalyticsSummary evaluateFieldAwd({
    required List<MonitoringZone> zones,
    AwdThresholdConfig config = const AwdThresholdConfig(),
    bool isStaleData = false,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final totalNodes = 4;
    final activeNodes = zones.where((z) => z.isOnline).length;
    final isInsufficientData = zones.length < 4;

    if (isInsufficientData || zones.isEmpty) {
      return AwdAnalyticsSummary(
        fieldStatus: FieldAwdStatus.safeDry,
        averageWaterDepthCm: 0.0,
        minWaterDepthCm: 0.0,
        maxWaterDepthCm: 0.0,
        averageSoilMoisturePercent: 0.0,
        zoneDryingRates: const [],
        activeThresholdConfig: config,
        recommendation: AwdRecommendation(
          action: IrrigationAction.monitor,
          urgency: RecommendationUrgency.low,
          title: 'Insufficient Telemetry Data',
          rationale:
              'Fewer than 4 monitoring zones (Q1–Q4) are currently reporting telemetry. A complete 4-zone field dataset is required to evaluate field-level AWD recommendations.',
          keyFactors: const [
            'Telemetry requirement: 4 active monitoring quadrants required.',
            'Current active reporting nodes: less than 4.',
          ],
          generatedAt: timestamp,
        ),
        reportingZones: zones,
        totalNodes: totalNodes,
        activeNodes: activeNodes,
        isInsufficientData: true,
        isStaleData: isStaleData,
        lastUpdated: timestamp,
      );
    }

    // Compute aggregated metrics across Q1-Q4
    final depths = zones.map((z) => z.waterLevelCm).toList();
    final moistures = zones.map((z) => z.soilMoisturePercent).toList();

    final averageWaterDepth =
        depths.reduce((a, b) => a + b) / depths.length;
    final minWaterDepth = depths.reduce(math.min);
    final maxWaterDepth = depths.reduce(math.max);
    final averageMoisture =
        moistures.reduce((a, b) => a + b) / moistures.length;

    // Calculate drying/wetting rates per zone (converted to cm/day)
    final zoneDryingRates = zones.map((zone) {
      final trend = zone.trendAnalysis;
      final ratePerDay = trend.rateCmPerHour * 24.0;
      return ZoneDryingRate(
        zoneCode: zone.code,
        zoneName: zone.name,
        currentDepthCm: zone.waterLevelCm,
        dryingRateCmPerDay: ratePerDay,
        trendDirection: trend.direction,
      );
    }).toList();

    // Determine field-wide AWD status
    FieldAwdStatus status;
    if (minWaterDepth <= config.criticalDrynessThresholdCm) {
      status = FieldAwdStatus.criticalDryness;
    } else if (minWaterDepth <= config.refloodTriggerCm ||
        averageWaterDepth <= config.safeDryThresholdCm) {
      status = FieldAwdStatus.refloodNeeded;
    } else if (averageWaterDepth > 2.0) {
      status = FieldAwdStatus.flooded;
    } else {
      status = FieldAwdStatus.safeDry;
    }

    // Generate recommendation rationale
    final lowZones = zones
        .where((z) => z.waterLevelCm <= config.refloodTriggerCm)
        .map((z) => z.code)
        .toList();

    IrrigationAction action;
    RecommendationUrgency urgency;
    String title;
    String rationale;
    List<String> keyFactors = [];

    switch (status) {
      case FieldAwdStatus.criticalDryness:
        action = IrrigationAction.irrigate;
        urgency = RecommendationUrgency.critical;
        title = 'Critical Dryness: Immediate Reflood Required';
        rationale =
            'One or more monitoring zones (e.g. ${lowZones.isNotEmpty ? lowZones.join(', ') : 'Q4'}) have reached critical soil water depletion below ${config.criticalDrynessThresholdCm.toStringAsFixed(1)} cm. Initiate centralized field irrigation immediately to avoid crop yield loss.';
        keyFactors = [
          'Minimum zone water depth: ${minWaterDepth.toStringAsFixed(1)} cm (Threshold: ${config.criticalDrynessThresholdCm} cm).',
          'Field average water depth: ${averageWaterDepth.toStringAsFixed(1)} cm.',
          'Critical quadrants requiring water: ${lowZones.join(', ')}.',
        ];
        break;

      case FieldAwdStatus.refloodNeeded:
        action = IrrigationAction.irrigate;
        urgency = RecommendationUrgency.high;
        title = 'Centralized Irrigation Recommended';
        rationale =
            'Field drying has reached the active AWD reflood threshold (${config.refloodTriggerCm.toStringAsFixed(1)} cm). ${lowZones.isNotEmpty ? 'Zones ${lowZones.join(', ')} have reached the trigger point.' : 'Field average depth is ${averageWaterDepth.toStringAsFixed(1)} cm.'} Activate centralized irrigation to restore target water depth of +${config.targetFloodDepthCm.toStringAsFixed(1)} cm.';
        keyFactors = [
          'Reflood trigger threshold: ${config.refloodTriggerCm.toStringAsFixed(1)} cm.',
          'Target post-irrigation flood depth: +${config.targetFloodDepthCm.toStringAsFixed(1)} cm.',
          'Quadrants crossing reflood limit: ${lowZones.isNotEmpty ? lowZones.join(', ') : 'Field Average'}.',
        ];
        break;

      case FieldAwdStatus.safeDry:
        action = IrrigationAction.doNotIrrigate;
        urgency = RecommendationUrgency.low;
        title = 'Maintain Safe Drying Cycle';
        rationale =
            'Field water levels are within safe AWD drying boundaries (Average: ${averageWaterDepth.toStringAsFixed(1)} cm). Soil aeration is promoting root health. Centralized irrigation is not recommended at this time.';
        keyFactors = [
          'Field average depth: ${averageWaterDepth.toStringAsFixed(1)} cm (Safe limit: ${config.safeDryThresholdCm.toStringAsFixed(1)} cm).',
          'Soil moisture average: ${averageMoisture.toStringAsFixed(1)}%.',
          'Drying status: All quadrants remain above reflood trigger.',
        ];
        break;

      case FieldAwdStatus.flooded:
        action = IrrigationAction.doNotIrrigate;
        urgency = RecommendationUrgency.low;
        title = 'Field Standing Water Adequate';
        rationale =
            'Field has standing water average of +${averageWaterDepth.toStringAsFixed(1)} cm. Allow natural percolation and crop evapotranspiration to progress the AWD drying phase before applying additional water.';
        keyFactors = [
          'Field standing water depth: +${averageWaterDepth.toStringAsFixed(1)} cm.',
          'Highest zone level: +${maxWaterDepth.toStringAsFixed(1)} cm.',
          'Centralized pump: Keep idle to save energy and water.',
        ];
        break;
    }

    return AwdAnalyticsSummary(
      fieldStatus: status,
      averageWaterDepthCm: averageWaterDepth,
      minWaterDepthCm: minWaterDepth,
      maxWaterDepthCm: maxWaterDepth,
      averageSoilMoisturePercent: averageMoisture,
      zoneDryingRates: zoneDryingRates,
      activeThresholdConfig: config,
      recommendation: AwdRecommendation(
        action: action,
        urgency: urgency,
        title: title,
        rationale: rationale,
        keyFactors: keyFactors,
        generatedAt: timestamp,
      ),
      reportingZones: zones,
      totalNodes: totalNodes,
      activeNodes: activeNodes,
      isInsufficientData: false,
      isStaleData: isStaleData,
      lastUpdated: timestamp,
    );
  }
}

