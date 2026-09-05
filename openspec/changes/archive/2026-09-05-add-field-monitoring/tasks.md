## 1. Domain & Data Layer Enhancement

- [x] 1.1 Update `MonitoringZone` model in `lib/features/zones/domain/models/monitoring_zone.dart` with sensor signal metrics (`isOnline`, `rssiDbm`, `snrDb`, `hardwareModel`, `firmwareVersion`, `waterLevelHistory`)
- [x] 1.2 Update `ZoneRepository` and `MockZoneDataSource` in `lib/features/zones/data/repositories/zone_repository.dart` to support signal diagnostics and multi-state mock data fetching (normal, empty, stale, unavailable, error)

## 2. Field Presentation Components

- [x] 2.1 Create `FieldHeaderOverviewCard` widget in `lib/features/field/presentation/widgets/field_header_overview_card.dart` displaying overall quadrant status, moisture contrast, and gateway sync indicator
- [x] 2.2 Create `QuadrantGridVisualizer` widget in `lib/features/field/presentation/widgets/quadrant_grid_visualizer.dart` displaying interactive 2x2 comparative grid of Q1–Q4 zones with online badges and moisture levels
- [x] 2.3 Create `ZoneDetailBottomSheet` widget in `lib/features/field/presentation/widgets/zone_detail_bottom_sheet.dart` showing full hardware diagnostics (RSSI, SNR, battery, firmware) and telemetry trend chart with explicit read-only notice

## 3. Screen Integration & Multi-State UI Feedback

- [x] 3.1 Refactor `FieldScreen` in `lib/features/field/presentation/field_screen.dart` to integrate header overview, comparative quadrant grid, and zone inspector sheet
- [x] 3.2 Implement pull-to-refresh, state simulation menu, and multi-state UI feedback handling (`LoadingStateWidget`, `EmptyStateWidget`, `ErrorStateWidget`, stale banner, and gateway unavailable banner)

## 4. Verification & Testing

- [x] 4.1 Run static analysis (`flutter analyze`) to verify zero errors or lints
- [x] 4.2 Run unit and widget tests (`flutter test`) for zone repository diagnostics, field screen rendering, zone selection, and state transitions
