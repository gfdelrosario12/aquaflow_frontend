## Why

The AquaFlow mobile app requires a unified, accessible, and modern design system tailored for agricultural IoT field monitoring. Establishing centralized design tokens, components (typography, spacing, colors, status badges, cards, charts, dialogs, loading/error states), and dual (light/dark) theme support prevents code duplication and enforces strict visual clarity between Q1–Q4 monitoring telemetry, AWD analysis status, device status, and centralized irrigation controls.

## What Changes

- **Design Tokens**: Centralize typography scale, spacing steps, border radii, elevations, semantic status colors (Monitoring, AWD, Irrigation, Device, Alerts), and icons.
- **Theme System**: Implement dual theme support (Dark-first default + Light theme option) via centralized Flutter `ThemeData` tokens.
- **Reusable Component Library**:
  - **Cards & Data Containers**: `AquaCard`, `SensorMetricCard`, `TelemetryBadgeCard`.
  - **Status Badges & Indicators**: `StatusBadge` distinguishing Zone Telemetry, AWD Analysis State, Centralized Pump/Valve State, Device Battery/LoRa, and System Alerts.
  - **Buttons & Inputs**: Styled primary, secondary, text buttons, chip selectors, and toggle switches.
  - **Navigation & Dialogs**: `AquaDialog`, custom app bar/bottom bar styling tokens.
  - **Charts & Data Visualization**: Reusable telemetry chart container and custom painter utilities for trends.
  - **Feedback Widgets**: Standardized `LoadingStateWidget`, `EmptyStateWidget`, and `ErrorStateWidget`.
- **Domain Constraints Enforcement**: Ensure visual design explicitly isolates Q1–Q4 telemetry cards (no irrigation toggles) from Centralized Field Irrigation cards.

## Capabilities

### New Capabilities
- `design-system`: Centralized design tokens, theme system (light & dark), status semantics, and reusable UI component library for agricultural IoT monitoring.

### Modified Capabilities
- `core-architecture`: Update core styling requirement to mandate the usage of centralized `AquaFlowTheme` tokens and design system component library.

## Impact

- **Frontend Codebase**: Scaffolds `lib/core/theme/` and `lib/core/widgets/` component architecture. Updates view implementations (`HomeScreen`, `FieldScreen`, `AnalyticsScreen`, `ControlScreen`, `SettingsScreen`) to consume unified design tokens.
- **No Logic / Backend Impact**: Strictly a presentation-layer and design-system foundation change. Does not include backend APIs, LoRaWAN, or physical irrigation logic.
