import 'dart:math' as math;
import '../../../zones/domain/models/monitoring_zone.dart';
import '../models/awd_analytics_summary.dart';
import '../models/awd_automation_eligibility.dart';
import '../models/awd_confidence.dart';
import '../models/awd_recommendation.dart';
import '../models/awd_threshold_config.dart';
import '../models/crop_growth_stage.dart';

class AwdRuleEngine {
  /// Calculates multi-factor confidence and data completeness for the field's monitoring zones.
  static AwdConfidence calculateConfidence(
    List<MonitoringZone> zones, {
    AwdThresholdConfig config = const AwdThresholdConfig(),
    bool isStaleData = false,
    DateTime? now,
    int? expectedTotalZones,
    int minRequiredZones = 1,
  }) {
    return evaluateFieldAwd(
      zones: zones,
      config: config,
      isStaleData: isStaleData,
      now: now,
      expectedTotalZones: expectedTotalZones,
      minRequiredZones: minRequiredZones,
    ).confidence;
  }

  static AwdAnalyticsSummary evaluateFieldAwd({
    required List<MonitoringZone> zones,
    AwdThresholdConfig config = const AwdThresholdConfig(),
    bool isStaleData = false,
    DateTime? now,
    int? expectedTotalZones,
    int minRequiredZones = 1,
  }) {
    final timestamp = now ?? DateTime.now();
    final totalConfiguredNodes = expectedTotalZones ?? zones.length;
    final activeOnlineZones = zones.where((z) => z.isOnline).toList();

    // ──────────────────────────────────────────────────────────────────────────
    // Stage 1: Data Cleansing, Range Validation & Outlier Detection
    // ──────────────────────────────────────────────────────────────────────────
    final flaggedOutliers = <String>[];
    final candidateZones = <MonitoringZone>[];

    for (final zone in zones) {
      final depth = zone.waterLevelCm;
      final moisture = zone.soilMoisturePercent;

      final isDepthPlausible =
          depth >= config.minPhysicalDepthCm && depth <= config.maxPhysicalDepthCm;
      final isMoisturePlausible = moisture >= 0.0 && moisture <= 100.0;

      if (!isDepthPlausible || !isMoisturePlausible) {
        flaggedOutliers.add(zone.code);
      } else {
        candidateZones.add(zone);
      }
    }

    // Statistical outlier detection using Median Absolute Deviation (MAD) for N >= 4
    final usableZones = <MonitoringZone>[];
    if (candidateZones.length >= 4) {
      final sortedDepths = candidateZones.map((z) => z.waterLevelCm).toList()..sort();
      final medianDepth = _computeMedian(sortedDepths);
      final absoluteDeviations = candidateZones
          .map((z) => (z.waterLevelCm - medianDepth).abs())
          .toList()
        ..sort();
      final mad = _computeMedian(absoluteDeviations);

      // If MAD is non-trivial, flag deviations > 3.0 * MAD
      final madThreshold = mad > 0.2 ? mad * 3.0 : 6.0;
      for (final zone in candidateZones) {
        if ((zone.waterLevelCm - medianDepth).abs() > madThreshold) {
          flaggedOutliers.add(zone.code);
        } else {
          usableZones.add(zone);
        }
      }
    } else {
      usableZones.addAll(candidateZones);
    }

    // Telemetry freshness calculation
    double totalFreshnessScore = 0.0;
    for (final zone in usableZones) {
      final ageMinutes = timestamp.difference(zone.lastUpdated).inMinutes.abs();
      if (ageMinutes <= config.freshnessTimeoutMinutes) {
        totalFreshnessScore += 1.0;
      } else if (ageMinutes <= config.freshnessTimeoutMinutes * 2) {
        totalFreshnessScore += 0.5;
      } else {
        totalFreshnessScore += 0.0;
      }
    }
    final freshnessRatio = usableZones.isNotEmpty
        ? (totalFreshnessScore / usableZones.length).clamp(0.0, 1.0)
        : 0.0;

    // Determine effective quorum
    final effectiveQuorum = config.minRequiredNodesOverride ?? minRequiredZones;
    final isInsufficientData =
        zones.isEmpty || usableZones.length < effectiveQuorum || usableZones.isEmpty;

    // Calculate confidence score
    final confidence = AwdConfidence.calculate(
      totalConfiguredNodes: totalConfiguredNodes,
      usableReportingNodes: usableZones.length,
      outlierCount: flaggedOutliers.length,
      freshnessScore: isStaleData ? 0.2 : freshnessRatio,
      minUsableNodes: effectiveQuorum,
    );

    if (isInsufficientData) {
      final insufficientEligibility = AwdAutomationEligibility(
        isEligibleForAutoIrrigation: false,
        recommendedDurationMinutes: 0,
        inhibitionReasons: [
          AwdInhibitionReason.insufficientData,
          if (confidence.score < 0.75) AwdInhibitionReason.lowConfidence,
          if (isStaleData) AwdInhibitionReason.staleTelemetry,
          if (flaggedOutliers.isNotEmpty) AwdInhibitionReason.criticalOutliers,
        ],
        summaryRationale:
            'Automated centralized irrigation is inhibited due to insufficient reporting monitoring nodes.',
        evaluatedAt: timestamp,
      );

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
          rationale: zones.isEmpty
              ? 'No active monitoring zones are currently reporting telemetry. Active zone telemetry is required to evaluate field-level AWD recommendations.'
              : 'Fewer than $effectiveQuorum usable monitoring zones are currently reporting telemetry. A minimum of $effectiveQuorum active reporting zones is required to evaluate field-level AWD recommendations.',
          keyFactors: [
            'Active usable zones: ${usableZones.length} (Minimum required: $effectiveQuorum).',
            'Configured field zones: $totalConfiguredNodes.',
            if (flaggedOutliers.isNotEmpty)
              'Outlier sensor nodes excluded: ${flaggedOutliers.join(', ')}.',
          ],
          generatedAt: timestamp,
        ),
        reportingZones: zones,
        usableReportingZones: usableZones,
        totalNodes: totalConfiguredNodes,
        activeNodes: activeOnlineZones.length,
        isInsufficientData: true,
        isStaleData: isStaleData,
        confidence: confidence,
        hasConflictingConditions: false,
        waterDepthSpreadCm: 0.0,
        flaggedOutlierZoneCodes: flaggedOutliers,
        lastUpdated: timestamp,
        autoEligibility: insufficientEligibility,
      );
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Stage 2: Spatially Weighted Metric Aggregation
    // ──────────────────────────────────────────────────────────────────────────
    final totalWeight = usableZones.map((z) => z.spatialWeight).fold<double>(0.0, (a, b) => a + b);
    final useEqualWeights = totalWeight <= 0.001;

