## Why

AquaSense currently lacks a centralized alert and notification management hub to inform farmers and field operators about critical agronomic, hardware, and infrastructure events. Providing real-time event classification, severity categorization, read/unread tracking, detailed contextual recommendations, and alert history is essential for preventing crop stress, identifying gateway/sensor faults, and managing centralized irrigation execution.

## What Changes

- **Alerts & Notification Hub**: Create an Alert List and Alert Detail view supporting categorization by severity (`info`, `warning`, `critical`).
- **Event Coverage**: Support alerts for low water levels, AWD irrigation recommendations, sensor offline states, abnormal measurements, low battery, gateway communication issues, centralized irrigation start/stop events, central pump/valve failures, and controller faults.
- **Contextual Source Attribution**:
  - Irrigation-related alerts explicitly attribute events to the centralized irrigation system serving the `ENTIRE FIELD`.
  - Telemetry and sensor alerts specify the originating monitoring quadrant (`Q1`, `Q2`, `Q3`, or `Q4`) or gateway infrastructure.
- **Alert Interaction & History**: Provide read/unread state toggling, filtering by severity and category, detailed recommended action guidance, and historical event archives.
- **State Handling & API Readiness**: Support loading, empty, stale telemetry warnings, and error presentation states using standardized design system components, preparing data layer abstractions for future backend and push notification service integrations.

## Capabilities

### New Capabilities
- `alert-management`: Provides real-time alert listing, severity categorization, detailed event inspection, read/unread state tracking, source attribution (centralized irrigation vs Q1–Q4 monitoring nodes), and historical event logging.

## Impact

- **UI Components**: `lib/features/alerts/presentation/alerts_screen.dart`, `alert_detail_screen.dart`, notification badge widgets.
- **Domain Layer**: `lib/features/alerts/domain/models/` (`SystemAlert`, `AlertSeverity`, `AlertCategory`, `AlertSource`).
- **Data Layer**: `lib/features/alerts/data/repositories/` abstraction and mock repository with stream-based notification triggers.
- **App Navigation**: Add notification icon badge and navigation shortcuts from `FieldDashboard` and `MobileAppShell`.

