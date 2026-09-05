## ADDED Requirements

### Requirement: Detailed sensor telemetry and signal metrics
The system SHALL present detailed telemetry metrics for each monitoring zone (Q1, Q2, Q3, Q4) including water level (cm), soil moisture (%), zone status/condition, sensor online/offline state, battery percentage, signal diagnostic metrics (RSSI in dBm and SNR in dB), and last measurement timestamp.

#### Scenario: Displaying telemetry and diagnostic signal metrics for a monitoring zone
- **WHEN** the user views a monitoring zone card or detailed inspector on the Field screen
- **THEN** water level, soil moisture, connection state (online/offline), battery percentage, RSSI, SNR, and last measurement timestamp are clearly displayed.

### Requirement: Field-level comparative zone visualization
The system SHALL provide a comparative visual grid layout displaying all four monitoring quadrants (Q1, Q2, Q3, Q4) simultaneously, enabling immediate field-level contrast of water levels and moisture conditions.

#### Scenario: Comparing field conditions across quadrants Q1 through Q4
- **WHEN** the user opens the Field Monitoring screen
- **THEN** Q1, Q2, Q3, and Q4 are rendered in a comparative grid showing status badges, moisture levels, and water depths for side-by-side assessment.

### Requirement: Zone selection read-only inspection
The system SHALL allow the user to select any monitoring zone to inspect detailed sensor telemetry in a dedicated sheet or view, while strictly excluding zone-level pump or valve activation controls.

#### Scenario: Selecting a monitoring zone for detailed telemetry inspection
- **WHEN** the user taps a monitoring zone card (Q1, Q2, Q3, or Q4)
- **THEN** a detailed telemetry inspection view opens displaying comprehensive sensor health, signal metrics, and historical depth readings without presenting any zone-level irrigation buttons or hardware triggers.

### Requirement: Field monitoring screen state handling
The system SHALL support loading, empty (no deployed nodes), stale (outdated measurements), unavailable (gateway connection lost), and error presentation states using reusable design-system widgets.

#### Scenario: Handling sensor telemetry connection error or gateway unavailability
- **WHEN** loading monitoring zone telemetry fails or gateway connection is lost
- **THEN** a standardized error state component or unavailable banner is rendered with retry instructions.

