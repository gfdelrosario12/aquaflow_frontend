import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/field/presentation/field_screen.dart';
import 'package:aquaflow_frontend/features/zones/data/datasources/zone_data_source.dart';
import 'package:aquaflow_frontend/features/zones/data/repositories/zone_repository.dart';

void main() {
  group('ZoneRepository Diagnostic Tests', () {
    late ZoneRepository repository;

    setUp(() {
      repository = ZoneRepositoryImpl();
    });

    test('fetchMonitoringZones returns signal diagnostics (RSSI, SNR, battery)',
        () async {
      final zones = await repository.fetchMonitoringZones(
        mockState: ZoneMockState.normal,
      );

      expect(zones.length, equals(4));
      final q1 = zones.firstWhere((z) => z.code == 'Q1');
      expect(q1.isOnline, isTrue);
      expect(q1.rssiDbm, equals(-78));
      expect(q1.snrDb, equals(10.4));
      expect(q1.batteryPercent, equals(94));
      expect(q1.waterLevelHistory, isNotEmpty);
    });

    test('fetchMonitoringZones returns stale zones when requested', () async {
      final zones = await repository.fetchMonitoringZones(
        mockState: ZoneMockState.stale,
      );

      expect(zones.length, equals(4));
      final q1 = zones.firstWhere((z) => z.code == 'Q1');
      final hoursAgo = DateTime.now().difference(q1.lastUpdated).inHours;
      expect(hoursAgo, greaterThanOrEqualTo(2));
    });

    test('fetchMonitoringZones throws gateway error on unavailable state',
        () async {
      expect(
        () => repository.fetchMonitoringZones(
          mockState: ZoneMockState.unavailable,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FieldScreen Widget Tests', () {
    testWidgets('renders Field Monitoring screen and 2x2 grid in normal state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FieldScreen(),
        ),
      );

      expect(find.text('Loading Field Zone Telemetry...'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('AquaSense Field Monitoring'), findsOneWidget);
      expect(find.text('Field Telemetry Matrix'), findsOneWidget);
      expect(
        find.textContaining('Monitoring Quadrants Matrix'),
        findsOneWidget,
      );
      expect(find.text('Q1'), findsWidgets);
      expect(find.text('Q2'), findsWidgets);
      expect(find.text('Q3'), findsWidgets);
      expect(find.text('Q4'), findsWidgets);
    });

    testWidgets(
        'tapping a zone card opens ZoneDetailBottomSheet with diagnostics and read-only notice',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FieldScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap quadrant Q1 card
      await tester.tap(find.text('Q1').first);
      await tester.pumpAndSettle();

      // Inspector sheet opens
      expect(find.text('Sensor Diagnostics & Network Info'), findsOneWidget);
      expect(find.textContaining('Signal Strength (RSSI)'), findsOneWidget);
      expect(find.textContaining('-78 dBm'), findsOneWidget);
      expect(find.textContaining('Read-Only Monitoring Point (Q1)'), findsOneWidget);
    });

    testWidgets('renders gateway unavailable error state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FieldScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open tune menu to switch to Gateway Unavailable
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gateway Offline'));
      await tester.pumpAndSettle();

      expect(find.text('Gateway Telemetry Error'), findsOneWidget);
      expect(find.textContaining('Gateway node (GW-01) is offline'), findsOneWidget);
    });
  });
}
