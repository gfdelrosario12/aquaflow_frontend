## 1. Core Realtime & API Layer

- [x] 1.1 Update `RealtimeEvent` in `lib/core/realtime/realtime_events.dart` to support dynamic node scopes and add `nodeStatus`, `transmissionIntervalUpdated`, and `nodeDiscovered` event types
- [x] 1.2 Add DTOs (`Esp32NodeDto`, `NodeRegistrationRequestDto`, `NodeSpatialAssignmentDto`, `TransmissionConfigDto`) in `lib/core/api/api_dtos.dart`
- [x] 1.3 Extend `DeviceApiService` (or add `NodeApiService`) in `lib/core/api/api_services.dart` for node listing, registration, spatial assignment, and interval configuration
- [x] 1.4 Add mapping functions in `lib/core/api/api_mappers.dart` for `Esp32Node`, `SpatialCoordinates`, and `TransmissionConfig`

## 2. Domain Models & Repositories

- [x] 2.1 Create domain models `Esp32Node`, `SpatialCoordinates`, and `TransmissionConfig` in `lib/features/nodes/domain/models/`
- [x] 2.2 Update `DeviceDiagnostic` in `lib/features/diagnostics/domain/models/device_diagnostic.dart` with MAC address, coordinates, and transmission interval fields
- [x] 2.3 Update `MonitoringZone` in `lib/features/zones/domain/models/monitoring_zone.dart` to support a list of assigned node IDs
- [x] 2.4 Create `NodeRepository` interface and dual implementations (`MockNodeRepository` and `ApiNodeRepository`) in `lib/features/nodes/data/repositories/`

## 3. State Management & Realtime Synchronization

- [x] 3.1 Create `NodeManagementNotifier` and `NodeManagementStateData` in `lib/features/nodes/presentation/providers/node_management_notifier.dart`
- [x] 3.2 Register event adapter in `NodeManagementNotifier` to react to `RealtimeCoordinator` events (`nodeMeasurement`, `transmissionIntervalUpdated`)
- [x] 3.3 Create `SpatialFieldNotifier` in `lib/features/nodes/presentation/providers/spatial_field_notifier.dart` managing coordinate scaling, bounds, and selection

## 4. UI Components & Visualizations

- [x] 4.1 Build `SpatialFieldCanvasVisualizer` using `CustomPainter` and `LayoutBuilder` in `lib/features/nodes/presentation/widgets/spatial_field_canvas_visualizer.dart`
- [x] 4.2 Build `NodeMarkerWidget` in `lib/features/nodes/presentation/widgets/node_marker_widget.dart` displaying online status, battery level, and interval pill
- [x] 4.3 Build `NodeRegistrationDialog` in `lib/features/nodes/presentation/widgets/node_registration_dialog.dart` for commissioning discovered nodes
- [x] 4.4 Build `TransmissionIntervalDialog` in `lib/features/nodes/presentation/widgets/transmission_interval_dialog.dart` with role authorization checks (`admin`/`operator` vs `viewer`)

## 5. Screen Integration & Verification

- [x] 5.1 Integrate view mode switcher on `FieldScreen` (`lib/features/field/presentation/field_screen.dart`) to toggle between matrix and spatial canvas
- [x] 5.2 Update `DeviceDiagnosticsScreen` (`lib/features/diagnostics/presentation/device_diagnostics_screen.dart`) with node registration button and interval badges
- [x] 5.3 Update `DeviceDetailDialog` and `ZoneDetailBottomSheet` with spatial coordinates and transmission interval controls
- [x] 5.4 Add unit tests for new models, repositories, and state notifiers, and verify static analysis

