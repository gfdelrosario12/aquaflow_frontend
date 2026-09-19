## MODIFIED Requirements

### Requirement: Aggregated field-wide AWD water condition assessment
The system SHALL aggregate water depth and soil moisture readings from all active reporting monitoring zones in the field to compute a unified field-wide AWD water level status (Safe Dry, Reflood Needed, Flooded, or Critical Dryness), field weighted-average water depth, and moisture range across arbitrary zone counts (1, 2, 4, 6, 8, or more), accounting for spatial weighting and excluding filtered outliers.

#### Scenario: Viewing field-wide AWD status summary
- **WHEN** the user opens the AWD Analytics screen
- **THEN** the system displays the aggregated field water status, spatially weighted average field water depth, active node count, and moisture range calculated from all usable reporting monitoring zones.

#### Scenario: Aggregating single-zone and multi-zone fields
- **WHEN** a field contains 1, 2, 6, or 8 active monitoring zones
- **THEN** the rule engine evaluates the aggregated water condition without requiring a fixed 4-zone topology.

### Requirement: Configurable AWD threshold rules engine
The system SHALL support configurable AWD rule parameters including crop growth stage presets (vegetative, reproductive, ripening), safe drying depth limit, reflood trigger threshold, target flood depth, critical dryness threshold, maximum allowable water depth spread, telemetry freshness timeout, and minimum usable node quorum percentage rather than hardcoding static constants.

#### Scenario: Applying crop stage specific AWD threshold configurations
- **WHEN** the crop stage is set to reproductive (flowering/heading)
- **THEN** the rule engine applies stricter safe drying limits (e.g. avoiding negative water depth during panicle initiation) to prevent crop yield loss.

#### Scenario: Applying configured AWD threshold rules
- **WHEN** the system evaluates field telemetry against the active AWD threshold configuration
- **THEN** field status and irrigation recommendations are computed dynamically relative to the configured threshold parameters and crop stage.

### Requirement: Transparent irrigation recommendation rationale
The system SHALL generate human-readable explanations detailing the precise rationale for recommending or not recommending centralized field irrigation, explicitly detailing the calculated confidence score, usable vs expected node count, specific zones crossing thresholds, and whether conflicting moisture conditions require physical inspection.

#### Scenario: Inspecting irrigation recommendation rationale
- **WHEN** the user views the field irrigation recommendation card on the AWD Analytics screen
- **THEN** a clear rationale statement is rendered explaining why centralized irrigation should or should not be activated, citing specific zone metrics, confidence level, and dry-zone codes.

#### Scenario: Conflicting water levels detected across zones
- **WHEN** one or more zones are below the reflood trigger while other zones remain flooded above the threshold spread
- **THEN** the recommendation highlights the variance conflict and recommends physical field inspection or pulsed distribution rather than an unverified full-field flooding.

### Requirement: Robust AWD Analytics state management
The system SHALL handle loading, insufficient data (when zero active monitoring zones report valid telemetry or active node count is below the minimum usable threshold), low confidence / unreliable data (when stale readings or high outlier rates degrade decision quality), and gateway error states using standardized design system widgets.

#### Scenario: Handling insufficient monitoring data for AWD analytics
- **WHEN** zero active monitoring zones report valid telemetry or active usable nodes are below quorum
- **THEN** an insufficient-data state card is displayed informing the user that minimum usable monitoring telemetry is required for field-level AWD recommendations.

#### Scenario: Handling low confidence or unreliable telemetry
- **WHEN** the calculated AWD confidence score falls below the acceptable reliability threshold due to stale or outlier readings
- **THEN** the system displays an unreliable-data advisory warning alongside tentative metrics, advising caution before irrigating.

## ADDED Requirements

### Requirement: Telemetry data quality and outlier filtering
The system SHALL evaluate incoming water depth and soil moisture measurements for physical plausibility and statistical deviation, flagging or excluding anomalous readings (e.g. values exceeding sensor physical limits or extreme sudden steps) from the field-level AWD aggregation while retaining them in diagnostic logs.

#### Scenario: Filtering sensor outlier spike
- **WHEN** a sensor node reports an erratic reading (+150 cm water depth in a shallow paddy) while surrounding nodes report 2 cm to 4 cm
- **THEN** the system flags the anomalous reading as an outlier, excludes it from the field weighted average, and notes the excluded node in the analysis diagnostics.

### Requirement: AWD analysis confidence and data completeness scoring
The system SHALL compute an explicit field-level AWD confidence score (High, Medium, Low, or Insufficient) based on active node ratio (active nodes / expected nodes), spatial coverage balance, and telemetry freshness (age of last received measurements).

#### Scenario: High confidence rating with complete telemetry
- **WHEN** all expected monitoring zones report fresh measurements within the freshness timeout and zero outliers are detected
- **THEN** the AWD confidence score evaluates to High (>=85%) and recommendations are marked with high reliability.

#### Scenario: Degraded confidence due to offline nodes or stale telemetry
- **WHEN** half of the configured monitoring zones are offline or reporting stale measurements
- **THEN** the AWD confidence score evaluates to Medium or Low, and the irrigation recommendation card displays a prominent telemetry warning chip.

### Requirement: Conflicting field condition detection and alert generation
The system SHALL detect severe water depth disparity across monitoring zones where the difference between the highest and lowest water depths exceeds a configurable spread threshold, generating an advisory alert for field level unevenness or soil percolation issues.

#### Scenario: Uneven field depth disparity alert
- **WHEN** Zone 1 reports -12 cm (severe drying) while Zone 4 reports +6 cm (flooded), exceeding the configured maximum spread threshold
- **THEN** the system flags a "High Zone Disparity" condition and advises operators to check field leveling, bund integrity, or inlet distribution before executing centralized pumping.
