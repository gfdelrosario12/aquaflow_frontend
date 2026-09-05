## Why

AquaSense requires system health monitoring and device management across all deployed physical hardware components. Providing field operators with detailed diagnostics for the four monitoring sensor nodes (Q1–Q4), the LoRaWAN gateway, and the single centralized field irrigation controller ensures quick identification of battery degradation, communication link issues, offline hardware, and controller faults.

## What Changes

- **Device Management & Diagnostics View**: Enhance `SettingsScreen` or introduce `DeviceManagementScreen` displaying real-time system health and diagnostic cards for sensor nodes Q1–Q4, the LoRaWAN gateway, and the central irrigation controller.
- **Monitoring Node Diagnostics (Q1–Q4)**: Display online/offline state, battery level (voltage & percentage), RSSI, SNR, last seen timestamp, last measurement, communication link quality, and health badge (`healthy`, `degraded`, `offline`, `stale`, `error`).
- **Gateway Diagnostics**: Display connectivity status, last communication timestamp, network uplink/downlink status, packet retransmission rate, and gateway health.
- **Central Irrigation Controller Diagnostics**: Display online/offline state, main pump status, distribution valve status, last dispatched command, command outcome result, last communication timestamp, and fixed target scope (`ENTIRE FIELD`).
- **Strict Scope Isolation**: Explicitly separate read-only telemetry node diagnostics from centralized irrigation controller diagnostics. Never create independent quadrant-level irrigation controllers.
- **State Handling**: Provide loading, empty list, stale telemetry warning, and gateway error presentation states.

## Capabilities

### New Capabilities
- `device-diagnostics`: Provides system health monitoring, diagnostic inspection, communication telemetry, and hardware state tracking across Q1–Q4 monitoring nodes, the LoRaWAN gateway, and the centralized irrigation controller.

## Impact

- **UI Components**: `lib/features/diagnostics/presentation/device_diagnostics_screen.dart`, device detail dialogs, diagnostic status badges.
- **Domain Layer**: `lib/features/diagnostics/domain/models/` (`DeviceDiagnostic`, `DeviceHealthStatus`, `DeviceType`).
- **Data Layer**: `lib/features/diagnostics/data/repositories/` abstraction and mock repository representing hardware telemetry diagnostics.
- **App Navigation**: Navigation entry points from `SettingsScreen` and `MobileAppShell`.

