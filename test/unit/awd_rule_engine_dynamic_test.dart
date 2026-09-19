import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_analytics_summary.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_recommendation.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_threshold_config.dart';
import 'package:aquaflow_frontend/features/awd/domain/services/awd_rule_engine.dart';

import '../support/zone_fixtures.dart';

void main() {
  group('AwdRuleEngine Dynamic Zone Configurations', () {
    const config = AwdThresholdConfig(
      safeDryThresholdCm: -15.0,
      refloodTriggerCm: 1.0,
      targetFloodDepthCm: 5.0,
      criticalDrynessThresholdCm: -20.0,
    );

    test('evaluates single-zone configuration correctly', () {
      final singleZone = [
        sampleZone(
          code: 'Zone-North',
          waterLevelCm: 0.5,
          history: [3.0, 2.0, 1.0, 0.5],
        ),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: singleZone,
        config: config,
      );

      expect(summary.isInsufficientData, isFalse);
      expect(summary.totalNodes, equals(1));
      expect(summary.activeNodes, equals(1));
      expect(summary.fieldStatus, equals(FieldAwdStatus.refloodNeeded));
      expect(summary.recommendation.action, equals(IrrigationAction.irrigate));
      expect(summary.recommendation.rationale, contains('Zone-North'));
      expect(summary.zoneDryingRates.length, equals(1));
      expect(summary.zoneDryingRates.first.zoneCode, equals('Zone-North'));
    });

    test('evaluates dual-zone configuration with contrasting moisture/water levels', () {
      final dualZones = [
        sampleZone(
          code: 'ZA',
          waterLevelCm: 4.5,
          soilMoisturePercent: 65.0,
          history: [5.0, 4.8, 4.6, 4.5],
        ),
        sampleZone(
          code: 'ZB',
          waterLevelCm: 0.8,
          soilMoisturePercent: 38.0,
          history: [4.0, 2.5, 1.5, 0.8],
        ),
      ];

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: dualZones,
        config: config,
      );

      expect(summary.isInsufficientData, isFalse);
      expect(summary.totalNodes, equals(2));
      expect(summary.activeNodes, equals(2));
      expect(summary.fieldStatus, equals(FieldAwdStatus.refloodNeeded));
      expect(summary.recommendation.action, equals(IrrigationAction.irrigate));
      expect(summary.averageWaterDepthCm, closeTo((4.5 + 0.8) / 2, 0.05));
      expect(summary.minWaterDepthCm, equals(0.8));
    });

    test('evaluates 6-zone configuration across entire field', () {
      final sixZones = List.generate(6, (i) {
        final code = 'Z${i + 1}';
        // Water levels decreasing across zones: 4.0, 3.5, 3.0, 2.5, 2.0, 1.5
        final waterLevel = 4.0 - (i * 0.5);
        return sampleZone(
          code: code,
          waterLevelCm: waterLevel,
          history: [5.0, 4.0, 3.0, waterLevel],
        );
      });

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: sixZones,
        config: config,
      );

      expect(summary.isInsufficientData, isFalse);
      expect(summary.totalNodes, equals(6));
      expect(summary.activeNodes, equals(6));
      // All water levels >= 1.5, which is above refloodTriggerCm 1.0 -> safeDry or flooded
      expect(summary.fieldStatus, isNot(FieldAwdStatus.refloodNeeded));
      expect(summary.recommendation.action, equals(IrrigationAction.doNotIrrigate));
      expect(summary.zoneDryingRates.length, equals(6));
    });

    test('evaluates 8-zone configuration with mixed online and offline states', () {
      final eightZones = List.generate(8, (i) {
        final code = 'Z${i + 1}';
        final isOnline = i != 7; // Z8 is offline
        final waterLevel = i == 0 ? 0.2 : 3.0; // Z1 needs reflood
        return sampleZone(
          code: code,
          waterLevelCm: waterLevel,
          isOnline: isOnline,
          history: [4.0, 3.0, 2.0, waterLevel],
        );
      });

      final summary = AwdRuleEngine.evaluateFieldAwd(
        zones: eightZones,
        config: config,
      );

      expect(summary.isInsufficientData, isFalse);
      expect(summary.totalNodes, equals(8));
      expect(summary.activeNodes, equals(7)); // 7 online
      expect(summary.fieldStatus, equals(FieldAwdStatus.refloodNeeded));
      expect(summary.recommendation.action, equals(IrrigationAction.irrigate));
      expect(summary.recommendation.rationale, contains('Z1'));
      expect(summary.zoneDryingRates.length, equals(8));
    });

    test('enforces custom quorum threshold on dynamic field setups', () {
      final fourZones = List.generate(4, (i) => sampleZone(code: 'Z${i + 1}'));

      // If minRequiredZones is set to 6 but only 4 exist, marks insufficient data
      final summaryUnderQuorum = AwdRuleEngine.evaluateFieldAwd(
        zones: fourZones,
        minRequiredZones: 6,
      );
      expect(summaryUnderQuorum.isInsufficientData, isTrue);
      expect(summaryUnderQuorum.recommendation.title, contains('Insufficient Telemetry Data'));

      // When quorum is 4, evaluates successfully
      final summaryMeetsQuorum = AwdRuleEngine.evaluateFieldAwd(
        zones: fourZones,
        minRequiredZones: 4,
      );
      expect(summaryMeetsQuorum.isInsufficientData, isFalse);
    });
  });
}
