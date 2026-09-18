## Why

The AquaSense prototype assumes a fixed four-quadrant topology (`Q1–Q4`), hardcoding zone codes and four-point arrays across data models, AWD rule evaluation, and UI layouts. Real-world rice paddy Alternate Wetting and Drying (AWD) deployments require arbitrary numbers of monitoring points (e.g., 1, 2, 4, 6, 8, or more) based on paddy geometry, acreage, and topography. Furthermore, physical sensor hardware must be separated from logical observation points so that broken or depleted ESP32 nodes can be replaced, reassigned, or decommissioned without breaking historical observation records or requiring new mobile app builds.

## What Changes

- **Field-Centric Dynamic Topology Domain Model**: Introduce `Field` as the top-level deployment boundary containing dynamic collections of `MonitoringZone`, `MonitoringPoint`, `SensorNode`, `Sensor`, and `Measurement`.
- **Logical Point vs. Physical Node Decoupling**: Separate the physical hardware device (`SensorNode`) from the logical observation station (`MonitoringPoint`). A node can be hot-swapped, serviced, or reassigned while preserving continuous water-level and soil-moisture history for that point.
- **Dynamic Node & Sensor Extensibility**: Model `SensorNode` with hardware identity (MAC/DevEUI, firmware version, battery, RF metrics, lifecycle state) and support multiple extensible `Sensor` transducers per node (ultrasonic water depth, soil moisture at multiple depths, soil temperature, ambient humidity).
- **Node Lifecycle Management**: Formalize lifecycle states for nodes: `discovered`, `provisioning`, `active`, `maintenance`, `offline`, `replaced`, and `decommissioned`.
- **Preservation of Centralized Irrigation Guardrails**: Strictly maintain that `MonitoringZone`, `MonitoringPoint`, and `SensorNode` are purely observational. Irrigation remains centralized at the `Field` level via a single `CentralIrrigationUnit` controlling the main pump and master valve.
- **BREAKING**: Refactor `MonitoringZone` to remove hardcoded `Q1–Q4` quadrant assumptions. Monitoring zones and points now use dynamic alphanumeric codes and labels.
- **Adaptive Visualization Contracts**: Update UI contracts in `monitoring-zones` and `field-dashboard` to accommodate arbitrary counts (1 to 16+ nodes) across mobile and web layouts.

## Capabilities

### New Capabilities
- `field-topology`: Defines the scalable domain aggregate encompassing `Field`, `MonitoringZone`, `MonitoringPoint`, `SensorNode`, `Sensor`, and `Measurement`, including lifecycle states and physical-to-logical point mapping.

### Modified Capabilities
- `monitoring-zones`: Modifies the requirement for fixed four quadrants (Q1–Q4) to support dynamically configured monitoring zones with arbitrary counts, while preserving read-only telemetry and strict prohibition of zone-level irrigation controls.
- `field-dashboard`: Updates field-level comparative visualization from a fixed 4-quadrant layout to an adaptive layout supporting dynamic node counts (1 to 16+ nodes).

## Impact

- **Domain Models**: Introduces `Field`, `MonitoringPoint`, `Sensor`, and `Measurement` models in `lib/features/field/domain/models/` and `lib/features/nodes/domain/models/`. Refactors `MonitoringZone` in `lib/features/zones/domain/models/`.
- **Data Repositories & DTOs**: Updates `ZoneRepository`, `NodeRepository`, and `FieldRepository` to return dynamic topology collections.
- **AWD Rule Engine**: Deprecates hardcoded `zones.length < 4` checks in favor of dynamic quorum and elevation-normalized calculations.
- **UI Components**: Updates `FieldScreen`, `QuadrantGridVisualizer`, and header cards to dynamically render 1 to 16+ nodes.
- **API Contracts**: Establishes `/api/v1/fields/{id}/topology` contract for multi-entity field graph payloads.

