import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_confidence.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_threshold_config.dart';
import 'package:aquaflow_frontend/features/awd/domain/services/awd_rule_engine.dart';
import '../support/zone_fixtures.dart';

void main() {
  group('AWD Data Quality & Outlier Filtering Tests', () {
    const config = AwdThresholdConfig(
      minPhysicalDepthCm: -30.0,
      maxPhysicalDepthCm: 30.0,
      minRequiredNodesOverride: 2,
    );

    test('filters out nodes violating physical depth bounds (>30cm or <-30cm)', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 4.0),
        sampleZone(code: 'Z2', waterLevelCm: 4.2),
        sampleZone(code: 'Z3', waterLevelCm: 3.8),
        sampleZone(code: 'Z_ERR_HIGH', waterLevelCm: 75.0), // physical invalid
        sampleZone(code: 'Z_ERR_LOW', waterLevelCm: -55.0),  // physical invalid
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: config,
      );

      expect(summary.flaggedOutlierZoneCodes, containsAll(['Z_ERR_HIGH', 'Z_ERR_LOW']));
      expect(summary.usableReportingZones.length, equals(3));
      expect(summary.averageWaterDepthCm, closeTo(4.0, 0.2));
      expect(summary.isInsufficientData, isFalse);
    });

    test('marks field as insufficient data if physical bounds violations drop count below quorum', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 4.0),
        sampleZone(code: 'Z2_INVALID', waterLevelCm: 99.0),
        sampleZone(code: 'Z3_INVALID', waterLevelCm: -80.0),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: config, // minUsableNodes: 2, quorumRatio: 0.5
      );

      expect(summary.usableReportingZones.length, equals(1));
      expect(summary.isInsufficientData, isTrue);
      expect(summary.confidence.level, equals(AwdConfidenceLevel.insufficient));
      expect(summary.recommendation.rationale, contains('Fewer than 2 usable monitoring zones'));
    });

    test('filters statistical outlier using MAD for N >= 4 nodes', () {
      // 4 normal nodes clustered around 3.0 cm, 1 outlier at 20.0 cm (within physical bounds)
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 3.0),
        sampleZone(code: 'Z2', waterLevelCm: 3.1),
        sampleZone(code: 'Z3', waterLevelCm: 2.9),
        sampleZone(code: 'Z4', waterLevelCm: 3.2),
        sampleZone(code: 'Z_SPIKE', waterLevelCm: 20.0),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: config,
      );

      expect(summary.flaggedOutlierZoneCodes, contains('Z_SPIKE'));
      expect(summary.usableReportingZones.length, equals(4));
      // Without outlier Z_SPIKE, average should be ~3.05, NOT ~6.4
      expect(summary.averageWaterDepthCm, closeTo(3.05, 0.15));
    });

    test('does not apply statistical MAD filtering when N < 4 to preserve spatial variance', () {
      // 3 zones with natural spatial variation: 1.0, 3.0, 7.0
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 1.0),
        sampleZone(code: 'Z2', waterLevelCm: 3.0),
        sampleZone(code: 'Z3', waterLevelCm: 7.0),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: config,
      );

      expect(summary.flaggedOutlierZoneCodes, isEmpty);
      expect(summary.usableReportingZones.length, equals(3));
      expect(summary.averageWaterDepthCm, closeTo((1.0 + 3.0 + 7.0) / 3, 0.1));
    });

    test('normalizes spatial weights across remaining non-outlier nodes', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 2.0, spatialWeight: 0.2),
        sampleZone(code: 'Z2', waterLevelCm: 4.0, spatialWeight: 0.3),
        sampleZone(code: 'Z3', waterLevelCm: 4.0, spatialWeight: 0.3),
        sampleZone(code: 'Z4', waterLevelCm: 2.0, spatialWeight: 0.2),
        sampleZone(code: 'Z_OUTLIER', waterLevelCm: 25.0, spatialWeight: 0.5),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: zones,
        config: config,
      );

      expect(summary.flaggedOutlierZoneCodes, contains('Z_OUTLIER'));
      expect(summary.usableReportingZones.length, equals(4));
      // Z1: 2.0 * 0.2 = 0.4
      // Z2: 4.0 * 0.3 = 1.2
      // Z3: 4.0 * 0.3 = 1.2
      // Z4: 2.0 * 0.2 = 0.4
      // sum weight = 1.0; weighted avg = 3.2
      expect(summary.averageWaterDepthCm, closeTo(3.2, 0.05));
    });
  });
}
