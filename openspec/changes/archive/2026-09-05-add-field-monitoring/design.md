## Context

The AquaSense Field Monitoring feature provides field operators with a real-time, comparative overview of telemetry across four independent monitoring zones (Q1, Q2, Q3, Q4). While the Home screen summarizes top-level condition recommendations, the Field screen delivers in-depth quadrant diagnostics including water level, online/offline state, battery status, and LoRaWAN signal metrics (RSSI, SNR).

See `proposal.md` for motivation and scope.

## Goals / Non-Goals

**Goals:**
- Provide a field-level comparative visualization (2x2 quadrant grid) comparing water condition, moisture, and hardware health across Q1, Q2, Q3, and Q4.
- Display comprehensive telemetry and diagnostic metrics for each zone: water depth (cm), soil moisture (%), online/offline status, battery level (%), RSSI (dBm), SNR (dB), and last measurement timestamp.
- Provide a read-only zone inspector bottom sheet when a user selects a zone card, reinforcing that Q1–Q4 are monitoring points only.
- Support 5 distinct UI presentation states: Loading, Content, Stale-Data (>15m), Empty (no deployed nodes), Gateway Unavailable, and Fetch Error.
- Prepare repository abstractions for seamless future API integration.

**Non-Goals:**
- Presenting zone-level pump or valve activation controls (strictly forbidden by system architecture).
- Implementing physical LoRaWAN hardware communication drivers or backend network protocols (uses mock data source).

## Decisions

### Decision 1: Domain Model Extension for LoRaWAN Telemetry
- **Choice**: Extend `MonitoringZone` model with `isOnline`, `rssiDbm`, `snrDb`, `hardwareModel`, `firmwareVersion`, and `waterLevelHistory`.
- **Rationale**: Captures complete IoT node diagnostics required for field maintenance without breaking existing component constructors (uses sensible default values in `copyWith`).

### Decision 2: Repository Mock State Engine
- **Choice**: Add `ZoneMockState` enum (`normal`, `empty`, `stale`, `unavailable`, `error`) to `ZoneRepository` fetch methods.
- **Rationale**: Enables deterministic verification of edge cases (gateway disconnect, unmonitored field, stale sensors) via the UI state simulator menu without needing mock web servers.

### Decision 3: Componentized Field Screen Layout & Read-Only Inspector
- **Choice**: Decompose `FieldScreen` into modular widgets under `lib/features/field/presentation/widgets/`:
  - `FieldHeaderOverviewCard`: Summarizes overall field moisture contrast and active quadrant count.
  - `QuadrantGridVisualizer`: Interactive 2x2 quadrant comparative layout.
  - `ZoneDetailBottomSheet`: Modal sheet displaying detailed hardware diagnostics (RSSI/SNR, battery, firmware) and water depth trend chart with explicit read-only notice.
- **Rationale**: Keeps screen code clean, testable, and compliant with Material 3 touch target guidelines (minimum 48dp).

## Risks / Trade-offs

- **[Risk] Compact Viewport Signal Metric Overflow**: Displaying RSSI, SNR, battery, and moisture within small 2x2 grid cards on 360px mobile screens.
  - *Mitigation*: Display top metrics (moisture, water depth, online badge) on grid cards, and detail all secondary diagnostics (RSSI, SNR, firmware) in the expandable `ZoneDetailBottomSheet`.
- **[Risk] Misinterpretation of Zone Selection**: Users assuming tapping a zone initiates quadrant irrigation.
  - *Mitigation*: Display a prominent banner in `ZoneDetailBottomSheet` clarifying that Q1–Q4 are monitoring points and linking to the Central Control screen for irrigation operations.

## Migration Plan

1. Update domain models: `MonitoringZone` fields in `lib/features/zones/domain/models/monitoring_zone.dart`.
2. Update `ZoneRepository` interface & `MockZoneDataSource` implementation in `lib/features/zones/data/repositories/zone_repository.dart`.
3. Create presentation components in `lib/features/field/presentation/widgets/`.
4. Refactor `FieldScreen` in `lib/features/field/presentation/field_screen.dart` with state management and simulation menu.
5. Verify hot reload, static analysis (`flutter analyze`), and widget tests (`flutter test`).

