## Why

In Alternate Wetting and Drying (AWD) rice irrigation, water depth fluctuates across a field due to soil variation, topography, microclimates, and percolation differences. AquaSense fields deploy a dynamic, variable number of sensor nodes and monitoring zones (e.g. 1, 2, 4, 6, 8, or more). Previously, field-level AWD evaluation relied on basic arithmetic averages and minimums that did not account for data quality, missing or offline nodes, newly provisioned nodes without historical depth data, stale readings, sensor outliers, spatial weighting, or conflicting water-level readings across zones.

Because irrigation in AquaSense is strictly centralized (a single pump and distribution valve serving the entire field), an unweighted average or raw outlier can cause catastrophic crop stress or unnecessary irrigation. Furthermore, incomplete telemetry directly impacts recommendation reliability. AquaSense needs a robust, mathematically grounded, and agronomic-aware AWD analysis engine that computes field-wide water condition, data completeness/confidence scoring, conflict detection, and actionable centralized irrigation recommendations with transparent rationale.

## What Changes

- **Robust Field-Level AWD Aggregator**:
  - Implement spatial weighting (e.g., zone polygon/area proportion weights) to prevent small peripheral zones from skewing field decisions.
  - Implement statistical outlier filtering (modified Z-score or interquartile range / physical sensor plausibility bounds) to filter sensor drift or anomalies without corrupting field metrics.
  - Handle telemetry age and freshness: stale measurements are progressively downweighted or excluded from real-time recommendations.
  - Handle newly provisioned or rebooted nodes: provisional status without trend history does not break drying-rate calculations.
- **Confidence & Data Completeness Scoring**:
  - Introduce an explicit `AwdConfidenceScore` (0–100% or `High`, `Medium`, `Low`, `Unusable`) reflecting active node coverage, spatial balance, and telemetry freshness.
  - Define minimum usable node quorum requirements: if coverage falls below minimum agronomic threshold, the system safely transitions to an `insufficientData` or `unreliableData` analysis state.
- **Conflicting Condition Detection**:
  - Detect high variance / conflicting conditions (e.g., Zone A critically dry while Zone B remains flooded) and generate high-priority field alert warnings advising physical field inspection before running centralized irrigation.
- **Configurable Agronomic & Engine Configuration**:
  - Expose explicit, configurable agronomic parameters: crop stage threshold presets (vegetative, reproductive, ripening), safe drying depth, reflood trigger depth, critical stress threshold, stale telemetry timeout, and minimum quorum percentage.
- **Field-Level Decision Invariant**:
  - Strict preservation of centralized irrigation semantics: analysis produces a single unified field recommendation (`irrigate`, `doNotIrrigate`, `inspectField`, `monitor`). Individual monitoring zones remain purely observational.

## Capabilities

### Modified Capabilities
- `awd-analytics`: Refactor AWD analytics domain service and rule engine to incorporate data quality validation, spatial weighting, confidence scoring, conflict detection, and configurable crop-stage thresholds.
- `field-dashboard`: Update field dashboard presentation to display AWD analysis confidence indicators, telemetry completeness status, and field conflict alerts.
- `monitoring-zones`: Extend monitoring zone telemetry models with data freshness, reliability metrics, and spatial contribution weights.

## Impact

- **Domain Models & Services**:
  - `lib/features/awd/domain/services/awd_rule_engine.dart`
  - `lib/features/awd/domain/models/awd_analytics_summary.dart`
  - `lib/features/awd/domain/models/awd_threshold_config.dart`
  - `lib/features/awd/domain/models/awd_recommendation.dart`
  - New models: `awd_confidence.dart`, `crop_growth_stage.dart`
- **UI & Presentation**:
  - `lib/features/awd/presentation/awd_analytics_screen.dart`
  - `lib/features/home/presentation/widgets/field_condition_header_card.dart`
  - `lib/features/home/presentation/home_screen.dart`
- **Tests**:
  - Expanded unit test coverage in `test/unit/` and widget tests validating confidence scoring, outlier filtering, conflict handling, and dynamic zone counts.

