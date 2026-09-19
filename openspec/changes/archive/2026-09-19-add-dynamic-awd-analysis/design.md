## Context

AquaSense rice cultivation fields employ Alternate Wetting and Drying (AWD) water management. In real-world paddy fields, water levels are not uniform across the terrain due to elevation gradients, uneven bund heights, localized soil percolation differences, and solar exposure. Furthermore, sensor nodes in IoT deployments experience transmission delays, temporary disconnects, low battery conditions, and sensor contamination or drift.

Because AquaSense irrigation is centralized (one main pump and valve supplying the entire field), naive arithmetic averaging across variable numbers of nodes can mislead the irrigator—either causing drought stress in dry areas or flooding already submerged sections. The AWD rule engine must mathematically cleanse, weight, and evaluate variable node telemetry while producing clear, explainable field-level decisions.

## Goals / Non-Goals

**Goals:**
- Provide a robust two-stage aggregation pipeline: physical plausibility filtering, outlier detection, and spatial-weighted water depth calculation.
- Support arbitrary numbers of monitoring zones ($N \ge 1$), gracefully scaling from 1 or 2 nodes up to 8+ nodes.
- Calculate an explicit `AwdConfidenceScore` (High, Medium, Low, Insufficient) based on active node ratio, telemetry freshness, and sensor validity.
- Detect high zone disparity / conflicting moisture conditions and produce explicit field inspection alerts before recommending irrigation.
- Support crop growth stage threshold presets (`vegetative`, `reproductive`, `ripening`) with explicit agronomic defaults and customizable overrides.
- Maintain the architectural invariant: strictly single centralized field decisions; zones remain read-only observational points.

**Non-Goals:**
- Zone-level actuation or localized valve control (centralized irrigation only).
- Direct backend hardware actuation without user or operator workflow confirmation.
- External cloud weather radar integration (future capability).

## Decisions

### Decision 1: Two-Stage Data Quality and Aggregation Pipeline
- **Stage 1 (Validation & Cleansing)**:
  - Physical Plausibility: Water level must be within $[-35\text{ cm}, +35\text{ cm}]$ and soil moisture within $[0\%, 100\%]$. Readings outside these bounds are marked as sensor faults/outliers and excluded from aggregation.
  - Statistical Outliers: For fields with $N \ge 4$ active nodes, calculate median and median absolute deviation (MAD). Readings with $|x_i - \text{median}| > 3.0 \times \text{MAD}$ are flagged as statistical outliers. For $N < 4$, statistical filtering is bypassed to avoid discarding genuine spatial variance.
  - Telemetry Freshness: Readings older than `freshnessTimeoutMinutes` (default: 45 minutes) are flagged as stale.
- **Stage 2 (Spatial Weighted Aggregation)**:
  - Usable zones (valid, non-outlier) contribute to field depth via normalized spatial weights:
    $$d_{field} = \sum_{i \in \text{Usable}} \bar{w}_i \cdot d_i \quad \text{where} \quad \bar{w}_i = \frac{w_i}{\sum_{j \in \text{Usable}} w_j}$$
  - If spatial weights are unset or zero, equal weighting $w_i = 1/N_{usable}$ is applied.

### Decision 2: Confidence and Completeness Scoring Algorithm
- The engine calculates a normalized confidence score $C \in [0.0, 1.0]$:
  $$C = 0.50 \times \left(\frac{N_{usable}}{N_{total}}\right) + 0.35 \times \text{FreshnessScore} + 0.15 \times \text{DistributionScore}$$
  - `High` ($C \ge 0.80$): Complete, fresh telemetry across field zones.
  - `Medium` ($0.50 \le C < 0.80$): Some nodes offline or slightly stale, but quorum met.
  - `Low` ($0.25 \le C < 0.50$): Significant missing or stale data; recommendations carry high caution notice.
  - `Insufficient` ($C < 0.25$ or $N_{usable} < N_{quorum}$): Evaluation cannot safely determine water condition; engine outputs `Insufficient Data` state.

### Decision 3: Conflicting Condition & Zone Disparity Detection
- If $d_{max} - d_{min} > \text{maxAllowedSpreadCm}$ (default: 8.0 cm):
  - If $d_{min} \le \text{refloodTrigger}$ while $d_{max} \ge 2.0\text{ cm}$ (flooded), the field has an extreme moisture gradient.
  - Pumping full irrigation would overflood the wet portion. The engine sets `hasConflictingConditions = true` and `recommendation.action = IrrigationAction.monitor` or `inspectField` with high urgency, directing the farmer to inspect bund leaks, drainage blocks, or uneven field grading.

### Decision 4: Agronomic Crop Stage Configuration Models
- Introduce [`CropGrowthStage`](file:///home/gladwin/Documents/pagaaral/aquaflow/aquaflow_frontend/lib/features/awd/domain/models/crop_growth_stage.dart) enum:
  - `vegetative`: Standard AWD drying allowed down to -15.0 cm.
  - `reproductive`: Critical heading/flowering stage. Water stress causes flower abortion. Drying limited to 0.0 cm / shallow flood +3.0 cm.
  - `ripening`: Terminal drying allowed down to -20.0 cm to prepare for harvest.
- Encapsulate in extended [`AwdThresholdConfig`](file:///home/gladwin/Documents/pagaaral/aquaflow/aquaflow_frontend/lib/features/awd/domain/models/awd_threshold_config.dart).

## Risks / Trade-offs

- **[Risk: Small field ($N=1$ or $N=2$) data volatility]**
  → *Mitigation*: Bypass statistical MAD filtering when $N < 4$; enforce physical range bounds only and evaluate quorum dynamically ($\min(1, N)$).
- **[Risk: Stale nodes skewing irrigation decisions indefinitely]**
  → *Mitigation*: Telemetry older than 45 minutes is completely excluded from the active average and contributes a 0.0 freshness score, downgrading overall confidence.
- **[Risk: Operator confuses inspection recommendation with pump refusal]**
  → *Mitigation*: The rationale explicitly details that central pumping remains accessible via Central Field Control, but highlights the disparity risk.

