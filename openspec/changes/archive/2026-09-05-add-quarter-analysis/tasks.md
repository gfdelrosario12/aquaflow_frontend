## 1. Domain & Data Foundation

- [x] 1.1 Extend `MonitoringZone` domain model and mock data source (`MockZoneDataSource`) with multi-timeframe historical telemetry (24h hourly and 7d daily readings).
- [x] 1.2 Implement trend calculation helper logic (`ZoneTrendAnalysis`) to compute "Wetter", "Drier", or "Stable" status and rate of change ($\text{cm/h}$) from telemetry history.

## 2. Presentation & UI Components

- [x] 2.1 Create `ZoneAnalysisScreen` widget in `lib/features/zones/presentation/zone_analysis_screen.dart` displaying zone header, real-time metric tiles, trend indicator card, multi-timeframe chart, and hardware diagnostic details.
- [x] 2.2 Add prominent read-only redirection banner enforcing non-controllable telemetry scope and providing direct navigation to Centralized Irrigation (`ControlScreen`).
- [x] 2.3 Integrate navigation to `ZoneAnalysisScreen` from zone cards on the Field Monitoring screen (`FieldScreen`) and Dashboard (`HomeScreen`).

## 3. State Handling & Quality Verification

- [x] 3.1 Support loading, empty, stale, offline node, and error states using reusable AquaFlow design system widgets (`LoadingStateWidget`, `ErrorStateWidget`, `AquaCard`).
- [x] 3.2 Execute static analysis (`flutter analyze`) and widget tests to confirm compliance with read-only rules and zero regressions.

