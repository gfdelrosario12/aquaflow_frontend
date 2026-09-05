## Why

Alternate Wetting and Drying (AWD) is a proven water-saving irrigation practice for rice cultivation that requires continuous field-wide water level evaluation. To make informed field-level irrigation decisions without over-watering or risking crop stress, farmers and water managers need an integrated AWD Analytics feature. This feature aggregates telemetry from all four independent monitoring zones (Q1, Q2, Q3, Q4), evaluates wetting/drying rates across the field, applies configurable AWD decision rules, and generates a clear field-level recommendation explaining whether the centralized irrigation system should irrigate the entire field.

## What Changes

- **Field-Level AWD Analytics Screen & Summary**: Implement a dedicated AWD Analytics screen and reusable summary widgets presenting field-level water condition, aggregated water depth metrics, and field AWD status.
- **Quad-Zone Telemetry Aggregation & Comparison**: Aggregate measurements from Q1, Q2, Q3, and Q4 into field-level metrics (mean water depth, moisture variance, drying/wetting rates) while preserving read-only telemetry boundaries for individual zones.
- **Wetting and Drying Trend Analysis**: Calculate field-wide and per-zone drying/wetting rate trends ($\text{cm/day}$ or $\text{cm/h}$) to detect rapid percolation, evapotranspiration, or rainfall events.
- **Configurable AWD Threshold Rules**: Structure AWD thresholds (e.g., safe dry water depth threshold, reflood/reflux trigger level, target flood depth) as configurable parameters rather than hardcoding scientifically unvalidated values, enabling future field-specific adjustments.
- **Transparent Recommendation Rationale**: Provide explicit, human-readable explanations detailing *why* the system recommends or does not recommend centralized irrigation (e.g., "Recommending Irrigation: 2 of 4 zones have dropped below the configured -15 cm safe drying threshold").
- **Single Centralized Decision Output**: Direct all recommendations toward the single centralized irrigation system serving the entire field. Strictly exclude any zone-specific pump or valve activation commands.
- **Comprehensive UI States**: Support loading, insufficient data (e.g., <4 active sensors), stale telemetry data, and gateway error presentation states.

## Capabilities

### New Capabilities
- `awd-analytics`: Field-level Alternate Wetting and Drying (AWD) analytics, multi-zone telemetry aggregation, drying/wetting rate trend analysis, configurable threshold rules, transparent recommendation rationale, and centralized field irrigation decision support.

## Impact

- **UI / Screens**: New `AwdAnalyticsScreen` in `lib/features/analytics/presentation/` (or `lib/features/awd/presentation/`), with entry points from the Analytics tab, Field screen, and Dashboard recommendations card.
- **Data & Domain Layer**: `AwdRepository`, `AwdAnalyticsSummary`, `AwdThresholdConfig`, and `AwdRecommendation` domain models in `lib/features/awd/`.
- **Dependencies**: Reusable design system widgets (`AquaCard`, `AquaChartContainer`, `StatusBadge`, `LoadingStateWidget`, `ErrorStateWidget`, `EmptyStateWidget`).

