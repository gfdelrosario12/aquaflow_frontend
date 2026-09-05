## Context

The AquaFlow frontend requires a comprehensive, reusable design system to unify visual styling, support light and dark themes, improve visual hierarchy for field telemetry, and eliminate duplicated UI patterns across screens.

## Goals / Non-Goals

**Goals:**
- Centralize design tokens for typography (`AppTypography`), colors (`AppColors`), spacing & sizing (`AppDimensions`), border radii, elevations, and icons (`AppIcons`).
- Define semantic color palettes for:
  - Monitoring Zone Telemetry (Optimal, Low, Critical, Offline)
  - AWD Analysis Status (Safe, Drying/Reflux Needed, Flooded)
  - Centralized Irrigation Status (Pump Active, Valve Open, Idle)
  - Device & Hardware Status (Battery Low, LoRa Signal Strong/Weak)
  - System Alerts & Notifications (Info, Warning, Error)
- Build a reusable UI component library under `lib/core/widgets/`:
  - `AquaCard`, `SensorMetricTile`, `StatusBadge`
  - `AquaButton` (Primary, Secondary, Icon)
  - `AquaDialog`
  - `AquaChartContainer`, `SimulatedTelemetryChart`
  - `LoadingStateWidget`, `EmptyStateWidget`, `ErrorStateWidget`, `ResponsiveContainer`
- Support Light and Dark mode dynamically via `AquaFlowTheme`.
- Preserve domain rules: Q1–Q4 remain telemetry-only monitoring zones; physical irrigation is centralized.

**Non-Goals:**
- Implementing real REST API integrations, backend services, or physical LoRaWAN/MQTT protocols.
- Implementing zone-level physical irrigation controls (violates field architecture).

## Decisions

### Decision 1: Centralized Design Token Layer (`lib/core/theme/tokens/`)
- **Decision**: Separate design tokens into dedicated files: `app_colors.dart`, `app_typography.dart`, `app_dimensions.dart`, `app_icons.dart`.
- **Rationale**: Isolates visual constants from Flutter widget code and allows easy theme switching.

### Decision 2: Distinct Semantic Status Color Mapping
- **Decision**: Define clear semantic status categories so users never confuse telemetry moisture alerts with pump execution or device connectivity status.
- **Rationale**: Farmers and operators need instant visual recognition of critical conditions in full daylight or dark conditions.

### Decision 3: Card and Feedback Widget Architecture
- **Decision**: Wrap standard Flutter cards and state widgets into `AquaCard` and reusable state components enforcing minimum 48dp touch targets and 360–430px layout constraints.
- **Rationale**: Ensures responsive consistency across target mobile viewports.

## Risks / Trade-offs

- **[Risk] High component surface area** → **Mitigation**: Keep components modular, self-contained, and export them cleanly via `lib/core/widgets/widgets.dart`.
