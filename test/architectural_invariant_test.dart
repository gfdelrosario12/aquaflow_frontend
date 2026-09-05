import 'package:aquaflow_frontend/core/api/api_dtos.dart';
import 'package:aquaflow_frontend/core/constants/app_strings.dart';
import 'package:aquaflow_frontend/features/awd/presentation/awd_analytics_screen.dart';
import 'package:aquaflow_frontend/features/control/data/repositories/control_repository.dart';
import 'package:aquaflow_frontend/features/control/domain/models/models.dart';
import 'package:aquaflow_frontend/features/field/presentation/field_screen.dart';
import 'package:aquaflow_frontend/features/zones/data/repositories/zone_repository.dart';
import 'package:aquaflow_frontend/features/zones/presentation/zone_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final forbiddenActuatorLabels = [
    'Start Irrigation (Q1)',
    'Start Irrigation (Q2)',
    'Start Irrigation (Q3)',
    'Start Irrigation (Q4)',
    'Stop Irrigation (Q1)',
    'Zone Pump',
    'Zone Valve',
    'Q1 Pump',
    'Q2 Valve',
  ];

  group('Q1–Q4 monitoring UIs have no zone irrigation actuators', () {
    testWidgets('FieldScreen has no zone-level irrigation controls', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FieldScreen()));
      await tester.pumpAndSettle();

      for (final label in forbiddenActuatorLabels) {
        expect(find.text(label), findsNothing);
      }
      expect(find.text('Start Field Irrigation'), findsNothing);
      expect(find.textContaining(AppStrings.zoneNotice.split('.').first), findsWidgets);
    });

    testWidgets('ZoneAnalysisScreen is read-only for each quadrant', (tester) async {
      final zones = await ZoneRepositoryImpl().fetchMonitoringZones();
      expect(zones.length, greaterThanOrEqualTo(4));

      for (final zone in zones.take(4)) {
        await tester.pumpWidget(
          MaterialApp(
            home: ZoneAnalysisScreen(
              zoneCode: zone.code,
              initialZone: zone,
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final label in forbiddenActuatorLabels) {
          expect(find.text(label), findsNothing, reason: '${zone.code} showed $label');
        }
        expect(find.text('Start Field Irrigation'), findsNothing);
        expect(find.text('Stop Field Irrigation'), findsNothing);
      }
    });

    testWidgets('AwdAnalyticsScreen does not expose Q-zone irrigation buttons',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AwdAnalyticsScreen()));
      await tester.pumpAndSettle();

      for (final label in forbiddenActuatorLabels) {
        expect(find.text(label), findsNothing);
      }
    });
  });

  group('Centralized irrigation is ENTIRE FIELD only', () {
    test('DTO and repository reject non-entire-field targets', () async {
      for (final target in ['Q1', 'Q2', 'Q3', 'Q4', 'ZONE-1']) {
        expect(
          () => IrrigationCommandDto(target: target).toJson(),
          throwsA(isA<FormatException>()),
        );
      }

      final repo = MockControlRepository();
      final rejected = await repo.dispatchCommand(
        ControlCommand(
          id: 'inv-1',
          type: CommandType.startIrrigation,
          target: 'Q1',
          durationMinutes: 15,
          timestamp: DateTime.now(),
          requestedBy: 'invariant',
          userRole: ControlUserRole.operator,
        ),
      );
      expect(rejected.outcome, CommandOutcome.rejected);

      final ok = await repo.dispatchCommand(
        ControlCommand(
          id: 'inv-2',
          type: CommandType.startIrrigation,
          durationMinutes: 15,
          timestamp: DateTime.now(),
          requestedBy: 'invariant',
          userRole: ControlUserRole.operator,
        ),
      );
      expect(ok.isSuccess, isTrue);
      final telemetry = await repo.getCentralTelemetry();
      expect(telemetry.target, CentralControlTelemetry.fixedTarget);
      expect(telemetry.pumpStatus, PumpStatus.pumping);
      expect(telemetry.valveStatus, MainValveStatus.open);
    });
  });
}
