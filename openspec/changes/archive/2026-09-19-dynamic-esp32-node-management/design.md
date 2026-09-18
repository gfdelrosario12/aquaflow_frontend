## Context

The AquaSense Flutter frontend models field telemetry using `ChangeNotifier` providers, an authenticated HTTP `ApiClient`, and a WebSocket-based `RealtimeCoordinator`. Currently, hardware nodes and telemetry zones are conflated into four static quadrants (`Q1`–`Q4`) represented by `MonitoringZone` and static `DeviceDiagnostic` records. Centralized irrigation remains strictly isolated from monitoring nodes. For detailed motivation, see [proposal.md](proposal.md).

## Goals / Non-Goals

**Goals:**
- Decouple physical IoT hardware (`Esp32Node`) from administrative monitoring zones (`MonitoringZone`), allowing dynamic node commissioning and multi-node zone topologies.
- Support dual spatial coordinates: WGS84 geographic coordinates (latitude, longitude) and local Cartesian field offsets (X, Y meters from field origin).
- Deliver an interactive 2D spatial canvas visualizer (`SpatialFieldCanvasVisualizer`) that plots node positions, signal quality, online/offline status, and moisture levels.
- Provide transmission interval management (display, operator configuration dialog, and real-time reflection of backend-driven adaptive rate adjustments).
- Enforce role-based access control: only `admin` and `operator` roles may configure transmission intervals; `viewer` roles are restricted to read-only viewing.
- Generalize `RealtimeEvent` validation to accept dynamic node IDs as monitoring scopes.

**Non-Goals:**
- Direct mobile-to-hardware communication (no direct BLE, LoRaWAN, or MQTT client in Flutter; all communication remains strictly backend-mediated).
- Zone-level pump or valve activation controls (strict architectural rule: irrigation controls remain centralized on `ControlScreen`).
- Third-party satellite map dependencies (e.g., Google Maps SDK or Mapbox) that require external API keys or heavy native footprints; a pure Flutter canvas handles agricultural field coordinates with full offline capability.

## Decisions

### Decision 1: Pure Flutter CustomPainter vs. Heavy Map SDK
- **Choice**: Implement `SpatialFieldCanvasVisualizer` using Flutter's `CustomPainter` with an interactive gesture layer (`InteractiveViewer` / `LayoutBuilder`).
- **Rationale**: Keeps the application lightweight, fully offline-compatible, and free of proprietary map keys. It supports relative Cartesian meter coordinates `(X, Y)` directly and normalizes geographic bounding boxes `(lat, lng)` to local viewport coordinates.
- **Alternatives Considered**: `google_maps_flutter` (requires API keys, lacks offline capability, introduces heavy native dependencies) and `flutter_map` with OpenStreetMap (requires network tiles, less suited for relative meter-based field dimensions).

### Decision 2: Decoupled Entity Architecture (`Esp32Node` vs. `MonitoringZone`)
- **Choice**: Introduce a dedicated `Esp32Node` domain model in `lib/features/nodes/domain/models/esp32_node.dart`. A `MonitoringZone` references one or more assigned node IDs (`assignedNodeIds`).
- **Rationale**: Physical hardware devices (with battery voltage, RSSI, SNR, MAC address, and firmware) are distinct from agricultural field zones. This enables reassigning nodes between zones and placing multiple sensors in large zones.
- **Alternatives Considered**: Adding more fields directly to `MonitoringZone` (rejected: perpetuates 1:1 coupling and breaks when a zone has 0 or multiple sensor nodes).

### Decision 3: Real-Time Adaptive Interval Reflection via `RealtimeCoordinator`
- **Choice**: Add `transmissionIntervalUpdated` to `RealtimeEventType` and register an adapter inside `NodeManagementNotifier` to ingest adaptive events.
- **Rationale**: Piggybacks on existing deduplication, sequence validation, and lifecycle-aware reconnects in `RealtimeCoordinator`. Nodes reactively transition their active interval and display the adaptation reason banner without full-page reloads.
- **Alternatives Considered**: Polling `/api/nodes/{id}` (rejected: high latency, causes battery drain and misses fast adaptive rate changes).

### Decision 4: Role Authorization Pattern
- **Choice**: Inspect `UserSession.role` against `ControlUserRole.viewer` prior to opening the configuration dialog or enabling the submit button.
- **Rationale**: Reuses the exact authorization pattern established in `CentralControlProvider` and `ControlConfirmationDialog`.

## Risks / Trade-offs

- **[Risk] Backward compatibility with existing Q1–Q4 tests and mock repositories**
  → *Mitigation*: Seed dynamic mock nodes that map to default quadrants (`NODE-Q1` through `NODE-Q4`) so existing diagnostic and zone tests pass unchanged while supporting new dynamic additions.
- **[Risk] Unplaced nodes without coordinates**
  → *Mitigation*: The spatial visualizer will display an "Unplaced Nodes" chip drawer at the top of the canvas, allowing operators to select and assign coordinates to unplaced nodes directly on the canvas.
- **[Risk] High-frequency real-time telemetry updates causing UI stutter**
  → *Mitigation*: Use immutable state models with fine-grained `ChangeNotifier` updates and `RepaintBoundary` around the canvas painter.

## Migration Plan

1. **Core Realtime & API Expansion**: Update `RealtimeEvent`, DTOs, and API services first with backward-compatible fallbacks.
2. **Domain Models & Repositories**: Implement `Esp32Node`, `SpatialCoordinates`, `TransmissionConfig`, and `NodeRepository`.
3. **State Management**: Create `NodeManagementNotifier` and wire into `AppShell` / `DiagnosticsNotifier`.
4. **UI Integration**: Add spatial visualizer tab in `FieldScreen`, update `DeviceDiagnosticsScreen` with node registration and interval actions, and update `ZoneDetailBottomSheet`.

