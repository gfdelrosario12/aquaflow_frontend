## 1. Domain Models & Lifecycle State Machine

- [x] 1.1 Add `NodeLifecycleStatus` enum with states (`discovered`, `provisioned`, `active`, `maintenance`, `disabled`, `replaced`, `decommissioned`) and transition validation logic
- [x] 1.2 Update `Esp32Node` and `SensorNode` models with lifecycle status, commissioning token metadata, `replacedByNodeId`, `replacesNodeId`, and audit timestamps
- [x] 1.3 Create `NodeReplacementResult` domain model to represent atomic replacement audit records

## 2. API DTOs, Services & Repositories

- [x] 2.1 Define node lifecycle DTOs (`NodeLifecycleUpdateDto`, `NodeReplacementRequestDto`, `NodeProvisioningRequestDto`) in `api_dtos.dart`
- [x] 2.2 Add lifecycle REST methods to `NodeService` in `api_services.dart` covering registration, provisioning, state transitions, and replacement
- [x] 2.3 Extend `NodeRepository` and `MockNodeRepository` with `transitionLifecycle`, `replaceNode`, `provisionNode`, and `decommissionNode` methods
- [x] 2.4 Add mapper functions in `api_mappers.dart` converting lifecycle DTOs to domain entities

## 3. State Management & Real-time Integration

- [x] 3.1 Update `NodeManagementNotifier` to support lifecycle state operations, error handling, and role-based permission checks
- [x] 3.2 Ensure `NodeManagementNotifier` and `SpatialFieldNotifier` maintain historical measurement continuity on the monitoring zone during node replacement
- [x] 3.3 Add real-time event listeners for `nodeLifecycleUpdated` and `nodeReplaced` to reflect backend changes dynamically

## 4. UI Components & Dialogs

- [x] 4.1 Create `NodeReplacementDialog` for authorized operators to select a replacement node, review target zone, and execute atomic swap
- [x] 4.2 Update `DeviceDetailDialog` and `DeviceDiagnosticsScreen` with lifecycle status chips, maintenance toggles, and replacement entrypoints
- [x] 4.3 Update `ZoneDetailBottomSheet` and `NodeMarkerWidget` to reflect node lifecycle states (e.g. maintenance badges) and hide mutation actions from `viewer` users

## 5. Verification & Testing

- [x] 5.1 Write unit tests for `NodeLifecycleStatus` transition rules and invalid state rejection
- [x] 5.2 Write repository and notifier unit tests for atomic node replacement ensuring historical measurements remain intact
- [x] 5.3 Write widget tests for `NodeReplacementDialog` and role-based lifecycle controls
- [x] 5.4 Execute full test suite (`flutter test`) and static analysis (`dart analyze`) to confirm zero regressions
