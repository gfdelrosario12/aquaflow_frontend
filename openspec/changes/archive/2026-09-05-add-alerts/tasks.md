## 1. Domain Models & Data Layer

- [x] 1.1 Create `SystemAlert`, `AlertSeverity`, `AlertCategory`, and `AlertSource` domain models in `lib/features/alerts/domain/models/`.
- [x] 1.2 Implement `AlertRepository` interface and `MockAlertRepository` in `lib/features/alerts/data/repositories/` providing stream notifications and seed events for low water, AWD recommendation, sensor offline, abnormal readings, low battery, gateway issues, and central irrigation events.
- [x] 1.3 Create `AlertNotifier` state provider in `lib/features/alerts/presentation/providers/alert_provider.dart` supporting severity/category filtering, unread count tracking, search filtering, and read status updates.

## 2. Presentation UI Screens & Components

- [x] 2.1 Create `AlertsScreen` in `lib/features/alerts/presentation/alerts_screen.dart` featuring severity filter chips (`All`, `Critical`, `Warning`, `Info`), unread filter toggle, search input, pull-to-refresh, and mark-all-as-read action.
- [x] 2.2 Create `AlertDetailScreen` in `lib/features/alerts/presentation/alert_detail_screen.dart` displaying detailed event history, source scope attribution (`ENTIRE FIELD` vs `Q1`–`Q4`), timestamp, severity indicators, and recommended action triggers.
- [x] 2.3 Add notification icon badge counter and navigation entry points in `MobileAppShell`, `FieldScreen`, and `ControlScreen`.

## 3. Verification & Safety Enforcements

- [x] 3.1 Handle loading, empty alert list, stale telemetry warning, and error presentation states using design system components.
- [x] 3.2 Add comprehensive unit and widget tests in `test/alerts_test.dart` verifying filter logic, read status state updates, source attribution rendering, and navigation.
- [x] 3.3 Execute static analysis (`flutter analyze`) and test suite (`flutter test`) to verify zero static errors and 100% test pass rate.

