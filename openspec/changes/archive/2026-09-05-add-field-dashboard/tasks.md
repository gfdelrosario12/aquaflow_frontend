## 1. Domain & Data Layer Setup

- [x] 1.1 Create `field_alert.dart` and `field_recommendation.dart` models in `lib/features/home/domain/models/`
- [x] 1.2 Create `field_dashboard_summary.dart` model combining overall condition, AWD state, zone contrasts, central irrigation, alerts, and recommendations
- [x] 1.3 Implement `FieldDashboardRepository` interface and `FieldDashboardRepositoryImpl` mock repository in `lib/features/home/data/repositories/` supporting normal, empty, stale-data, and error mock states

## 2. Dashboard Component Widgets

- [x] 2.1 Implement `FieldConditionHeaderCard` widget displaying overall field water condition, AWD state, last updated timestamp, and stale-data warning badge
- [x] 2.2 Implement `ZoneContrastSummaryCard` widget displaying Q1–Q4 monitoring point telemetries and highlighting wetter vs drier zones
- [x] 2.3 Implement `CentralIrrigationOverviewCard` widget presenting centralized pump/valve status, flow rate, pressure, and navigation trigger to central control
- [x] 2.4 Implement `FieldRecommendationsCard` widget displaying prioritized actionable recommendations and answering if irrigation is needed
- [x] 2.5 Implement `ActiveAlertsSection` widget rendering critical and warning field alert banners

## 3. Screen Integration & State Handling

- [x] 3.1 Refactor `HomeScreen` in `lib/features/home/presentation/home_screen.dart` to integrate all dashboard component cards
- [x] 3.2 Wire up pull-to-refresh and multi-state UI handling (`LoadingStateWidget`, `EmptyStateWidget`, `ErrorStateWidget`, and stale data banner) using design-system components

## 4. Verification & Testing

- [x] 4.1 Run static analysis (`dart analyze`) to verify zero errors or lints
- [x] 4.2 Run unit and widget tests to verify field dashboard rendering and UI state transitions
