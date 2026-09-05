## Context

AquaSense deployed hardware comprises four independent quadrant monitoring nodes (Q1–Q4), one central LoRaWAN field gateway, and one centralized field irrigation controller. The app requires a dedicated Device Diagnostics & System Health feature (`lib/features/diagnostics/`). See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Implement `DeviceDiagnostic` domain model, `DeviceCategory` (`sensorNode`, `gateway`, `centralController`), and `DeviceHealthStatus` (`healthy`, `degraded`, `offline`, `stale`, `error`).
- Build `DiagnosticsRepository` and `MockDiagnosticsRepository` providing comprehensive health telemetry and RF signal quality metrics (RSSI, SNR, battery voltage/percentage, last seen, last measurement).
- Build `DeviceDiagnosticsScreen` featuring:
  - System Health Overview Header (Overall status, online count, warning indicators).
  - Quadrant Monitoring Nodes Section (Q1, Q2, Q3, Q4 read-only telemetry health cards).
  - Field LoRaWAN Gateway Section (Uptime, packet loss, cellular backhaul link).
  - Central Irrigation Controller Section (Online status, pump state, valve state, last command outcome, fixed scope `ENTIRE FIELD`).
- Build `DeviceDetailDialog` displaying full hardware specs, raw RF telemetry metrics, and troubleshooting steps.
- Handle state variations: loading, empty device list, stale telemetry warnings, and communication errors using design system components.

**Non-Goals:**
- Direct hardware OTA (Over-The-Air) firmware flashing or BLE pairing (mock repository abstractions simulate gateway/node API contracts).
- Creating individual quadrant-level irrigation controllers (Q1–Q4 remain strictly read-only monitoring nodes).

## Decisions

### 1. Diagnostic Domain Schema & Target Scope Isolation
- **Decision**: `DeviceDiagnostic` explicitly includes `targetScope` (`ENTIRE FIELD` for central controller & gateway vs `Q1`–`Q4` for sensor nodes).
- **Rationale**: Reinforces architectural boundaries preventing operators from mistaking telemetry nodes for independent irrigation actuators.

### 2. State Notifier Architecture
- **Decision**: `DiagnosticsNotifier` (ChangeNotifier) manages data fetching, periodic health polling, category filtering, and selected device detail state.
- **Rationale**: Guarantees reactive UI updates when node battery levels drop or heartbeats miss.

### 3. UI Sectioning & Health Badging
- **Decision**: Use `StatusBadge.deviceStatus` with color-coded severity indicators (`green` for Healthy, `amber` for Degraded/Stale, `red` for Offline/Error).
- **Rationale**: Delivers instant visual feedback for field operators assessing hardware reliability.

## Risks / Trade-offs

- **[Risk: RF signal fluctuations causing brief RSSI/SNR drops]** → *Mitigation*: Diagnostic engine classifies temporary RSSI dips as `Degraded` rather than immediately marking the node `Offline` until 3 consecutive heartbeats are missed.
- **[Risk: Misinterpreting node telemetry diagnostics as zone control]** → *Mitigation*: Node diagnostic tiles state "Read-Only Telemetry Node", while the Central Controller card provides a direct link to the Central Control screen.

