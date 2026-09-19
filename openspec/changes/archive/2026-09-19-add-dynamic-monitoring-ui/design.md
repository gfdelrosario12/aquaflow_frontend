## Context

See `proposal.md` for motivation. The AquaSense Flutter frontend models are already capable of representing arbitrary zones and nodes (`MonitoringZone`, `Esp32Node`, `SpatialCoordinates`), but several key presentation widgets and domain services still assume a fixed 4-quadrant layout ("Q1–Q4"). Specifically:
- `QuadrantGridVisualizer` enforces a 2x2 grid and hardcodes the header text `"Monitoring Quadrants Matrix (Q1–Q4)"`.
- `SpatialFieldCanvasVisualizer` hardcodes corner quadrant labels (`Q1 (North-East)`, `Q2 (North-West)`, etc.) at fixed canvas coordinates.
- `AwdRuleEngine` explicitly rejects any field telemetry where fewer than 4 zones report.
- Home dashboard and diagnostic widgets have hardcoded strings referencing Q1–Q4.
- Cross-platform responsiveness on Flutter Web and Android requires adaptive grid columns and card layouts.

## Goals / Non-Goals

**Goals:**
- Replace `QuadrantGridVisualizer` with a generic, responsive `DynamicZoneGridVisualizer` that adapts column counts (1 to 4) based on screen width and zone count.
- Refactor `SpatialFieldCanvasVisualizer` to dynamically position zone labels and boundaries using node coordinates and zone metadata.
- Update `AwdRuleEngine` and `AwdAnalyticsScreen` to support dynamic zone counts (requiring at least 1 reporting zone, or a dynamic field quorum) without hardcoding 4 zones.
- Refactor dashboard summary cards, header cards, diagnostic lists, and zone analysis sheets to derive counts, titles, and labels from backend configuration.
- Provide comprehensive loading, empty (0 zones / 0 nodes), stale, and error states.
- Ensure 100% feature and API parity across Android and Flutter Web.
- Maintain strict centralized irrigation safety: no zone-level actuation triggers anywhere in the UI.

**Non-Goals:**
- Changing backend REST endpoints or altering existing DTO schemas.
- Implementing zone-level irrigation pump or valve controls (centralized irrigation is strictly field-wide).
- Introducing platform-specific native plugins (remains pure Flutter cross-platform).

## Decisions

### Decision 1: Responsive Grid Breakpoints in `DynamicZoneGridVisualizer`
- **Choice**: Use `LayoutBuilder` with adaptive column counts:
  - Width < 420px: 2 columns (or 1 column if expanded) with dynamic aspect ratio (1.1 to 1.25) to prevent overflow.
  - Width 420px – 768px: 2 columns with generous padding.
  - Width 768px – 1100px: 3 columns.
  - Width > 1100px: 4 columns.
- **Rationale**: Ensures cards are easily readable and do not suffer from RenderFlex overflows on narrow Android devices (360px) while taking advantage of wider screen real estate on desktop/tablet web.
- **Alternatives Considered**: Fixed 2-column grid (stretches cards excessively on web); pure ListView (wastes space on desktop).

### Decision 2: Dynamic Spatial Canvas Rendering
- **Choice**: Compute spatial bounds and zone centerpoints from the active nodes' `SpatialCoordinates`. Render zone labels near their corresponding node clusters or in a dynamic canvas legend when coordinates are not spatially separated. Remove hardcoded corner text drawing (`Q1 (North-East)`, etc.).
- **Rationale**: Works cleanly for 1, 2, 4, 6, 8, or arbitrary node configurations without drawing confusing or inaccurate quadrant borders.
- **Alternatives Considered**: Drawing static crosshairs (assumes 4 quadrants).

### Decision 3: Flexible AWD Rule Engine Quorum
- **Choice**: Refactor `AwdRuleEngine` to evaluate all active, reporting monitoring zones. Evaluate conditions when `reportingZones.isNotEmpty`. If 0 zones report, return `AwdFieldWaterStatus.insufficientData` with an explanatory message: `"No active monitoring zones are currently reporting telemetry."`
- **Rationale**: Supports smallholder fields with 1 or 2 monitoring points as well as commercial fields with 6, 8, or 12 nodes.
- **Alternatives Considered**: Requiring at least 2 nodes (breaks single-node demo deployments).

### Decision 4: Cross-Platform Parity (Android & Web)
- **Choice**: Share identical Riverpod state providers, HTTP clients, and UI widgets across Android and Web. Adapt layouts using Flutter's layout primitives (`LayoutBuilder`, `MediaQuery`, `FittedBox`) rather than conditional platform imports.
- **Rationale**: Eliminates drift between mobile and web experiences and minimizes maintenance overhead.

## Risks / Trade-offs

- **[Risk]** Existing widget test suites hardcode expect finds for "Q1", "Q2", "Q3", "Q4", or "Quadrant".
  → **Mitigation**: Retain default mock seed codes (e.g. zones with code "Q1" or "Z1") in mock repositories for backward-compatible test assertions, while updating tests to verify dynamic multi-zone rendering (e.g., 6 and 8 zones).
- **[Risk]** Text overflow in compact zone cards on 360px mobile viewports.
  → **Mitigation**: Use `FittedBox`, `Flexible`, `TextOverflow.ellipsis`, and child aspect ratio constraints; verify with `test/responsive_validation_test.dart`.
- **[Risk]** Field with zero zones or zero nodes.
  → **Mitigation**: Provide dedicated `EmptyStateWidget` variants on Field, Dashboard, and Diagnostics screens guiding operators to provision nodes.

