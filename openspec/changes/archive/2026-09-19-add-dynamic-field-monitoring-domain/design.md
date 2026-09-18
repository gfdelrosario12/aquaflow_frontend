## Context

The current prototype in `aquaflow_frontend` models field monitoring around four quadrant zones (`Q1`, `Q2`, `Q3`, `Q4`) defined in `lib/features/zones/domain/models/monitoring_zone.dart`. While the recent `dynamic-esp32-node-management` change introduced an initial `Esp32Node` entity, monitoring telemetry remains conflated between zones and physical devices. In real-world rice cultivation with Alternate Wetting and Drying (AWD), fields range from small test plots (1–2 monitoring tubes) to expansive multi-terrace farms (6–16+ monitoring tubes). Furthermore, physical sensor hardware is vulnerable to water intrusion, battery depletion, or physical damage, requiring frequent hot-swapping in the field without breaking the historical observation record of the tube installation.

## Goals / Non-Goals

**Goals:**
- Establish a scalable, normalized domain model: `Field` (aggregate root) containing `MonitoringZone`, `MonitoringPoint`, `SensorNode`, `Sensor`, and `Measurement`.
- Decouple the physical hardware (`SensorNode`) from the logical observation station (`MonitoringPoint`) to support device replacement and maintenance without historical data fragmentation.
- Support dynamic node counts (1 to 16+ nodes) without hardcoded quadrant identifiers or application rebuilds.
- Provide extensible multi-sensor support per node (tube water depth, multi-depth soil moisture, soil temperature, humidity, battery metrics).
- Implement a formal hardware lifecycle state machine (`discovered`, `provisioning`, `active`, `maintenance`, `offline`, `replaced`, `decommissioned`).
- Strictly enforce centralized irrigation guardrails: monitoring zones, points, and nodes are observational only; all irrigation actuation remains centralized at the field level.

**Non-Goals:**
- Rewriting the AWD analytics rule engine algorithm to calculate multi-point spatial weights (scoped to the follow-up change `variable-node-awd-engine`).
- Re-architecting all UI layouts and grid visualizers (scoped to `scalable-responsive-field-ui`).
- Backend database schema implementation (this change defines client-side models, DTOs, mappers, and repository interfaces).

## Decisions

### 1. Separation of `MonitoringPoint` and `SensorNode`
- **Decision**: Introduce `MonitoringPoint` as a distinct logical entity representing the physical field installation (tube datum, GPS/Cartesian coordinates, elevation offset), while `SensorNode` represents the electronic device mounted at that point (MAC, firmware, battery, radio).
- **Alternatives Considered**: Combining location and device into a single `Esp32Node` entity.
- **Rationale**: In agricultural IoT, sensor enclosures are frequently repaired or swapped. If device identity is merged with location, swapping an ESP32 destroys or fragments historical water depth charts for that station. Decoupling ensures point telemetry remains continuous.

### 2. Field Aggregate Root Pattern
- **Decision**: Model `Field` as the top-level aggregate root managing its topology:
  ```
  Field (1) ──▶ (N) MonitoringZone (1) ──▶ (N) MonitoringPoint (0..1) ──▶ (0..1) SensorNode (1) ──▶ (N) Sensor
  ```
- **Alternatives Considered**: Flat, unassociated collections of zones and devices.
- **Rationale**: AWD management, water balance, and irrigation actuation are strictly field-level concerns. Modeling `Field` as an aggregate root guarantees consistency across all contained zones and points.

### 3. Extensible Multi-Sensor Architecture
- **Decision**: Model `Sensor` as an individual transducer channel belonging to a `SensorNode`, outputting time-stamped `Measurement` records with calibration offsets and quality flags.
- **Alternatives Considered**: Adding fixed properties (`soilMoisture15cm`, `soilMoisture30cm`, `waterLevelCm`) directly onto the node class.
- **Rationale**: Future field deployments may introduce weather stations, water electrical conductivity (salinity) probes, or soil redox sensors. An extensible sensor list prevents continuous domain refactoring. Convenience getters on `SensorNode` will provide easy access to primary water depth and moisture metrics.

### 4. Dynamic Alphanumeric Identifiers
- **Decision**: Replace the `ZoneCode` enum (`q1`, `q2`, `q3`, `q4`) with dynamic alphanumeric string codes (`code: "Z1"`, `"Z2"`, `"P01"`).
- **Alternatives Considered**: Extending the enum to `q1` through `q16`.
- **Rationale**: Hardcoded enums require mobile application rebuilds whenever field configurations change. Dynamic strings permit backend-driven field provisioning without client updates.

