## MODIFIED Requirements

### Requirement: Aggregated field-wide AWD water condition assessment
The system SHALL aggregate water depth and soil moisture readings from all active reporting monitoring zones in the field to compute a unified field-wide AWD water level status (Safe Dry, Reflood Needed, Flooded, or Critical Dryness) and field average water depth, supporting arbitrary zone counts.

#### Scenario: Viewing field-wide AWD status summary
- **WHEN** the user opens the AWD Analytics screen
- **THEN** the system displays the aggregated field water status, average field water depth, and moisture range calculated from all actively reporting monitoring zones.

### Requirement: Multi-zone drying and wetting trend evaluation
The system SHALL compute and display drying and wetting rate trends (cm/day or cm/h) across all configured field monitoring zones, allowing users to compare localized drying rates and identify rapid water depletion or accumulation areas.

#### Scenario: Inspecting zone drying and wetting trend rates
- **WHEN** the user views the zone trend comparison section of the AWD Analytics screen
- **THEN** the system presents drying and wetting rates for all configured field zones with visual indicators identifying which zones are drying fastest or accumulating water.

### Requirement: Robust AWD Analytics state management
The system SHALL handle loading, insufficient data (when zero active monitoring zones report valid telemetry or field quorum is unmet), stale data (outdated telemetry timestamps), and gateway error states using standardized design system widgets.

#### Scenario: Handling insufficient monitoring data for AWD analytics
- **WHEN** zero active monitoring zones report valid telemetry
- **THEN** an insufficient-data state card is displayed informing the user that active monitoring zone telemetry is required for field-level AWD recommendations.

