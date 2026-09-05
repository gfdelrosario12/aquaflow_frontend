# monitoring-zones Specification

## Purpose
Defines domain structures, telemetry data models, and monitoring views for independent field monitoring quadrants Q1, Q2, Q3, and Q4.

## Requirements

### Requirement: Quadrant monitoring zones definition
The application MUST model Q1, Q2, Q3, and Q4 strictly as independent telemetry monitoring zones providing soil moisture, water level, and sensor status telemetry.

#### Scenario: Displaying telemetry for monitoring zones
- **WHEN** the user views zone telemetry in the Field or Home screens
- **THEN** readings for Q1, Q2, Q3, and Q4 are displayed independently with moisture and water level metrics.

### Requirement: Strict prohibition of zone-level irrigation controls
The application MUST NOT present or permit zone-specific irrigation triggers or zone-level pump/valve control actions within monitoring zone models or views.

#### Scenario: Inspecting monitoring zone actions
- **WHEN** the user selects any monitoring zone (Q1, Q2, Q3, or Q4) in the UI
- **THEN** only read-only monitoring metrics and sensor diagnostic information are shown, with no zone-level activation controls present.

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

### Requirement: Dedicated quarter monitoring zone analysis view
The system SHALL provide a dedicated analysis screen/view for any selected monitoring zone (Q1, Q2, Q3, or Q4) displaying real-time water level depth, soil moisture percentage, sensor online/offline status, battery level, RSSI, SNR, and the last update timestamp.

#### Scenario: Navigating to individual quarter zone analysis
- **WHEN** the user selects a monitoring zone (Q1, Q2, Q3, or Q4) from the Field Monitoring screen or Dashboard zone cards
- **THEN** the application opens the Zone Analysis screen displaying the detailed telemetry, hardware diagnostics, and historical performance for that specific quadrant.

### Requirement: Telemetry trend direction and rate analysis
The system SHALL compute and display a trend direction indicator for the selected monitoring zone, explicitly stating whether the quadrant is becoming "wetter" (increasing water level) or "drier" (decreasing water level) alongside the estimated rate of change over time.

#### Scenario: Displaying trend direction and rate indicator
- **WHEN** the user inspects the trend card on the zone analysis screen
- **THEN** the system displays a clear visual badge and text indicator showing whether the zone is becoming "Wetter" or "Drier" (e.g., "Wetter (+1.8 cm/h)" or "Drier (-1.2 cm/h)") calculated from historical measurements.

### Requirement: Multi-timeframe historical trend visualization
The system SHALL render interactive or multi-range historical trend charts (e.g., 24-hour and 7-day timeframes) allowing users to visually inspect and compare historical water depth and moisture behavior for the selected quadrant.

#### Scenario: Switching timeframes on the historical trend chart
- **WHEN** the user selects a different historical timeframe filter (e.g., 24h or 7d) on the zone analysis chart
- **THEN** the historical telemetry chart updates to display data points corresponding to the selected time window.

### Requirement: Read-only AWD and centralized irrigation redirection
The system MUST NOT provide zone-level Start Irrigation, Stop Irrigation, pump controls, or valve triggers on the zone analysis screen. If the user requires irrigation action based on quadrant trends, the screen MUST display an explicit read-only notice directing the user toward field-level AWD analysis and centralized irrigation.

#### Scenario: Verifying read-only guardrails and centralized irrigation redirection
- **WHEN** the user views the zone analysis screen for any quadrant
- **THEN** no pump or valve control triggers are present, and a prominent redirection banner is displayed guiding the user to the centralized irrigation and field AWD controller for any watering actions.
