## Why

The AquaSense frontend currently couples telemetry monitoring strictly to four static quadrant sensors (Q1–Q4) with hardcoded identifiers and a rigid 2x2 grid layout. In real-world agricultural deployments, fields require dynamic ESP32 IoT node commissioning, multi-node deployments across custom irrigation zones, spatial placement (GPS coordinates and local Cartesian field X/Y coordinates), and flexible telemetry reporting intervals that adapt automatically to environmental dry-down events or battery preservation strategies.

Introducing dynamic ESP32 IoT node management and spatial field monitoring transitions AquaSense from a static quad-zone prototype into a production-grade, spatially-aware precision irrigation frontend while preserving strict safety guardrails that isolate monitoring telemetry from centralized irrigation actuation.

## What Changes

- **Dynamic ESP32 Node Lifecycle**: Support discovery of unassigned ESP32 nodes over backend-mediated channels, operator-guided node registration, and editing of node display names and operational metadata.
- **Field & Zone Association**: Allow operators to bind dynamic nodes to specific agricultural fields and irrigation/monitoring zones, supporting multi-node topologies per zone.
- **Spatial Positioning Coordinates**: Model, store, and display dual spatial coordinates for each node: geographic coordinates (latitude, longitude, elevation) and field-local Cartesian coordinates (X, Y in meters relative to field origin).
- **Spatial 2D Field Visualization**: Implement an interactive 2D spatial field visualizer displaying field boundaries, zone partitions, and node placement pins with live health, signal, and moisture status indicators.
- **Transmission Interval Management**: Display current node transmission intervals (e.g., 30s, 60s, 300s, 900s), enable authorized operators (`admin` and `operator` roles) to configure intervals, and restrict unauthorized `viewer` roles.
- **Real-Time Adaptive Interval Reflection**: Ingest and reflect backend-driven adaptive transmission rate changes in real time via WebSocket events, surfacing adaptive reason indicators and automated interval transitions.
- **Expanded Real-Time Event Validation**: Generalize the real-time event pipeline to accept dynamic node IDs in event scopes alongside legacy `Q1–Q4` scopes.

## Capabilities

### New Capabilities
- `node-management`: Dynamic ESP32 node discovery, registration, field/zone assignment, manual transmission interval configuration, and live tracking of adaptive interval states.
- `spatial-field-monitoring`: Dual spatial coordinate representations (GPS WGS84 and local Cartesian X/Y meters), interactive 2D spatial field canvas rendering, and node position visualization.

### Modified Capabilities
- `monitoring-zones`: Extend zone models and views to support dynamic assignment of multiple sensor nodes per zone and spatial positioning while preserving strict read-only isolation from irrigation controls.
- `device-diagnostics`: Expand hardware diagnostic views and state management to list dynamically registered ESP32 nodes, their transmission intervals, and coordinate metadata alongside gateway and central controller health.
- `realtime-updates`: Extend event schemas, typed event coverage, and scope validation to support dynamic node identifiers, node status transitions, and transmission interval update events.

## Impact

- **Domain Models**: Introduces `Esp32Node`, `SpatialCoordinates`, and `TransmissionConfig` models; updates `DeviceDiagnostic` and `MonitoringZone`.
- **API & Repositories**: Adds `NodeApiService` (or extends `DeviceApiService`), `NodeRepository`, and DTOs for node registration, spatial assignment, and interval configuration.
- **Real-Time Transport**: Expands `RealtimeEvent` validation to accept dynamic node aggregate keys and adds `nodeStatus` and `transmissionIntervalUpdated` event types.
- **Presentation UI**: Adds spatial field canvas visualizer in `FieldScreen`, node registration modal, transmission interval configuration dialog, and updates `DeviceDiagnosticsScreen` and `ZoneDetailBottomSheet`.
- **Dependencies**: No external native plugins required; uses pure Flutter custom canvas painting (`CustomPainter` / `LayoutBuilder`) and existing core design system widgets.

