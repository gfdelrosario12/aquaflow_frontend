## Why

Farmers and water managers monitoring AquaSense field telemetry need detailed historical analysis for individual monitoring zones (Q1, Q2, Q3, Q4) to understand localized moisture changes over time (e.g., whether a quadrant is becoming wetter or drier) and compare historical sensor performance. Currently, the monitoring view provides a snapshot of zone conditions, but lacks detailed historical trend visualization, trend rate indicators, and clear guidance explaining that monitoring points are read-only telemetry stations that defer all irrigation actions to field-level Alternate Wetting and Drying (AWD) analysis and centralized irrigation.

## What Changes

- **Detailed Monitoring Zone Analysis View**: Provide dedicated zone detail/analysis views for Q1, Q2, Q3, and Q4 containing current water depth, soil moisture, sensor diagnostic status, battery percentage, RSSI, SNR, and timestamp of the latest measurement.
- **Trend Direction & Wetter/Drier Analysis**: Calculate and display trend direction indicators (e.g., "Wetter (+2.1 cm/h)" or "Drier (-1.4 cm/h)") based on historical water level readings to inform water movement across the field.
- **Historical Telemetry Chart & Time-Window Filtering**: Render interactive or multi-range historical trend charts (e.g., 24h, 7d) allowing comparison of historical water depth and moisture behavior.
- **Strict Read-Only Irrigation Redirection**: Enforce read-only presentation by explicitly omitting any quadrant-level Start/Stop Irrigation buttons, pump controls, or valve triggers. Display an informative notice directing users toward field-level AWD analysis and centralized irrigation controls when irrigation actions are relevant.
- **Robust UI State Management**: Handle loading, empty, stale telemetry, offline sensor, and error states using existing AquaFlow design system widgets and repository abstractions (`ZoneRepository`).

## Capabilities

### Modified Capabilities
- `monitoring-zones`: Extend monitoring zone requirements to include detailed historical trend analysis, wetter/drier trend indicators, multi-timeframe historical telemetry visualization, and explicit read-only redirection banners for field-level AWD and centralized irrigation.

## Impact

- **UI / Screens**: Reusable `ZoneAnalysisScreen` or `ZoneDetailView` integrated into navigation from the Field Monitoring screen and Dashboard zone cards.
- **State Management & Repositories**: Extensions or usage of `ZoneRepository` and `MonitoringZone` models to provide historical depth points, trend calculation helpers, and diagnostic telemetry.
- **Dependencies**: Reusable `AquaChartContainer`, `SimulatedTelemetryChart`, `StatusBadge`, and design system widgets from `lib/core/widgets/`.

