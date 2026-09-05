## Context

The AquaSense Home/Dashboard is the central hub of the application. It aggregates telemetry from individual monitoring zones (Q1–Q4) and status from the centralized field irrigation system to provide field-level water condition insight, AWD (Alternate Wetting and Drying) guidance, and actionable recommendations.

See `proposal.md` for motivation and background context.

## Goals / Non-Goals

**Goals:**
- Provide a unified field-level dashboard summarizing overall water condition, AWD status, Q1-Q4 monitoring point telemetry, centralized irrigation state, active alerts, and actionable field recommendations.
- Answer the 5 core operator questions:
  1. What is the current field condition?
  2. Which monitoring zones are wetter or drier?
  3. Does the overall field require irrigation?
  4. Is centralized irrigation currently running?
  5. What action is recommended?
- Enforce strict architectural separation between read-only monitoring points (Q1–Q4) and centralized irrigation controls.
- Handle state transitions gracefully: Loading, Content, Empty, Stale-Data, and Error fallback states using reusable design-system widgets.

**Non-Goals:**
- Actual backend network calls, real LoRaWAN gateways, or production AWD algorithm implementation (uses repository mock layer).
- Zone-level irrigation controls or per-quadrant solenoid valve triggers (prohibited by system architecture).

## Decisions

### Decision 1: Aggregated Field Dashboard Domain Model & Mock Repository
- **Choice**: Create a dedicated `FieldDashboardSummary` domain model and `FieldDashboardRepository` mock interface under `lib/features/home/`.
- **Rationale**: Isolates dashboard aggregation logic from individual raw zone telemetries, allowing clean testing of stale data, empty data, and error states.
- **Alternatives Considered**: Fetching zone and irrigation repositories directly inside UI `initState()` and computing field metrics inline. Rejected as it mixes domain logic with UI and makes handling stale/empty/error states fragmented.

### Decision 2: Stale Data & Refresh Management
- **Choice**: Add a timestamp (`lastUpdated`) to `FieldDashboardSummary` and a configurable freshness threshold (15 minutes). If exceeded or simulated stale, display a `StaleDataBanner` built with `AppColors.warning` tokens while retaining cached telemetry.
- **Rationale**: Field operators need immediate awareness if sensor network telemetry is delayed or offline without crashing or hiding past telemetry data.

### Decision 3: Zone Moisture Relative Contrast Visualizer
- **Choice**: Compute min/max soil moisture across Q1–Q4 zones to explicitly tag zones as "Wetter" or "Drier" in a visual comparison summary card.
- **Rationale**: Directly answers "Which monitoring zones are wetter or drier?" at a glance before deciding field-wide irrigation needs.

### Decision 4: Read-Only Zone Summaries & Centralized Control Navigation
- **Choice**: Display Q1–Q4 as read-only metric tiles. Include a button in the Centralized Irrigation section to navigate to the dedicated Control screen for pump management.
- **Rationale**: Complies with the core system rule that irrigation status and controls refer strictly to the single centralized field irrigation system.

## Risks / Trade-offs

- **[Risk] Mock Data Synchronization**: Disconnect between mock data on Home screen vs. Field or Control screens.
  - *Mitigation*: Share or re-use `ZoneRepository` and `IrrigationRepository` singleton mock instances inside `FieldDashboardRepositoryImpl`.
- **[Risk] UI Density on Mobile Viewports**: Fitting overall condition, Q1–Q4 comparison, alerts, recommendations, and central irrigation status on 360px–430px screens.
  - *Mitigation*: Wrap content in `ResponsiveContainer` and `SingleChildScrollView` with structured card sections and clear visual hierarchy.

## Migration Plan

1. Create domain models: `field_dashboard_summary.dart`, `field_alert.dart`, `field_recommendation.dart`.
2. Create repository: `field_dashboard_repository.dart` with mock implementation.
3. Update `HomeScreen` in `lib/features/home/presentation/home_screen.dart` with componentized card widgets (`FieldConditionHeaderCard`, `ZoneContrastSummaryCard`, `CentralIrrigationOverviewCard`, `FieldRecommendationsCard`, `ActiveAlertsSection`).
4. Support simulated state toggles for testing loading, empty, stale, and error views.
5. Verify hot reload and widget rendering on mobile viewports.

