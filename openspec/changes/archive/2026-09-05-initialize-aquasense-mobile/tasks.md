## 1. Project Structure & Core Foundation

- [x] 1.1 Configure dependencies in `pubspec.yaml` and set up `lib/core` directory architecture (tokens, theme, constants).
- [x] 1.2 Implement dark-first `AppTheme` with design tokens (colors, typography, cards, badges).
- [x] 1.3 Implement reusable feedback widgets (`LoadingStateWidget`, `EmptyStateWidget`, `ErrorStateWidget`, `ResponsiveContainer`).

## 2. Domain Models & Mock Repositories

- [x] 2.1 Create `MonitoringZone` model and `ZoneRepository` abstraction with `MockZoneDataSource` for Q1–Q4 monitoring telemetry.
- [x] 2.2 Create `CentralizedIrrigation` model and `IrrigationRepository` abstraction with `MockIrrigationDataSource` for field-wide irrigation status.

## 3. Application Shell & Navigation Views

- [x] 3.1 Implement `AppShell` navigation widget with bottom navigation bar for 360–430px Android screens.
- [x] 3.2 Implement `HomeScreen` with field overview, zone telemetry highlights, and system status summary.
- [x] 3.3 Implement `FieldScreen` displaying Q1–Q4 monitoring zone telemetry without zone-level irrigation controls.
- [x] 3.4 Implement `AnalyticsScreen` displaying telemetry trends and water usage charts/metrics.
- [x] 3.5 Implement `ControlScreen` displaying centralized field-wide irrigation status and simulated override abstractions.
- [x] 3.6 Implement `SettingsScreen` for mobile app preferences and system configuration summaries.

## 4. Verification & Polish

- [x] 4.1 Verify layout rendering and touch targets across 360–430px viewports with simulated loading and error states.
- [x] 4.2 Run `flutter analyze` and `flutter test` to ensure code quality and clean architecture.