## Architecture & Entity Class Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│                                 FIELD                                  │
│ ────────────────────────────────────────────────────────────────────── │
│ + id: String                                                           │
│ + name: String                                                         │
│ + boundaryPolygon: List<GeoPoint>                                      │
│ + areaSquareMeters: double                                             │
│ + activeCropStage: CropStage                                           │
│ + awdProfileId: String                                                 │
│ + zones: List<MonitoringZone>                                          │
│ + centralControllerId: String                                          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ 1..N
┌───────────────────────────────────▼────────────────────────────────────┐
│                            MONITORING ZONE                             │
│ ────────────────────────────────────────────────────────────────────── │
│ + id: String                                                           │
│ + fieldId: String                                                      │
│ + code: String                                                         │
│ + name: String                                                         │
│ + spatialWeight: double                                                │
│ + points: List<MonitoringPoint>                                        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ 1..N
┌───────────────────────────────────▼────────────────────────────────────┐
│                            MONITORING POINT                            │
│ ────────────────────────────────────────────────────────────────────── │
│ + id: String                                                           │
│ + zoneId: String                                                       │
│ + label: String                                                        │
│ + coordinates: SpatialCoordinates                                      │
│ + relativeElevationCm: double                                          │
│ + tubeDatumOffsetCm: double                                            │
│ + assignedNodeId: String?                                              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ 0..1 (Mount)
┌───────────────────────────────────▼────────────────────────────────────┐
│                              SENSOR NODE                               │
│ ────────────────────────────────────────────────────────────────────── │
│ + id: String                                                           │
│ + macAddress: String (or devEui)                                       │
│ + hardwareRevision: String                                             │
│ + firmwareVersion: String                                              │
│ + lifecycleState: NodeLifecycleState                                   │
│ + batteryPercent: int?                                                 │
│ + batteryVoltage: double?                                              │
│ + rssiDbm: int?                                                        │
│ + snrDb: double?                                                       │
│ + transmissionConfig: TransmissionConfig                               │
│ + sensors: List<Sensor>                                                │
│ + lastHeartbeat: DateTime                                              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ 1..N
┌───────────────────────────────────▼────────────────────────────────────┐
│                                SENSOR                                  │
│ ────────────────────────────────────────────────────────────────────── │
│ + id: String                                                           │
│ + nodeId: String                                                       │
│ + type: SensorType                                                     │
│ + channelIndex: int                                                    │
│ + unit: String                                                         │
│ + depthOffsetCm: double?                                               │
│ + latestMeasurement: Measurement?                                      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ 1..N
┌───────────────────────────────────▼────────────────────────────────────┐
│                             MEASUREMENT                                │
│ ────────────────────────────────────────────────────────────────────── │
│ + timestamp: DateTime                                                  │
│ + sensorId: String                                                     │
│ + pointId: String                                                      │
│ + rawValue: double                                                     │
│ + calibratedValue: double                                              │
│ + qualityFlag: MeasurementQuality                                      │
└────────────────────────────────────────────────────────────────────────┘
```

## Risks / Trade-offs

- **[Risk] Existing UI and tests expect `MonitoringZone.code` to be `Q1–Q4`** → **Mitigation**: Implement convenience getters and a backward-compatible adapter layer so existing test suites and UI widgets can continue to render while transitioning to dynamic collections.
- **[Risk] Increased complexity in state management** → **Mitigation**: Provide repository methods that return either flat lists of nodes/points or the fully resolved `FieldTopology` tree, keeping component consumption ergonomic.
- **[Risk] Performance overhead when rendering many points** → **Mitigation**: Cache normalized spatial coordinates on `MonitoringPoint` and memoize visual markers on the canvas.

## Migration Plan

1. **Step 1: Domain Entities**: Create `Field`, `MonitoringPoint`, `Sensor`, `Measurement`, and `NodeLifecycleState` models alongside updated `MonitoringZone` and `Esp32Node`.
2. **Step 2: API DTOs & Mappers**: Create DTO representations (`FieldDto`, `MonitoringPointDto`, `SensorDto`, `MeasurementDto`, `FieldTopologyDto`) in `lib/core/api/`.
3. **Step 3: Repository Interfaces & Implementations**: Implement `FieldRepository` and extend `NodeRepository` and `ZoneRepository` to support dynamic query operations.
4. **Step 4: Mock Data & Seed Updates**: Update mock datasets with realistic multi-point topologies (e.g., 2-point, 4-point, and 8-point field configurations).
5. **Step 5: Verification**: Add thorough unit tests verifying entity serialization, lifecycle transitions, physical-to-logical point assignment, and read-only guardrails.

