## 1. Centralized Design Tokens & Theme Configuration

- [x] 1.1 Expand `lib/core/constants/app_colors.dart` with light/dark palettes and distinct semantic status colors (Monitoring, AWD, Irrigation, Device, Alerts).
- [x] 1.2 Implement `lib/core/theme/app_typography.dart` and expand `app_dimensions.dart` (typography scale, spacing, border radii, elevations, touch targets).
- [x] 1.3 Implement `lib/core/theme/app_theme.dart` supporting both light and dark ThemeData configurations (`AquaFlowTheme`).

## 2. Reusable UI Component Library

- [x] 2.1 Implement `StatusBadge` widget for distinct monitoring, AWD, irrigation, and device status indicators.
- [x] 2.2 Implement `AquaCard` and `SensorMetricTile` components with strong visual hierarchy and high-contrast typography.
- [x] 2.3 Implement `AquaButton` and chip selection widgets with minimum 48dp touch target compliance.
- [x] 2.4 Implement `AquaDialog` for clear confirmation and alert overlays.
- [x] 2.5 Refactor feedback widgets (`LoadingStateWidget`, `EmptyStateWidget`, `ErrorStateWidget`, `ResponsiveContainer`) to consume new design tokens.
- [x] 2.6 Implement `AquaChartContainer` and custom telemetry trend visualizer widget.

## 3. Integration & Screen Refactoring

- [x] 3.1 Refactor `HomeScreen` to utilize `AquaCard`, `StatusBadge`, and new design system tokens.
- [x] 3.2 Refactor `FieldScreen` to display Q1–Q4 telemetry using `SensorMetricTile` and `StatusBadge` while preserving Q1–Q4 monitoring isolation.
- [x] 3.3 Refactor `AnalyticsScreen` to utilize `AquaChartContainer` and updated stat badges.
- [x] 3.4 Refactor `ControlScreen` to render centralized irrigation hardware metrics using new design system components.
- [x] 3.5 Refactor `SettingsScreen` to include theme toggle (Light / Dark mode switcher).

## 4. Quality Audit & Verification

- [x] 4.1 Verify light and dark theme rendering and touch target sizing across 360–430px Android viewports.
- [x] 4.2 Run `flutter analyze` and `flutter test` to ensure code quality and clean execution.
