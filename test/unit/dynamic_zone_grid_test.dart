import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/field/presentation/widgets/dynamic_zone_grid_visualizer.dart';
import 'package:aquaflow_frontend/features/zones/domain/models/monitoring_zone.dart';

import '../support/responsive.dart';
import '../support/zone_fixtures.dart';

void main() {
  group('DynamicZoneGridVisualizer Widget Tests', () {
    testWidgets('renders empty state safely when zones list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicZoneGridVisualizer(zones: []),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DynamicZoneGridVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final zoneCount in [1, 2, 4, 6, 8]) {
      for (final width in [360.0, 400.0, 600.0, 900.0, 1200.0]) {
        testWidgets('renders $zoneCount zones at ${width.toInt()}px without overflow',
            (tester) async {
          await setPhoneWidth(tester, width);

          final zones = List.generate(
            zoneCount,
            (i) => sampleZone(
              code: 'Z${i + 1}',
              waterLevelCm: 4.5,
              soilMoisturePercent: 55.0 + (i * 2),
            ),
          );

          MonitoringZone? selected;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: DynamicZoneGridVisualizer(
                    zones: zones,
                    onZoneSelected: (zone) => selected = zone,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);

          // All zone codes should be displayed
          for (int i = 1; i <= zoneCount; i++) {
            expect(find.text('Z$i'), findsOneWidget);
          }

          // Verify interaction
          await tester.tap(find.text('Z1'));
          await tester.pumpAndSettle();
          expect(selected?.code, equals('Z1'));
        });
      }
    }
  });
}

