## Why

Farmers and field operators need a clear, centralized field-level dashboard (AquaSense Home/Dashboard experience) to quickly gauge overall field water status, alternate wetting and drying (AWD) assessments, active field alerts, and centralized irrigation activity. Currently, individual zone telemetries and central controls are disconnected, lacking a unified home overview that answers critical operational questions in one glance without exposing dangerous zone-level irrigation controls.

## What Changes

- **Field Overview Header & Status**: Display current overall field water condition, AWD state assessment, latest update timestamp, and stale-data indicator.
- **Centralized Irrigation Status**: Integrate field-wide centralized irrigation system status (running vs idle, flow rate, pressure, pump state) while explicitly preserving single-centralized-system controls and prohibiting zone-specific irrigation triggers.
- **Monitoring Zone Comparison (Q1–Q4)**: Summarize telemetry for quadrants Q1, Q2, Q3, and Q4 as read-only monitoring points, identifying which zones are wetter or drier.
- **Alerts & Recommendations Engine View**: Display active system/water alerts and prioritized actionable field recommendations answering whether the field requires irrigation and what action is recommended.
- **State Management & UI States**: Implement loading, empty, stale-data (last update > threshold), and error fallback states using reusable design-system components and repository mock data.

## Capabilities

### New Capabilities
- `field-dashboard`: Covers the AquaSense Home/Dashboard experience including overall field condition summary, AWD assessment, Q1-Q4 zone contrast summaries, centralized irrigation operational status, active alerts, recommendations, and multi-state UI feedback (loading, empty, stale, error).

### Modified Capabilities
- None.

## Impact

- `lib/features/home/presentation/home_screen.dart`: Refactored to render full AquaSense Dashboard experience with recommendations, active alerts, zone comparison, and stale-data feedback.
- `lib/features/home/domain/models/`: Domain models for field dashboard overview, field recommendations, active alerts, and overall field condition summaries.
- `lib/features/home/data/repositories/`: Repository interface and mock implementation for fetching consolidated field dashboard telemetry.
- Reusable Design System components (`lib/core/widgets/`): Leveraged for cards, badges, tiles, empty, error, stale, and loading states.

