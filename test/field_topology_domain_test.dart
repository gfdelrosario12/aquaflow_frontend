import 'package:aquaflow_frontend/core/api/api_mappers.dart';
import 'package:aquaflow_frontend/features/field/data/repositories/field_repository.dart';
import 'package:aquaflow_frontend/features/field/domain/models/field.dart';
import 'package:aquaflow_frontend/features/nodes/domain/models/models.dart';
import 'package:aquaflow_frontend/features/zones/domain/models/monitoring_zone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Field Topology Domain Entities & Serialization (Task 5.1)', () {
    test('Field model serializes and deserializes correctly', () {
      final now = DateTime.now();
      final field = Field(
        id: 'fld-test-01',
        name: 'Experimental Paddy Alpha',
        description: 'Test AWD field for precision water management',
        areaSquareMeters: 8500.0,
        soilType: 'Silt Clay',
        activeCropStage: CropStage.panicleInitiation,
        awdProfileId: 'awd_profile_panicle',
        centralControllerId: 'pump-station-01',
        boundaryCoordinates: const [
          {'latitude': 14.1500, 'longitude': 121.2400},
          {'latitude': 14.1520, 'longitude': 121.2405},
        ],
        createdAt: now,
        updatedAt: now,
      );

      final json = field.toJson();
      final restored = Field.fromJson(json);

      expect(restored.id, 'fld-test-01');
      expect(restored.name, 'Experimental Paddy Alpha');
      expect(restored.areaSquareMeters, 8500.0);
      expect(restored.soilType, 'Silt Clay');
      expect(restored.activeCropStage, CropStage.panicleInitiation);
      expect(restored.centralControllerId, 'pump-station-01');
      expect(restored.boundaryCoordinates.length, 2);

      // Verify ApiMapper round-trip
      final dto = ApiMappers.fieldDto(field);
      final mappedField = ApiMappers.field(dto);
      expect(mappedField.id, field.id);
      expect(mappedField.activeCropStage, field.activeCropStage);
    });

    test('MonitoringPoint model captures spatial and tube datum offsets', () {
      const point = MonitoringPoint(
        id: 'pt-01',
        fieldId: 'fld-test-01',
        zoneId: 'zn-north',
        code: 'P01',
        label: 'Observation Tube Northwest',
        coordinates: SpatialCoordinates(
          latitude: 14.1510,
          longitude: 121.2402,
          localX: 20.0,
          localY: 45.0,
          elevationMeters: 19.2,
        ),
        relativeElevationCm: 1.2,
        tubeDatumOffsetCm: 18.5,
        assignedNodeId: 'node-esp-01',
      );

      expect(point.hasAssignedNode, isTrue);
      expect(point.relativeElevationCm, 1.2);
      expect(point.tubeDatumOffsetCm, 18.5);

      final json = point.toJson();
      final restored = MonitoringPoint.fromJson(json);
      expect(restored.code, 'P01');
      expect(restored.assignedNodeId, 'node-esp-01');
      expect(restored.coordinates?.localX, 20.0);

      // Verify ApiMappers
      final dto = ApiMappers.monitoringPointDto(point);
      final mapped = ApiMappers.monitoringPoint(dto);
      expect(mapped.id, point.id);
      expect(mapped.tubeDatumOffsetCm, 18.5);
    });

    test('Sensor and Measurement models preserve channel and calibration data', () {
      final now = DateTime.now();
      final measurement = Measurement(
        id: 'meas-101',
        timestamp: now,
        sensorId: 'sens-ultrasonic-01',
        pointId: 'pt-01',
        rawValue: 12.4,
        calibratedValue: -6.1, // -6.1 cm perched water table
        qualityFlag: MeasurementQuality.valid,
      );

      final sensor = Sensor(
        id: 'sens-ultrasonic-01',
        nodeId: 'node-esp-01',
        type: SensorType.waterLevelTube,
        channelIndex: 0,
        unit: 'cm',
        depthOffsetCm: 0.0,
        calibrationCoefficients: const {'slope': 1.0, 'intercept': -18.5},
        latestMeasurement: measurement,
      );

      expect(sensor.latestValue, -6.1);
      expect(sensor.type, SensorType.waterLevelTube);

      final json = sensor.toJson();
      final restored = Sensor.fromJson(json);
      expect(restored.id, sensor.id);
      expect(restored.latestValue, -6.1);
      expect(restored.calibrationCoefficients?['intercept'], -18.5);

      // Verify ApiMappers
      final dto = ApiMappers.sensorDto(sensor);
      final mapped = ApiMappers.sensor(dto);
      expect(mapped.latestValue, -6.1);
    });
  });

  group('SensorNode Lifecycle State Transitions (Task 5.2)', () {
    test('transitions through discovered, provisioning, active, and offline', () {
      final now = DateTime.now();

      // 1. Node newly discovered by LoRa gateway beacon
      final discoveredNode = Esp32Node(
        id: 'node-disc-01',
        macAddress: 'A4:CF:12:00:11:22',
        displayName: 'Unclaimed Node',
        lifecycleState: NodeLifecycleState.discovered,
        transmissionConfig: TransmissionConfig(
          intervalSeconds: 300,
          lastConfiguredAt: DateTime.now(),
        ),
        isOnline: true,
        lastSeen: now,
      );
      expect(discoveredNode.lifecycleState, NodeLifecycleState.discovered);
      expect(discoveredNode.assignedPointId, isNull);

      // 2. Node claimed and entering provisioning
      final provisioningNode = discoveredNode.copyWith(
        displayName: 'North Inflow Node',
        assignedFieldId: 'fld-test-01',
        assignedZoneId: 'zn-north',
        assignedPointId: 'pt-01',
        lifecycleState: NodeLifecycleState.provisioning,
      );
      expect(provisioningNode.lifecycleState, NodeLifecycleState.provisioning);
      expect(provisioningNode.assignedPointId, 'pt-01');

      // 3. Node confirmed active and streaming
      final activeNode = provisioningNode.copyWith(
        lifecycleState: NodeLifecycleState.active,
        batteryPercent: 98,
        waterLevelCm: 3.5,
      );
      expect(activeNode.lifecycleState, NodeLifecycleState.active);
      expect(activeNode.isOnline, isTrue);

      // 4. Node misses heartbeats and goes offline
      final offlineNode = activeNode.copyWith(
        lifecycleState: NodeLifecycleState.offline,
        isOnline: false,
      );
      expect(offlineNode.lifecycleState, NodeLifecycleState.offline);
      expect(offlineNode.isOnline, isFalse);
    });
  });

  group('Physical Node Replacement & Continuity (Task 5.3)', () {
    test('swapping physical nodes maintains MonitoringPoint continuity', () async {
      final repo = MockFieldRepository(activePreset: '2-point');
      final initialTopology = await repo.fetchFieldTopology('field-maligaya-01');

      final point1 = initialTopology.findPoint('point-01')!;
      final oldNodeId = point1.assignedNodeId!;
      expect(oldNodeId, 'node-01');

      // Register new replacement hardware
      final newNode = Esp32Node(
        id: 'node-new-replacement',
        macAddress: '78:E3:6D:99:99:99',
        displayName: 'Replacement Node V2',
        transmissionConfig: TransmissionConfig(
          intervalSeconds: 300,
          lastConfiguredAt: DateTime.now(),
        ),
        isOnline: true,
        lastSeen: DateTime.now(),
        lifecycleState: NodeLifecycleState.discovered,
      );

      // Execute node replacement on the point
      final updatedPoint = await repo.replaceNodeAtPoint(
        pointId: 'point-01',
        oldNodeId: oldNodeId,
        newNodeId: newNode.id,
      );

      // Point identity, code, and datum remain identical
      expect(updatedPoint.id, 'point-01');
      expect(updatedPoint.code, 'P01');
      expect(updatedPoint.tubeDatumOffsetCm, 18.0);
      expect(updatedPoint.assignedNodeId, 'node-new-replacement');

      // Verify topology query reflects new assignment
      final updatedTopology = await repo.fetchFieldTopology('field-maligaya-01');
      final fetchedPoint = updatedTopology.findPoint('point-01')!;
      expect(fetchedPoint.assignedNodeId, 'node-new-replacement');
    });
  });

  group('Legacy Adapters & Guardrail Verification (Tasks 4.1 & 4.2)', () {
    test('MonitoringZone.fromPointAndNode produces valid legacy zone view', () {
      const point = MonitoringPoint(
        id: 'pt-05',
        fieldId: 'fld-01',
        zoneId: 'zn-05',
        code: 'P05',
        label: 'Field Edge 5',
      );

      final node = Esp32Node(
        id: 'esp-05',
        macAddress: '11:22:33:44:55:66',
        displayName: 'ESP32 Node 5',
        transmissionConfig: TransmissionConfig(
          intervalSeconds: 300,
          lastConfiguredAt: DateTime.now(),
        ),
        isOnline: true,
        lastSeen: DateTime.now(),
        waterLevelCm: -12.5,
        soilMoisturePercent: 18.0,
      );

      final legacyZone = MonitoringZone.fromPointAndNode(point: point, node: node);
      expect(legacyZone.code, 'P05');
      expect(legacyZone.waterLevelCm, -12.5);
      expect(legacyZone.status, ZoneStatus.critical); // due to waterLevel < -10
      expect(legacyZone.isOnline, isTrue);
      expect(legacyZone.assignedNodeIds, contains('esp-05'));
    });

    test('FieldTopology.toLegacyZones handles variable node topologies', () async {
      final repo8 = MockFieldRepository(activePreset: '8-point');
      final topology8 = await repo8.fetchFieldTopology('field-maligaya-01');

      final legacyZones = topology8.toLegacyZones();
      expect(legacyZones.length, greaterThanOrEqualTo(4));
    });
  });
}