    double weightedDepthSum = 0.0;
    double weightedMoistureSum = 0.0;
    double minDepth = double.infinity;
    double maxDepth = -double.infinity;

    for (final zone in usableZones) {
      final normalizedWeight = useEqualWeights
          ? (1.0 / usableZones.length)
          : (zone.spatialWeight / totalWeight);

      weightedDepthSum += zone.waterLevelCm * normalizedWeight;
      weightedMoistureSum += zone.soilMoisturePercent * normalizedWeight;
      minDepth = math.min(minDepth, zone.waterLevelCm);
      maxDepth = math.max(maxDepth, zone.waterLevelCm);
    }

    final averageWaterDepth = weightedDepthSum;
    final minWaterDepth = minDepth.isFinite ? minDepth : 0.0;
    final maxWaterDepth = maxDepth.isFinite ? maxDepth : 0.0;
    final averageMoisture = weightedMoistureSum;
    final depthSpread = (maxWaterDepth - minWaterDepth).abs();

    // Compute zone drying rates for all reporting zones
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

    // ──────────────────────────────────────────────────────────────────────────
    // Stage 3: Disparity Detection & Conflicting Conditions
    // ──────────────────────────────────────────────────────────────────────────
    final isDisparityDetected = depthSpread > config.maxAllowedSpreadCm;
    final hasConflictingConditions = isDisparityDetected &&
        minWaterDepth <= config.refloodTriggerCm &&
        maxWaterDepth >= 2.0;

    // ──────────────────────────────────────────────────────────────────────────
    // Stage 4: Field Status & Recommendation Decision
    // ──────────────────────────────────────────────────────────────────────────
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

