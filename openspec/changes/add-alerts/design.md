## Context

AquaSense provides telemetry monitoring across quadrants Q1–Q4, field-wide AWD analytics, and centralized field irrigation control. The frontend requires a unified Alerts & Notification Management hub (`lib/features/alerts/`) to present agronomic warnings, battery/sensor faults, gateway connectivity dropouts, and centralized irrigation events. See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Implement `SystemAlert` domain models with `AlertSeverity` (`info`, `warning`, `critical`), `AlertCategory` (`agronomic`, `hardware`, `irrigation`, `connectivity`), and explicit `AlertSource` attribution (`Centralized Irrigation - ENTIRE FIELD` vs `Monitoring Zone Q1–Q4` vs `Gateway`).
- Build `AlertRepository` and `MockAlertRepository` exposing stream-based notification triggers ready for REST/GraphQL and push-notification backends.
- Build `AlertsScreen` featuring category/severity filter chips, read/unread status filters, mark-all-as-read action, and unread notification badge counter.
- Build `AlertDetailScreen` displaying full event history, contextual source hardware details, severity indicators, and actionable remediation steps.
- Handle state variations: loading, empty alert history, stale data warnings, and communication errors using design system widgets.

**Non-Goals:**
- Production Firebase Cloud Messaging (FCM) or APNs push infrastructure setup (data layer uses stream abstractions to prepare for push payload mapping).
- Automating physical valve triggers directly from alerts (irrigation alerts direct users to the Central Control screen for manual safety execution).

## Decisions

### 1. Alert Domain Schema & Source Scope
- **Decision**: Define `AlertSource` with properties `name`, `type` (`centralIrrigation`, `monitoringZone`, `gateway`), and `targetScope` (`ENTIRE FIELD` for irrigation vs `Q1`–`Q4` for monitoring nodes).
- **Rationale**: Prevents confusion between field-wide irrigation failures and quadrant-level sensor telemetry readings.

### 2. State Management & Stream-Based Provider
- **Decision**: Implement `AlertNotifier` (ChangeNotifier) wrapping `AlertRepository`, providing reactive unread count tracking, severity filtering, search filtering, and optimistic read status toggling.
- **Rationale**: Ensures responsive UI state updates when users toggle read status or receive new stream events.

### 3. Navigation & Screen Flow
- **Decision**: Embed notification icon with unread badge counter in top app header (`FieldDashboard` and app shell). Tapping navigates to `AlertsScreen`. Tapping an individual alert opens `AlertDetailScreen`.
- **Rationale**: Provides immediate visibility of critical warnings across all app screens.

## Risks / Trade-offs

- **[Risk: Large volume of telemetry warning logs overwhelming the UI]** → *Mitigation*: Provide quick filter chips (`All`, `Unread`, `Critical`, `Warning`, `Irrigation`) and search bar to quickly locate critical alerts.
- **[Risk: Misinterpreting node alerts as quadrant irrigation commands]** → *Mitigation*: Node alerts explicitly present read-only sensor observations, while AWD/irrigation alerts direct users strictly to centralized field control.

