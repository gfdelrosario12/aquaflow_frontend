## Why

Field operators need a dedicated Field Monitoring view (AquaSense Field Monitoring experience) to continuously monitor and compare conditions across the four independent field quadrants Q1, Q2, Q3, and Q4. Operators must inspect key telemetry metrics including water level, soil moisture, sensor connection state, battery percentage, signal diagnostics (RSSI and SNR), and last measurement timestamp without confusing monitoring zones with irrigation activation units.

## What Changes

- **Field-Level Q1–Q4 Visualization**: Render a interactive comparative grid of quadrants Q1, Q2, Q3, and Q4 displaying water level, condition/status, online/offline connection state, battery percentage, RSSI/SNR signal diagnostic data, and timestamp.
- **Zone Selection & Read-Only Detail Inspector**: Allow users to tap/select any monitoring zone to view detailed diagnostic metrics and telemetry history in a modal/sheet without exposing zone-level pump or valve irrigation controls.
- **Strict Architecture Boundaries**: Explicitly maintain Q1–Q4 as read-only telemetry monitoring points. Prohibit zone-specific irrigation controls and reinforce that field irrigation is served solely by the single centralized system.
- **Multi-State Data Feedback**: Support loading, empty (no zones deployed), stale (old telemetry data), unavailable (gateway disconnected), and error presentation states using reusable design-system widgets.
- **Repository Abstraction Layer**: Enhance `ZoneRepository` and domain models to support detailed LoRaWAN sensor diagnostics (RSSI, SNR, battery level, gateway connection state) prepared for future live API integration.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `monitoring-zones`: Expanded to include field-level comparative Q1–Q4 visualization, detailed sensor telemetry (water level, online/offline, battery, RSSI, SNR, timestamp), zone detail selection view with read-only controls, and multi-state UI feedback (loading, empty, stale, unavailable, error).

## Impact

- `lib/features/field/presentation/field_screen.dart`: Refactored to provide complete AquaSense Field Monitoring experience with interactive Q1–Q4 comparative grid, state switching, and detail inspection sheet.
- `lib/features/zones/domain/models/monitoring_zone.dart`: Updated to include sensor signal metrics (`rssi`, `snr`, `isOnline`).
- `lib/features/zones/data/repositories/zone_repository.dart`: Updated mock repository layer to support signal diagnostic data and multi-state mock toggling (normal, empty, stale, unavailable, error).
- Reusable Design System components (`lib/core/widgets/`): Used for status badges, metric tiles, and error/empty/loading/stale feedback widgets.

