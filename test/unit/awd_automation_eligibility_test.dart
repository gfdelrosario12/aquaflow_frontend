import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_analytics_summary.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_automation_eligibility.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_confidence.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_threshold_config.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/crop_growth_stage.dart';
import 'package:aquaflow_frontend/features/awd/domain/services/awd_rule_engine.dart';

import '../support/zone_fixtures.dart';

void main() {
  group('AwdAutomationEligibility evaluation', () {
    const config = AwdThresholdConfig(
      cropStage: CropGrowthStage.vegetative,
      safeDryThresholdCm: -15.0,
      refloodTriggerCm: -15.0,
      targetFloodDepthCm: 5.0,
      criticalDrynessThresholdCm: -20.0,
      maxAllowedSpreadCm: 8.0,
    );

    const highConfidence = AwdConfidence(
      level: AwdConfidenceLevel.high,
      score: 0.88,
      coverageRatio: 1.0,
      freshnessScore: 1.0,
      validityRatio: 1.0,
      contributingFactors: ['Full zone coverage'],
      summaryMessage: 'High confidence field assessment',
    );

    test('marks eligible for optimal reflood with high confidence and fresh data',
        () {
      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.refloodNeeded,
        averageWaterDepthCm: -15.2,
        minWaterDepthCm: -16.0,
        confidence: highConfidence,
        hasConflictingConditions: false,
        isStaleData: false,
        flaggedOutlierZoneCodes: const [],
        config: config,
        now: DateTime(2026, 9, 19, 10),
      );

      expect(eligibility.isEligibleForAutoIrrigation, isTrue);
      expect(eligibility.inhibitionReasons, isEmpty);
      expect(eligibility.recommendedDurationMinutes, greaterThanOrEqualTo(15));
      expect(eligibility.recommendedDurationMinutes, lessThanOrEqualTo(45));
      expect(eligibility.summaryRationale, contains('automated reflood'));
    });

    test('inhibits automated irrigation due to high zone disparity', () {
      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.refloodNeeded,
        averageWaterDepthCm: -8.0,
        minWaterDepthCm: -16.0,
        confidence: highConfidence,
        hasConflictingConditions: true,
        isStaleData: false,
        flaggedOutlierZoneCodes: const [],
        config: config,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isFalse);
      expect(
        eligibility.hasInhibition(AwdInhibitionReason.disparityConflict),
        isTrue,
      );
      expect(eligibility.summaryRationale, contains('inhibited'));
    });

    test('inhibits when telemetry confidence is below 0.75', () {
      const lowConfidence = AwdConfidence(
        level: AwdConfidenceLevel.low,
        score: 0.55,
        coverageRatio: 0.5,
        freshnessScore: 0.6,
        validityRatio: 0.7,
        contributingFactors: ['Partial coverage'],
        summaryMessage: 'Low confidence',
      );

      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.criticalDryness,
        averageWaterDepthCm: -21.0,
        minWaterDepthCm: -22.0,
        confidence: lowConfidence,
        hasConflictingConditions: false,
        isStaleData: false,
        flaggedOutlierZoneCodes: const [],
        config: config,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isFalse);
      expect(
        eligibility.hasInhibition(AwdInhibitionReason.lowConfidence),
        isTrue,
      );
    });

    test('inhibits when telemetry is stale', () {
      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.refloodNeeded,
        averageWaterDepthCm: -15.5,
        minWaterDepthCm: -16.0,
        confidence: highConfidence,
        hasConflictingConditions: false,
        isStaleData: true,
        flaggedOutlierZoneCodes: const [],
        config: config,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isFalse);
      expect(
        eligibility.hasInhibition(AwdInhibitionReason.staleTelemetry),
        isTrue,
      );
    });

    test('inhibits when critical outliers are present', () {
      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.refloodNeeded,
        averageWaterDepthCm: -15.5,
        minWaterDepthCm: -16.0,
        confidence: highConfidence,
        hasConflictingConditions: false,
        isStaleData: false,
        flaggedOutlierZoneCodes: const ['Q3'],
        config: config,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isFalse);
      expect(
        eligibility.hasInhibition(AwdInhibitionReason.criticalOutliers),
        isTrue,
      );
    });

    test('inhibits during ripening terminal drainage stage', () {
      final ripeningConfig = config.copyWith(cropStage: CropGrowthStage.ripening);

      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.refloodNeeded,
        averageWaterDepthCm: -15.5,
        minWaterDepthCm: -16.0,
        confidence: highConfidence,
        hasConflictingConditions: false,
        isStaleData: false,
        flaggedOutlierZoneCodes: const [],
        config: ripeningConfig,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isFalse);
      expect(
        eligibility.hasInhibition(AwdInhibitionReason.cropStageTerminalDrainage),
        isTrue,
      );
    });

    test('inhibits when field is already flooded', () {
      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.flooded,
        averageWaterDepthCm: 4.5,
        minWaterDepthCm: 3.0,
        confidence: highConfidence,
        hasConflictingConditions: false,
        isStaleData: false,
        flaggedOutlierZoneCodes: const [],
        config: config,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isFalse);
      expect(
        eligibility.hasInhibition(AwdInhibitionReason.alreadyFlooded),
        isTrue,
      );
      expect(eligibility.recommendedDurationMinutes, equals(0));
    });

    test('calculates estimated run duration proportional to water deficit', () {
      // deficit = 5.0 - (-15.0) = 20.0 cm
      // duration = min(45, (20*2.5 + 10).round()) = min(45, 60) = 45
      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.refloodNeeded,
        averageWaterDepthCm: -15.0,
        minWaterDepthCm: -15.5,
        confidence: highConfidence,
        hasConflictingConditions: false,
        isStaleData: false,
        flaggedOutlierZoneCodes: const [],
        config: config,
        maxSafetyDurationMinutes: 45,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isTrue);
      expect(eligibility.recommendedDurationMinutes, equals(45));
    });

    test('enforces minimum 15-minute duration for small deficits', () {
      // deficit = 5.0 - 4.0 = 1.0 cm
      // duration = (1*2.5 + 10).round() = 13 -> clamped to 15
      final eligibility = AwdRuleEngine.evaluateAutomationEligibility(
        fieldStatus: FieldAwdStatus.refloodNeeded,
        averageWaterDepthCm: 4.0,
        minWaterDepthCm: 0.5,
        confidence: highConfidence,
        hasConflictingConditions: false,
        isStaleData: false,
        flaggedOutlierZoneCodes: const [],
        config: config.copyWith(refloodTriggerCm: 1.0),
        maxSafetyDurationMinutes: 45,
      );

      expect(eligibility.isEligibleForAutoIrrigation, isTrue);
      expect(eligibility.recommendedDurationMinutes, equals(15));
    });

    test('end-to-end: field evaluation produces disparity inhibition via rule engine',
        () {
      final zones = [
        sampleZone(code: 'Q1', waterLevelCm: -16.0, history: [-10, -12, -14, -16]),
        sampleZone(code: 'Q2', waterLevelCm: -15.5, history: [-10, -12, -14, -15.5]),
        sampleZone(code: 'Q3', waterLevelCm: 5.0, history: [5.0, 5.0, 5.0, 5.0]),
        sampleZone(code: 'Q4', waterLevelCm: 4.5, history: [4.5, 4.5, 4.5, 4.5]),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: config,
      );

      expect(summary.hasConflictingConditions, isTrue);
      expect(summary.autoEligibility, isNotNull);
      expect(summary.autoEligibility!.isEligibleForAutoIrrigation, isFalse);
      expect(
        summary.autoEligibility!
            .hasInhibition(AwdInhibitionReason.disparityConflict),
        isTrue,
      );
    });

    test('human descriptions cover all known inhibition codes', () {
      for (final reason in [
        AwdInhibitionReason.disparityConflict,
        AwdInhibitionReason.lowConfidence,
        AwdInhibitionReason.staleTelemetry,
        AwdInhibitionReason.criticalOutliers,
        AwdInhibitionReason.cropStageTerminalDrainage,
        AwdInhibitionReason.insufficientData,
        AwdInhibitionReason.alreadyFlooded,
        AwdInhibitionReason.notInDryState,
      ]) {
        final description = AwdInhibitionReason.toHumanDescription(reason);
        expect(description, isNotEmpty);
        expect(description, isNot(equals(reason)));
      }
    });
  });
}
