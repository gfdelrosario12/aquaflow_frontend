import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_confidence.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_threshold_config.dart';
import 'package:aquaflow_frontend/features/awd/domain/services/awd_rule_engine.dart';
import '../support/zone_fixtures.dart';

void main() {
  group('AWD Multi-Factor Confidence Scoring Tests', () {
    final now = DateTime(2026, 9, 19, 12, 0, 0);
    const config = AwdThresholdConfig(
      freshnessTimeoutMinutes: 45,
      minQuorumRatio: 0.50,
      minRequiredNodesOverride: 2,
    );

    test('evaluates High confidence when all nodes are fresh, online, and valid', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 4.0, lastUpdated: now.subtract(const Duration(minutes: 2))),
        sampleZone(code: 'Z2', waterLevelCm: 4.2, lastUpdated: now.subtract(const Duration(minutes: 3))),
        sampleZone(code: 'Z3', waterLevelCm: 3.8, lastUpdated: now.subtract(const Duration(minutes: 5))),
        sampleZone(code: 'Z4', waterLevelCm: 4.1, lastUpdated: now.subtract(const Duration(minutes: 1))),
      ];

      final confidence = AwdRuleEngine.calculateConfidence(zones, config: config, now: now);

      expect(confidence.level, equals(AwdConfidenceLevel.high));
      expect(confidence.score, greaterThanOrEqualTo(0.85));
      expect(confidence.coverageRatio, equals(1.0));
      expect(confidence.freshnessScore, greaterThanOrEqualTo(0.90));
      expect(confidence.validityRatio, equals(1.0));
      expect(confidence.contributingFactors, isNotEmpty);
    });

    test('evaluates Degraded / Medium confidence when half of the field is missing/offline', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 4.0, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 2))),
        sampleZone(code: 'Z2', waterLevelCm: 4.2, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 3))),
      ];

      final confidence = AwdRuleEngine.calculateConfidence(
        zones,
        config: config,
        expectedTotalZones: 4,
        now: now,
      );

      // 2 of 4 online -> coverage = 0.5
      expect(confidence.coverageRatio, equals(0.5));
      expect(confidence.level, equals(AwdConfidenceLevel.medium));
      expect(confidence.score, inInclusiveRange(0.60, 0.84));
    });

    test('evaluates Low confidence when data is stale beyond timeout', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 4.0, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 90))),
        sampleZone(code: 'Z2', waterLevelCm: 4.2, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 90))),
        sampleZone(code: 'Z3', waterLevelCm: 3.8, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 100))),
        sampleZone(code: 'Z4', waterLevelCm: 4.1, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 120))),
      ];

      final confidence = AwdRuleEngine.calculateConfidence(zones, config: config, now: now);

      expect(confidence.freshnessScore, lessThan(0.40));
      expect(confidence.level, anyOf(equals(AwdConfidenceLevel.low), equals(AwdConfidenceLevel.insufficient)));
    });

    test('evaluates Insufficient confidence when node count is below quorum', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 4.0, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 2))),
        sampleZone(code: 'Z2', waterLevelCm: 88.0, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 2))), // invalid
        sampleZone(code: 'Z3', waterLevelCm: -90.0, isOnline: false, lastUpdated: now.subtract(const Duration(hours: 4))), // invalid + offline
      ];

      final confidence = AwdRuleEngine.calculateConfidence(zones, config: config, now: now);

      expect(confidence.level, equals(AwdConfidenceLevel.insufficient));
      expect(confidence.score, lessThan(0.60));
    });

    test('calculates accurate composite formula: 50% coverage + 35% freshness + 15% validity', () {
      final zones = [
        sampleZone(code: 'Z1', waterLevelCm: 3.0, isOnline: true, lastUpdated: now.subtract(const Duration(minutes: 10))),
        sampleZone(code: 'Z2', waterLevelCm: 4.0, isOnline: false, lastUpdated: now.subtract(const Duration(minutes: 10))),
      ];

      final confidence = AwdRuleEngine.calculateConfidence(zones, config: config, now: now);

      final expectedScore = (confidence.coverageRatio * 0.50) +
          (confidence.freshnessScore * 0.35) +
          (confidence.validityRatio * 0.15);

      expect(confidence.score, closeTo(expectedScore, 0.001));
    });
  });
}
