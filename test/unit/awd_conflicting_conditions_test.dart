import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_analytics_summary.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_recommendation.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_threshold_config.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/crop_growth_stage.dart';
import 'package:aquaflow_frontend/features/awd/domain/services/awd_rule_engine.dart';
import '../support/zone_fixtures.dart';

void main() {
  group('AWD Conflicting Condition & Crop Growth Stage Tests', () {
    test('detects conflicting conditions and spread when one zone is dry and another flooded', () {
      final zones = [
        sampleZone(code: 'Z_DRY1', waterLevelCm: -16.0),
        sampleZone(code: 'Z_DRY2', waterLevelCm: -15.5),
        sampleZone(code: 'Z_FLOODED1', waterLevelCm: 4.0),
        sampleZone(code: 'Z_FLOODED2', waterLevelCm: 3.5),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: const AwdThresholdConfig(
          safeDryThresholdCm: -15.0,
          refloodTriggerCm: -15.0,
          maxAllowedSpreadCm: 8.0,
        ),
      );

      // Spread = 4.0 - (-16.0) = 20.0 cm > 8.0 cm
      expect(summary.hasConflictingConditions, isTrue);
      expect(summary.waterDepthSpreadCm, closeTo(20.0, 0.01));
      // Since centralized irrigation cannot selectively water Z_DRY without overflooding Z_FLOODED,
      // the engine should recommend monitor with high urgency and field inspection alert
      expect(summary.recommendation.action, equals(IrrigationAction.monitor));
      expect(summary.recommendation.urgency, equals(RecommendationUrgency.high));
      expect(summary.recommendation.title, contains('High Zone Disparity'));
      expect(summary.recommendation.rationale, contains('Severe water depth disparity'));
      expect(summary.recommendation.rationale, contains('Inspect bunds, drainage, and field leveling'));
    });

    test('does not flag conflicting conditions when spread is large but no zone is flooded', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: -16.0),
        sampleZone(code: 'Z2', waterLevelCm: -6.0), // spread = 10.0 cm, but max is -6.0 (< 2.0 cm)
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: const AwdThresholdConfig(
          safeDryThresholdCm: -15.0,
          refloodTriggerCm: -15.0,
          maxAllowedSpreadCm: 8.0,
        ),
      );

      expect(summary.hasConflictingConditions, isFalse);
      expect(summary.waterDepthSpreadCm, closeTo(10.0, 0.01));
      // Normal reflood needed because Z1 is below -15.0
      expect(summary.fieldStatus, equals(FieldAwdStatus.refloodNeeded));
      expect(summary.recommendation.action, equals(IrrigationAction.irrigate));
    });

    test('applies reproductive stage thresholds strictly requiring standing water', () {
      final vegetativeConfig = AwdThresholdConfig.forStage(CropGrowthStage.vegetative);
      final reproductiveConfig = AwdThresholdConfig.forStage(CropGrowthStage.reproductive);

      // Water depth is -5.0 cm (soil is drying, 5cm below soil surface)
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: -5.0),
        sampleZone(code: 'Z2', waterLevelCm: -5.0),
      ];

      // In vegetative stage: safeDry is -15.0, so -5.0 cm is safe (no irrigation needed)
      final vegSummary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: vegetativeConfig,
      );
      expect(vegSummary.fieldStatus, equals(FieldAwdStatus.safeDry));
      expect(vegSummary.recommendation.action, equals(IrrigationAction.doNotIrrigate));

      // In reproductive (flowering) stage: reflood trigger is +1.0 cm. -5.0 cm is critical deficit!
      final reproSummary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: reproductiveConfig,
      );
      expect(reproSummary.fieldStatus, equals(FieldAwdStatus.refloodNeeded));
      expect(reproSummary.recommendation.action, equals(IrrigationAction.irrigate));
      expect(reproSummary.recommendation.urgency, equals(RecommendationUrgency.high));
      expect(reproSummary.recommendation.rationale, contains('reproductive stage'));
    });

    test('applies ripening stage allowing deeper drying for terminal drainage', () {
      final ripeningConfig = AwdThresholdConfig.forStage(CropGrowthStage.ripening);

      // Water depth is -17.0 cm (dryer than standard vegetative -15.0)
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: -17.0),
        sampleZone(code: 'Z2', waterLevelCm: -17.0),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: ripeningConfig,
      );

      // Ripening safeDry is -20.0 cm, so -17.0 cm is still safe dry
      expect(summary.fieldStatus, equals(FieldAwdStatus.safeDry));
      expect(summary.recommendation.action, equals(IrrigationAction.doNotIrrigate));
    });
  });
}