    final lowZones = usableZones
        .where((z) => z.waterLevelCm <= config.refloodTriggerCm)
        .map((z) => z.code)
        .toList();
    final floodedZones = usableZones
        .where((z) => z.waterLevelCm >= 2.0)
        .map((z) => z.code)
        .toList();

    IrrigationAction action;
    RecommendationUrgency urgency;
    String title;
    String rationale;
    List<String> keyFactors = [];

    if (hasConflictingConditions) {
      // Conflicting conditions: one area is dry while another is flooded
      action = IrrigationAction.monitor;
      urgency = RecommendationUrgency.high;
      title = 'High Zone Disparity: Field Inspection Advised';
      rationale =
          'Severe water depth disparity detected across monitoring zones (${depthSpread.toStringAsFixed(1)} cm spread). Zone(s) ${lowZones.join(', ')} require reflood, but zone(s) ${floodedZones.join(', ')} remain flooded (+${maxWaterDepth.toStringAsFixed(1)} cm). Centralized irrigation would flood already inundated areas. Inspect bunds, drainage, and field leveling before pumping.';
      keyFactors = [
        'Water depth spread: ${depthSpread.toStringAsFixed(1)} cm (Limit: ${config.maxAllowedSpreadCm.toStringAsFixed(1)} cm).',
        'Drying zones: ${lowZones.join(', ')} (Min: ${minWaterDepth.toStringAsFixed(1)} cm).',
        'Flooded zones: ${floodedZones.join(', ')} (Max: +${maxWaterDepth.toStringAsFixed(1)} cm).',
        'Confidence level: ${confidence.level.label} (${(confidence.score * 100).toInt()}%).',
      ];
    } else {
      switch (status) {
        case FieldAwdStatus.criticalDryness:
          action = IrrigationAction.irrigate;
          urgency = RecommendationUrgency.critical;
          title = 'Critical Dryness: Immediate Reflood Required';
          rationale =
              'One or more monitoring zones (${lowZones.isNotEmpty ? lowZones.join(', ') : 'field area'}) have reached critical soil water depletion below ${config.criticalDrynessThresholdCm.toStringAsFixed(1)} cm. Initiate centralized field irrigation immediately to avoid crop yield loss.';
          keyFactors = [
            'Minimum zone water depth: ${minWaterDepth.toStringAsFixed(1)} cm (Threshold: ${config.criticalDrynessThresholdCm} cm).',
            'Field average water depth: ${averageWaterDepth.toStringAsFixed(1)} cm.',
            'Crop stage: ${config.cropStage.label}.',
            'Confidence: ${confidence.level.label} (${(confidence.score * 100).toInt()}%).',
          ];
          break;

        case FieldAwdStatus.refloodNeeded:
          action = IrrigationAction.irrigate;
          urgency = RecommendationUrgency.high;
          title = 'Centralized Irrigation Recommended';
          final stageNote = config.cropStage == CropGrowthStage.reproductive
              ? ' (reproductive stage: standing water required)'
              : (config.cropStage == CropGrowthStage.ripening ? ' (ripening stage)' : '');
          rationale =
              'Field drying has reached the active AWD reflood threshold (${config.refloodTriggerCm.toStringAsFixed(1)} cm)$stageNote. ${lowZones.isNotEmpty ? 'Zones ${lowZones.join(', ')} have reached the trigger point.' : 'Field average depth is ${averageWaterDepth.toStringAsFixed(1)} cm.'} Activate centralized irrigation to restore target water depth of +${config.targetFloodDepthCm.toStringAsFixed(1)} cm.';
          keyFactors = [
            'Reflood trigger threshold: ${config.refloodTriggerCm.toStringAsFixed(1)} cm.',
            'Target post-irrigation flood depth: +${config.targetFloodDepthCm.toStringAsFixed(1)} cm.',
            'Monitoring zones crossing reflood limit: ${lowZones.isNotEmpty ? lowZones.join(', ') : 'Field Average'}.',
            'Crop stage: ${config.cropStage.label}.',
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
            'Drying status: All active monitoring zones remain above reflood trigger.',
            'Crop stage: ${config.cropStage.label}.',
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
    }

    final autoEligibility = evaluateAutomationEligibility(
      fieldStatus: status,
      averageWaterDepthCm: averageWaterDepth,
      minWaterDepthCm: minWaterDepth,
      confidence: confidence,
      hasConflictingConditions: hasConflictingConditions,
      isStaleData: isStaleData,
      flaggedOutlierZoneCodes: flaggedOutliers,
      config: config,
      now: timestamp,
    );

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
      usableReportingZones: usableZones,
      totalNodes: totalConfiguredNodes,
      activeNodes: activeOnlineZones.length,
      isInsufficientData: false,
      isStaleData: isStaleData,
      confidence: confidence,
      hasConflictingConditions: hasConflictingConditions,
      waterDepthSpreadCm: depthSpread,
      flaggedOutlierZoneCodes: flaggedOutliers,
      lastUpdated: timestamp,
      autoEligibility: autoEligibility,
    );
  }

