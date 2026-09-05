## 1. Domain Models & Rules Engine Foundation

- [x] 1.1 Create `AwdThresholdConfig`, `AwdRecommendation`, and `AwdAnalyticsSummary` domain models in `lib/features/awd/domain/models/`.
- [x] 1.2 Implement `AwdRuleEngine` domain service to compute field-level water metrics, zone drying/wetting rates ($\text{cm/day}$), active AWD status, and transparent recommendation rationale.
- [x] 1.3 Implement `AwdRepository` and `MockAwdRepository` in `lib/features/awd/data/repositories/` to aggregate `MonitoringZone` telemetry and produce `AwdAnalyticsSummary`.

## 2. Presentation & UI Screens

- [x] 2.1 Create `AwdAnalyticsScreen` in `lib/features/awd/presentation/awd_analytics_screen.dart` displaying field AWD status, recommendation rationale card, quad-zone drying/wetting rate table, and configurable threshold inspector.
- [x] 2.2 Add prominent read-only redirection banner enforcing single centralized field irrigation decision scope and providing direct navigation shortcut to `ControlScreen`.
- [x] 2.3 Integrate navigation to `AwdAnalyticsScreen` from `AnalyticsScreen`, `FieldScreen`, and `HomeScreen`.

## 3. State Handling & Quality Verification

- [x] 3.1 Support loading, insufficient-data (<4 active reporting nodes), stale telemetry, and gateway error presentation states using design system components.
- [x] 3.2 Execute static analysis (`flutter analyze`) and unit/widget test suites to verify rule engine calculations and zero UI regressions.

