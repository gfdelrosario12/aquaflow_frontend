## 1. Domain Models & Enums

- [x] 1.1 Create `NodeLifecycleState` and `SensorType` enums in `lib/features/nodes/domain/models/node_enums.dart`
- [x] 1.2 Create `MeasurementQuality` enum and `Measurement` domain model in `lib/features/nodes/domain/models/measurement.dart`
- [x] 1.3 Create `Sensor` domain model in `lib/features/nodes/domain/models/sensor.dart` supporting individual channels, units, and calibration offsets
- [x] 1.4 Create `MonitoringPoint` domain model in `lib/features/nodes/domain/models/monitoring_point.dart` with spatial coordinates, elevation offset, and tube datum
- [x] 1.5 Update `Esp32Node` in `lib/features/nodes/domain/models/esp32_node.dart` with hardware revision, lifecycle state, and extensible sensor list
- [x] 1.6 Create `Field` domain model and `CropStage` enum in `lib/features/field/domain/models/field.dart`
- [x] 1.7 Refactor `MonitoringZone` in `lib/features/zones/domain/models/monitoring_zone.dart` to support dynamic alphanumeric codes, spatial weights, and point references

## 2. API Data Transfer Objects & Mappers

- [x] 2.1 Define `MeasurementDto`, `SensorDto`, and `MonitoringPointDto` in `lib/core/api/api_dtos.dart`
- [x] 2.2 Define `FieldDto` and `FieldTopologyDto` in `lib/core/api/api_dtos.dart`
- [x] 2.3 Implement bidirectional mappers for `Field`, `MonitoringPoint`, `Sensor`, and `Measurement` in `lib/core/api/api_mappers.dart`
- [x] 2.4 Add field topology endpoints to `api_services.dart` and expose through `ApiClient`

## 3. Repositories & Mock Datasets

- [x] 3.1 Create `FieldRepository` interface in `lib/features/field/data/repositories/field_repository.dart`
- [x] 3.2 Implement `MockFieldRepository` with realistic 2-point, 4-point, and 8-point field topology presets
- [x] 3.3 Update `NodeRepository` and `ZoneRepository` to support dynamic point queries and physical node replacement

## 4. Compatibility & Guardrail Verification

- [x] 4.1 Implement legacy adapter on `Field` enabling existing views (`QuadrantGridVisualizer`, `FieldHeaderOverviewCard`) to consume dynamic points safely
- [x] 4.2 Verify read-only guardrails: ensure monitoring points and nodes contain zero irrigation actuation triggers

## 5. Testing & Static Analysis

- [x] 5.1 Add unit tests for `Field`, `MonitoringPoint`, `Sensor`, and `Measurement` serialization and domain logic
- [x] 5.2 Add unit tests for `SensorNode` lifecycle state transitions (`discovered`, `provisioning`, `active`, `offline`)
- [x] 5.3 Add unit tests verifying physical node replacement preserves `MonitoringPoint` measurement continuity
- [x] 5.4 Run static analysis (`dart analyze`) to confirm zero lint errors
