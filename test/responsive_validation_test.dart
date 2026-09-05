import 'package:aquaflow_frontend/core/constants/app_dimensions.dart';
import 'package:aquaflow_frontend/core/offline/offline_models.dart';
import 'package:aquaflow_frontend/core/widgets/offline_banner.dart';
import 'package:aquaflow_frontend/features/control/data/repositories/control_repository.dart';
import 'package:aquaflow_frontend/features/control/presentation/control_screen.dart';
import 'package:aquaflow_frontend/features/control/presentation/providers/central_control_provider.dart';
import 'package:aquaflow_frontend/features/field/presentation/field_screen.dart';
import 'package:aquaflow_frontend/features/home/data/repositories/field_dashboard_repository.dart';
import 'package:aquaflow_frontend/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/responsive.dart';

void main() {
  group('Responsive phone widths', () {
    for (final width in [
      AppDimensions.minMobileWidth,
      AppDimensions.maxMobileWidth,
    ]) {
      testWidgets('HomeScreen at ${width.toInt()}px has no overflow',
          (tester) async {
        await setPhoneWidth(tester, width);
        await tester.pumpWidget(
          MaterialApp(
            home: HomeScreen(
              repository: FieldDashboardRepositoryImpl(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('ControlScreen at ${width.toInt()}px keeps Start action',
          (tester) async {
        await setPhoneWidth(tester, width);
        final notifier = CentralControlNotifier(
          repository: MockControlRepository(),
        );
        addTearDown(notifier.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ControlScreen(notifier: notifier)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Start Field Irrigation'), findsOneWidget);
        expect(find.textContaining('ENTIRE FIELD'), findsWidgets);
      });

      testWidgets('FieldScreen at ${width.toInt()}px shows Q1–Q4', (tester) async {
        await setPhoneWidth(tester, width);
        await tester.pumpWidget(const MaterialApp(home: FieldScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.textContaining('Q1'), findsWidgets);
        expect(find.textContaining('Q2'), findsWidgets);
        expect(find.textContaining('Q3'), findsWidgets);
        expect(find.textContaining('Q4'), findsWidgets);
      });
    }
  });

  group('Async UI states', () {
    testWidgets('HomeScreen loading then content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(repository: FieldDashboardRepositoryImpl()),
        ),
      );
      expect(find.textContaining('Loading'), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('AquaSense Dashboard'), findsOneWidget);
    });

    testWidgets('HomeScreen stale and error recovery via tune menu',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(repository: FieldDashboardRepositoryImpl()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stale Telemetry'));
      await tester.pumpAndSettle();
      expect(find.textContaining('STALE'), findsWidgets);

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Error State'));
      await tester.pumpAndSettle();
      expect(find.text('Telemetry Connection Error'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);

      await tester.tap(find.text('Retry Connection'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('OfflineBanner shows offline and recovery labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(state: ConnectivityState.offline),
          ),
        ),
      );
      expect(find.textContaining('Offline'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineBanner(state: ConnectivityState.recovery),
          ),
        ),
      );
      expect(find.textContaining('Recovering'), findsOneWidget);
    });
  });
}
