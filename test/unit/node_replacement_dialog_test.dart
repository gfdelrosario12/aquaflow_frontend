import 'package:aquaflow_frontend/core/api/api_dtos.dart';
import 'package:aquaflow_frontend/core/widgets/aqua_button.dart';
import 'package:aquaflow_frontend/features/control/domain/models/control_enums.dart';
import 'package:aquaflow_frontend/features/nodes/domain/models/models.dart';
import 'package:aquaflow_frontend/features/nodes/presentation/widgets/node_replacement_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final targetNode = Esp32Node(
    id: 'NODE-OLD',
    macAddress: 'AA:11:22:33:44:55',
    displayName: 'Node Q1',
    assignedZoneId: 'zone-q1',
    transmissionConfig: TransmissionConfig(
      intervalSeconds: 60,
      lastConfiguredAt: DateTime(2026, 1, 1),
    ),
    isOnline: true,
    lifecycleState: NodeLifecycleStatus.active,
    lastSeen: DateTime(2026, 1, 1),
    soilMoisturePercent: 32.0,
    waterLevelCm: 5.5,
  );

  final candidateNode = Esp32Node(
    id: 'NODE-CANDIDATE',
    macAddress: 'BB:11:22:33:44:55',
    displayName: 'Spare Sensor 1',
    transmissionConfig: TransmissionConfig(
      intervalSeconds: 300,
      lastConfiguredAt: DateTime(2026, 1, 1),
    ),
    isOnline: true,
    lifecycleState: NodeLifecycleStatus.provisioned,
    lastSeen: DateTime(2026, 1, 1),
  );

  Widget buildApp({
    required ControlUserRole userRole,
    List<Esp32Node>? availableNodes,
    Future<NodeReplacementResult?> Function(NodeReplacementRequestDto)? onReplace,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                NodeReplacementDialog.show(
                  context,
                  targetNode: targetNode,
                  availableNodes: availableNodes ?? [candidateNode],
                  userRole: userRole,
                  onReplace: onReplace ??
                      (_) async => NodeReplacementResult(
                            oldNodeId: 'NODE-OLD',
                            replacementNodeId: 'NODE-CANDIDATE',
                            fieldId: 'field-1',
                            zoneId: 'zone-q1',
                            replacedAt: DateTime.now(),
                            updatedReplacementNode: candidateNode,
                            retiredNode: targetNode,
                          ),
                );
              },
              child: const Text('Open Replacement Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders replacement dialog with target node and guarantee banner', (tester) async {
    await tester.pumpWidget(buildApp(userRole: ControlUserRole.operator));
    await tester.tap(find.text('Open Replacement Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Replace Sensor Node'), findsOneWidget);
    expect(find.text('Node Q1'), findsOneWidget);
    expect(find.textContaining('Historical sensor readings'), findsOneWidget);
    expect(find.text('Execute Replacement'), findsOneWidget);
  });

  testWidgets('operator can submit replacement request with custom reason', (tester) async {
    NodeReplacementRequestDto? capturedRequest;

    await tester.pumpWidget(
      buildApp(
        userRole: ControlUserRole.operator,
        onReplace: (req) async {
          capturedRequest = req;
          return NodeReplacementResult(
            oldNodeId: 'NODE-OLD',
            replacementNodeId: req.replacementNodeId,
            fieldId: 'field-1',
            zoneId: 'zone-q1',
            replacedAt: DateTime.now(),
            updatedReplacementNode: candidateNode,
            retiredNode: targetNode,
          );
        },
      ),
    );
    await tester.tap(find.text('Open Replacement Dialog'));
    await tester.pumpAndSettle();

    // Enter replacement reason
    final reasonField = find.byType(TextField);
    expect(reasonField, findsOneWidget);
    await tester.enterText(reasonField, 'Water damage on soil probe');
    await tester.pumpAndSettle();

    // Click execute replacement
    final executeBtn = find.widgetWithText(AquaButton, 'Execute Replacement');
    await tester.ensureVisible(executeBtn);
    await tester.tap(executeBtn);
    await tester.pumpAndSettle();

    expect(capturedRequest, isNotNull);
    expect(capturedRequest!.replacementNodeId, 'NODE-CANDIDATE');
    expect(capturedRequest!.reason, 'Water damage on soil probe');
    expect(capturedRequest!.transferCalibration, isTrue);
  });

  testWidgets('viewer role sees read-only banner and has disabled execute button', (tester) async {
    await tester.pumpWidget(buildApp(userRole: ControlUserRole.viewer));
    await tester.tap(find.text('Open Replacement Dialog'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Viewing as VIEWER'), findsOneWidget);

    final btn = tester.widget<AquaButton>(
      find.widgetWithText(AquaButton, 'Execute Replacement'),
    );
    expect(btn.onPressed, isNull);
  });

  testWidgets('disables execute button when no eligible candidates are available', (tester) async {
    await tester.pumpWidget(
      buildApp(
        userRole: ControlUserRole.operator,
        availableNodes: [],
      ),
    );
    await tester.tap(find.text('Open Replacement Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('No eligible replacement nodes available.'), findsOneWidget);

    final btn = tester.widget<AquaButton>(
      find.widgetWithText(AquaButton, 'Execute Replacement'),
    );
    expect(btn.onPressed, isNull);
  });
}