  /// Evaluates automated irrigation decision eligibility and safety inhibition rules.
  static AwdAutomationEligibility evaluateAutomationEligibility({
    required FieldAwdStatus fieldStatus,
    required double averageWaterDepthCm,
    required double minWaterDepthCm,
    required AwdConfidence confidence,
    required bool hasConflictingConditions,
    required bool isStaleData,
    required List<String> flaggedOutlierZoneCodes,
    required AwdThresholdConfig config,
    int maxSafetyDurationMinutes = 45,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final reasons = <String>[];

    // Safety Interlock 1: Zone moisture disparity conflict
    if (hasConflictingConditions) {
      reasons.add(AwdInhibitionReason.disparityConflict);
    }

    // Safety Interlock 2: Telemetry confidence score >= 0.75
    if (confidence.score < 0.75) {
      reasons.add(AwdInhibitionReason.lowConfidence);
    }

    // Safety Interlock 3: Data freshness
    if (isStaleData) {
      reasons.add(AwdInhibitionReason.staleTelemetry);
    }

    // Safety Interlock 4: Sensor outlier anomalies
    if (flaggedOutlierZoneCodes.isNotEmpty) {
      reasons.add(AwdInhibitionReason.criticalOutliers);
    }

    // Agronomic Rule 1: Terminal drainage during crop ripening stage
    if (config.cropStage == CropGrowthStage.ripening) {
      reasons.add(AwdInhibitionReason.cropStageTerminalDrainage);
    }

    // Agronomic Rule 2: Water level must indicate reflood or critical dryness
    final needsReflood = fieldStatus == FieldAwdStatus.refloodNeeded ||
        fieldStatus == FieldAwdStatus.criticalDryness;

    if (!needsReflood) {
      if (fieldStatus == FieldAwdStatus.flooded) {
        reasons.add(AwdInhibitionReason.alreadyFlooded);
      } else {
        reasons.add(AwdInhibitionReason.notInDryState);
      }
    }

    final isEligible = needsReflood && reasons.isEmpty;
    int recommendedDuration = 0;
    String summary;

    if (isEligible) {
      final deficit =
          (config.targetFloodDepthCm - averageWaterDepthCm).clamp(0.0, 35.0);
      recommendedDuration = math.min(
        maxSafetyDurationMinutes,
        (deficit * 2.5 + 10.0).round(),
      );
      if (recommendedDuration < 15) recommendedDuration = 15;
      summary =
          'Field water deficit of ${deficit.toStringAsFixed(1)} cm qualifies for automated reflood. Target runtime: $recommendedDuration minutes to reach +${config.targetFloodDepthCm.toStringAsFixed(1)} cm.';
    } else {
      final descriptions =
          reasons.map(AwdInhibitionReason.toHumanDescription).join(' ');
      summary = 'Automated irrigation inhibited: $descriptions';
    }

    return AwdAutomationEligibility(
      isEligibleForAutoIrrigation: isEligible,
      recommendedDurationMinutes: recommendedDuration,
      inhibitionReasons: reasons,
      summaryRationale: summary,
      evaluatedAt: timestamp,
    );
  }

  static double _computeMedian(List<double> values) {
    if (values.isEmpty) return 0.0;
    final middle = values.length ~/ 2;
    if (values.length % 2 == 1) {
      return values[middle];
    } else {
      return (values[middle - 1] + values[middle]) / 2.0;
    }
  }
}
