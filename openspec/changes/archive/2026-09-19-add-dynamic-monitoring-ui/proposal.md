## Why

The AquaSense mobile and web monitoring interfaces currently carry legacy assumptions of a fixed 4-quadrant layout labeled "Q1–Q4", including hardcoded grid columns, quadrant titles, and a rigid requirement in the AWD engine that exactly 4 zones must report. Real-world agricultural deployments vary widely—from small single-zone plots to complex multi-hectare fields with 2, 6, 8, or more monitoring zones and physical sensor nodes. Refactoring the frontend to dynamically generate monitoring cards, comparative grids, spatial visualizers, AWD evaluations, and diagnostic inspectors from backend field configuration eliminates hardcoded constraints, enables seamless runtime node updates, and provides responsive layouts across Android and Web.

## What Changes

- **Dynamic Zone & Node Rendering**: Replace hardcoded "Q1–Q4" and "Quadrant" strings, titles, and fixed 2x2 grid widgets with dynamic, configuration-driven components that adapt to any practical number of monitoring zones (1, 2, 4, 6, 8, or more).
- **Adaptive Responsive Layouts (Android & Web)**: Introduce responsive layout logic for field monitoring and dashboard cards that dynamically adjusts columns, aspect ratios, and card structures based on screen width (mobile portrait, mobile landscape, tablet, desktop web) and zone counts.
- **Dynamic Field & Zone Visualization**: Refactor canvas and spatial visualization widgets to dynamically calculate boundaries, zone partitions, and node placements from backend spatial metadata and coordinates, eliminating hardcoded quadrant quadrant corner labels.
- **Configurable AWD Reporting Thresholds**: Update the AWD rule engine and presentation components to accept variable reporting zone counts (e.g. requiring a dynamic quorum or percentage of active zones, or at least 1 reporting zone) rather than rejecting fields with fewer than 4 nodes.
- **Dynamic Dashboard & Analytics Cards**: Update field condition headers, zone contrast summaries, historical trend charts, and diagnostic lists to display dynamically formatted zone counts, configured labels, and runtime status indicators.
- **Real-Time Node Mutation Adaptation**: Ensure the UI dynamically ingests added, removed, disabled, replaced, or reassigned nodes over real-time events and REST polling without requiring application reload or rebuild.
- **Identical Cross-Platform REST Consumption**: Maintain complete API parity across Android and Flutter Web with no platform-specific network or data parsing divergence.
- **Prohibition of Legacy Q1–Q4 Widgets**: Deprecate and replace `QuadrantGridVisualizer` with a generic, extensible `DynamicZoneGridVisualizer` and clean up hardcoded quadrant terminology across all feature layers.

## Capabilities

### New Capabilities
<!-- No new capabilities required; existing capabilities are refactored to support dynamic topologies -->

### Modified Capabilities
- `monitoring-zones`: Remove hardcoded Q1–Q4 quadrant assumptions; require adaptive responsive layouts for arbitrary zone counts (1, 2, 4, 6, 8+), dynamic labels from backend configuration, and multi-node zone telemetry rendering.
- `field-dashboard`: Update field condition header and zone contrast summaries to dynamically reflect arbitrary zone counts, configuration-driven labels, and responsive layout scaling on mobile and web.
- `awd-analytics`: Refactor AWD rule engine and UI to evaluate dynamic active monitoring zones rather than requiring exactly 4 reporting zones, updating recommendation rationale accordingly.
- `spatial-field-monitoring`: Eliminate hardcoded Q1–Q4 corner labels from 2D spatial canvas rendering; dynamically position and render zone boundaries and labels based on backend spatial geometry and node coordinates.
- `device-diagnostics`: Generalize node inspection tabs and headers to display dynamic node counts and configured node labels rather than fixed "Q1–Q4" groupings.

## Impact

- **Affected Presentation Widgets**:
  - `lib/features/field/presentation/widgets/quadrant_grid_visualizer.dart` (refactored to `DynamicZoneGridVisualizer`)
  - `lib/features/field/presentation/field_screen.dart`
  - `lib/features/home/presentation/widgets/field_condition_header_card.dart`
  - `lib/features/home/presentation/widgets/zone_contrast_summary_card.dart`
  - `lib/features/analytics/presentation/analytics_screen.dart`
  - `lib/features/awd/presentation/awd_analytics_screen.dart`
  - `lib/features/nodes/presentation/widgets/spatial_field_canvas_visualizer.dart`
  - `lib/features/diagnostics/presentation/device_diagnostics_screen.dart`
  - `lib/features/zones/presentation/zone_analysis_screen.dart`
- **Affected Domain Services**:
  - `lib/features/awd/domain/services/awd_rule_engine.dart`
- **APIs and Protocols**:
  - Consumes existing `/api/fields`, `/api/zones`, `/api/nodes`, and `/api/analytics` REST endpoints and WebSocket events identically across Android and Web.
- **Testing & Verification**:
  - Unit tests in `test/unit/` and widget tests across varying zone configurations (1, 2, 4, 6, 8 nodes) and responsive viewports (360px mobile to 1200px web).

