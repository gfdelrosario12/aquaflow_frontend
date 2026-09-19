import 'package:aquaflow_frontend/core/api/api_dtos.dart';
import 'package:aquaflow_frontend/core/realtime/realtime_events.dart';
import 'package:aquaflow_frontend/features/control/domain/models/control_enums.dart';
import 'package:aquaflow_frontend/features/nodes/data/repositories/node_repository.dart';
import 'package:aquaflow_frontend/features/nodes/domain/models/models.dart';
import 'package:aquaflow_frontend/features/nodes/presentation/providers/node_management_notifier.dart';
import 'package:aquaflow_frontend/features/nodes/presentation/providers/spatial_field_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Esp32Node domain models', () {
    test('SpatialCoordinates reports geo and local availability', () {
      const coords = SpatialCoordinates(
        latitude: 14.1524,
        longitude: 121.2431,
        localX: 25,
        localY: 40,
      );
      expect(coords.hasGeoCoordinates, isTrue);
      expect(coords.hasLocalCoordinates, isTrue);
      expect(coords.hasAnyCoordinates, isTrue);
      expect(coords.toJson()['localX'], 25);
    });

    test('TransmissionConfig maps adaptive mode', () {
      final config = TransmissionConfig(
        intervalSeconds: 60,
        isAdaptive: true,
        adaptiveReason: 'dry-down',
        lastConfiguredAt: DateTime(2026, 1, 1),
      );
      expect(config.mode, TransmissionMode.adaptive);
      expect(TransmissionConfig.fromJson(config.toJson()).intervalSeconds, 60);
    });

    test('Esp32Node copyWith updates transmission and telemetry', () {
      final node = Esp32Node(
        id: 'NODE-Q1',
        macAddress: 'AA:BB:CC:DD:EE:01',
        displayName: 'Q1',
        transmissionConfig: TransmissionConfig(
          intervalSeconds: 300,
          lastConfiguredAt: DateTime(2026, 1, 1),
        ),
        isOnline: true,
        lastSeen: DateTime(2026, 1, 1),
      );
      final updated = node.copyWith(
        soilMoisturePercent: 22.5,
        transmissionConfig: node.transmissionConfig.copyWith(intervalSeconds: 30),
      );
      expect(updated.soilMoisturePercent, 22.5);
      expect(updated.transmissionConfig.intervalSeconds, 30);
      expect(updated.id, 'NODE-Q1');
    });
  });

  group('MockNodeRepository', () {
    test('seeds quadrant-compatible nodes and discovered devices', () async {
      final repo = MockNodeRepository();
      final nodes = await repo.fetchNodes();
      final discovered = await repo.fetchDiscoveredNodes();

      expect(nodes, hasLength(4));
      expect(nodes.map((n) => n.id), containsAll(['NODE-Q1', 'NODE-Q2', 'NODE-Q3', 'NODE-Q4']));
      expect(discovered, isNotEmpty);
    });

    test('registers node and configures transmission interval', () async {
      final repo = MockNodeRepository(initialDiscovered: [
        NodeDiscoveryInfo(
          id: 'DISC-1',
          macAddress: 'A4:CF:12:98:F1:AA',
          hardwareModel: 'ESP32',
          firmwareVersion: 'v2',
          rssiDbm: -70,
          detectedAt: DateTime.now(),
        ),
      ]);

      final registered = await repo.registerNode(
        const NodeRegistrationRequestDto(
          macAddress: 'A4:CF:12:98:F1:AA',
          displayName: 'New Node',
          fieldId: 'field-main',
          zoneId: 'zone-q1',
          latitude: 14.15,
          longitude: 121.24,
          localX: 10,
          localY: 20,
          transmissionIntervalSeconds: 120,
        ),
      );
      expect(registered.displayName, 'New Node');
      expect(await repo.fetchDiscoveredNodes(), isEmpty);

      final config = await repo.configureTransmissionInterval(
        registered.id,
        const TransmissionConfigDto(intervalSeconds: 30, isAdaptive: true, reason: 'dry-down'),
      );
      expect(config.intervalSeconds, 30);
      expect(config.isAdaptive, isTrue);

      final fetched = await repo.fetchNodeById(registered.id);
      expect(fetched?.transmissionConfig.intervalSeconds, 30);
    });
  });

  group('NodeManagementNotifier', () {
    test('loads nodes and applies transmissionIntervalUpdated events', () async {
      final repo = MockNodeRepository();
      final notifier = NodeManagementNotifier(repository: repo);
      addTearDown(notifier.dispose);

      await notifier.fetchNodes();
      expect(notifier.state.nodes, hasLength(4));

      notifier.handleRealtimeEvent(
        RealtimeEvent.fromJson({
          'version': 1,
          'eventId': 'evt-interval-1',
          'eventType': 'transmissionIntervalUpdated',
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          'sequence': 1,
          'scope': 'NODE-Q1',
          'payload': {
            'nodeId': 'NODE-Q1',
            'intervalSeconds': 30,
            'isAdaptive': true,
            'reason': 'Rapid soil dry-down detected',
          },
        }),
      );

      final node = notifier.state.nodes.firstWhere((n) => n.id == 'NODE-Q1');
      expect(node.transmissionConfig.intervalSeconds, 30);
      expect(node.transmissionConfig.isAdaptive, isTrue);
      expect(node.transmissionConfig.adaptiveReason, contains('dry-down'));
    });

    test('registers discovered node through notifier', () async {
      final repo = MockNodeRepository();
      final notifier = NodeManagementNotifier(repository: repo);
      addTearDown(notifier.dispose);
      await notifier.fetchDiscoveredNodes();
      final mac = notifier.state.discoveredNodes.first.macAddress;

      final ok = await notifier.registerNode(
        NodeRegistrationRequestDto(
          macAddress: mac,
          displayName: 'Commissioned Node',
          fieldId: 'field-main',
          zoneId: 'zone-q2',
          transmissionIntervalSeconds: 60,
        ),
      );
      expect(ok, isTrue);
      expect(
        notifier.state.nodes.any((n) => n.displayName == 'Commissioned Node'),
        isTrue,
      );
    });
  });

  group('SpatialFieldNotifier', () {
    test('normalizes local coordinates into canvas-relative points', () {
      final notifier = SpatialFieldNotifier();
      final node = Esp32Node(
        id: 'NODE-Q1',
        macAddress: 'AA:BB',
        displayName: 'Q1',
        coordinates: const SpatialCoordinates(localX: 25, localY: 75),
        transmissionConfig: TransmissionConfig(
          intervalSeconds: 300,
          lastConfiguredAt: DateTime(2026, 1, 1),
        ),
        isOnline: true,
        lastSeen: DateTime(2026, 1, 1),
      );

      final point = notifier.getNormalizedPosition(node);
      expect(point, isNotNull);
      expect(point!.x, closeTo(0.25, 0.01));
      // Y is inverted so localY=75 on a 100m field → ~0.25 from top
      expect(point.y, closeTo(0.25, 0.01));

      notifier.selectNode('NODE-Q1');
      expect(notifier.state.selectedNodeId, 'NODE-Q1');
      notifier.toggleGridLines();
      expect(notifier.state.showGridLines, isFalse);
    });
  });

  group('RealtimeEvent dynamic node scopes', () {
    test('accepts NODE-/ESP32- scopes for interval updates', () {
      final event = RealtimeEvent.fromJson({
        'version': 1,
        'eventId': 'evt-n1',
        'eventType': 'transmission_interval_updated',
        'occurredAt': DateTime.now().toUtc().toIso8601String(),
        'sequence': 2,
        'scope': 'NODE-Q2',
        'payload': {'intervalSeconds': 60},
      });
      expect(event.type, RealtimeEventType.transmissionIntervalUpdated);
      expect(event.isMonitoringScope, isTrue);
    });

    test('parses nodeDiscovered and nodeStatus event types', () {
      final discovered = RealtimeEvent.fromJson({
        'version': 1,
        'eventId': 'evt-d1',
        'eventType': 'node_discovered',
        'occurredAt': DateTime.now().toUtc().toIso8601String(),
        'sequence': 3,
        'scope': 'ENTIRE FIELD',
        'payload': {'macAddress': 'AA:BB:CC'},
      });
      expect(discovered.type, RealtimeEventType.nodeDiscovered);

      final status = RealtimeEvent.fromJson({
        'version': 1,
        'eventId': 'evt-s1',
        'eventType': 'node_status',
        'occurredAt': DateTime.now().toUtc().toIso8601String(),
        'sequence': 4,
        'scope': 'ESP32-98F1',
        'payload': {'isOnline': false},
      });
      expect(status.type, RealtimeEventType.nodeStatus);
    });

    test('parses nodeLifecycleUpdated and nodeReplaced event types', () {
      final lifecycleEvt = RealtimeEvent.fromJson({
        'version': 1,
        'eventId': 'evt-lc-1',
        'eventType': 'node_lifecycle_updated',
        'occurredAt': DateTime.now().toUtc().toIso8601String(),
        'sequence': 5,
        'scope': 'NODE-Q1',
        'payload': {'nodeId': 'NODE-Q1', 'lifecycleStatus': 'maintenance'},
      });
      expect(lifecycleEvt.type, RealtimeEventType.nodeLifecycleUpdated);

      final replacedEvt = RealtimeEvent.fromJson({
        'version': 1,
        'eventId': 'evt-rep-1',
        'eventType': 'node_replaced',
        'occurredAt': DateTime.now().toUtc().toIso8601String(),
        'sequence': 6,
        'scope': 'NODE-Q1',
        'payload': {
          'oldNodeId': 'NODE-Q1',
          'replacementNodeId': 'NODE-Q5',
          'fieldId': 'field-main',
          'zoneId': 'zone-q1',
        },
      });
      expect(replacedEvt.type, RealtimeEventType.nodeReplaced);
    });
  });

  group('Atomic Node Replacement & Measurement Preservation', () {
    test('MockNodeRepository executes atomic swap preserving zone and point linkage', () async {
      final repo = MockNodeRepository(
        initialNodes: [
          Esp32Node(
            id: 'NODE-OLD',
            macAddress: 'AA:11:22:33:44:55',
            displayName: 'Old Sensor Q1',
            assignedFieldId: 'field-1',
            assignedZoneId: 'zone-1',
            assignedPointId: 'point-1',
            coordinates: const SpatialCoordinates(latitude: 14.15, longitude: 121.24, localX: 10, localY: 20),
            transmissionConfig: TransmissionConfig(intervalSeconds: 60, lastConfiguredAt: DateTime.now()),
            isOnline: true,
            lifecycleState: NodeLifecycleStatus.active,
            lastSeen: DateTime.now(),
            soilMoisturePercent: 35.5,
            waterLevelCm: 4.2,
          ),
          Esp32Node(
            id: 'NODE-NEW',
            macAddress: 'BB:11:22:33:44:55',
            displayName: 'New Spare Sensor',
            transmissionConfig: TransmissionConfig(intervalSeconds: 300, lastConfiguredAt: DateTime.now()),
            isOnline: true,
            lifecycleState: NodeLifecycleStatus.provisioned,
            lastSeen: DateTime.now(),
          ),
        ],
      );

      final result = await repo.executeNodeReplacement(
        oldNodeId: 'NODE-OLD',
        replacementNodeId: 'NODE-NEW',
        reason: 'Faulty soil probe',
        transferCalibration: true,
      );

      expect(result.oldNodeId, 'NODE-OLD');
      expect(result.replacementNodeId, 'NODE-NEW');
      expect(result.historicalMeasurementsPreserved, isTrue);
      expect(result.zoneId, 'zone-1');

      // Check retired node
      final retired = await repo.fetchNodeById('NODE-OLD');
      expect(retired?.lifecycleState, NodeLifecycleStatus.replaced);
      expect(retired?.replacedByNodeId, 'NODE-NEW');
      expect(retired?.isRetired, isTrue);

      // Check active replacement node
      final active = await repo.fetchNodeById('NODE-NEW');
      expect(active?.lifecycleState, NodeLifecycleStatus.active);
      expect(active?.assignedZoneId, 'zone-1');
      expect(active?.assignedPointId, 'point-1');
      expect(active?.replacesNodeId, 'NODE-OLD');
      // Preserves historical telemetry reading continuity
      expect(active?.soilMoisturePercent, 35.5);
      expect(active?.waterLevelCm, 4.2);
    });

    test('NodeManagementNotifier enforces role permissions on replacement', () async {
      final repo = MockNodeRepository();
      final notifier = NodeManagementNotifier(repository: repo);
      addTearDown(notifier.dispose);
      await notifier.fetchNodes();

      // Viewer role must be rejected
      final viewerResult = await notifier.executeNodeReplacement(
        'NODE-Q1',
        const NodeReplacementRequestDto(replacementNodeId: 'NODE-Q2'),
        userRole: ControlUserRole.viewer,
      );
      expect(viewerResult, isNull);
      expect(notifier.state.errorMessage, contains('Viewers cannot replace sensor nodes'));

      // Operator role succeeds
      final operatorResult = await notifier.executeNodeReplacement(
        'NODE-Q1',
        const NodeReplacementRequestDto(
          replacementNodeId: 'NODE-Q2',
          reason: 'Routine hardware upgrade',
        ),
        userRole: ControlUserRole.operator,
      );
      expect(operatorResult, isNotNull);
      expect(operatorResult!.oldNodeId, 'NODE-Q1');
      expect(operatorResult.replacementNodeId, 'NODE-Q2');
    });

    test('NodeManagementNotifier handles realtime nodeReplaced event', () async {
      final repo = MockNodeRepository();
      final notifier = NodeManagementNotifier(repository: repo);
      addTearDown(notifier.dispose);
      await notifier.fetchNodes();

      notifier.handleRealtimeEvent(
        RealtimeEvent.fromJson({
          'version': 1,
          'eventId': 'evt-rep-live',
          'eventType': 'node_replaced',
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          'sequence': 10,
          'scope': 'NODE-Q1',
          'payload': {
            'oldNodeId': 'NODE-Q1',
            'replacementNodeId': 'NODE-Q2',
            'fieldId': 'field-1',
            'zoneId': 'zone-1',
            'monitoringPointId': 'point-1',
            'replacedAt': DateTime.now().toUtc().toIso8601String(),
          },
        }),
      );

      final oldNode = notifier.state.nodes.firstWhere((n) => n.id == 'NODE-Q1');
      expect(oldNode.lifecycleState, NodeLifecycleStatus.replaced);
      expect(oldNode.replacedByNodeId, 'NODE-Q2');

      final newNode = notifier.state.nodes.firstWhere((n) => n.id == 'NODE-Q2');
      expect(newNode.lifecycleState, NodeLifecycleStatus.active);
      expect(newNode.replacesNodeId, 'NODE-Q1');
      expect(newNode.assignedZoneId, 'zone-1');
    });
  });
}

