## MODIFIED Requirements

### Requirement: Quadrant monitoring zones definition
The application MUST model monitoring zones as dynamically configurable observational zones within a field supporting arbitrary zone counts (such as 1, 2, 4, 6, 8, or more), providing soil moisture, water level, and environmental telemetry while strictly avoiding hardcoded quadrant limitations.

#### Scenario: Displaying telemetry for monitoring zones
- **WHEN** the user views zone telemetry in the Field or Home screens
- **THEN** readings for all dynamically configured monitoring zones in the field are displayed independently with moisture and water level metrics, regardless of whether 1, 2, 4, 6, 8, or more zones are provisioned.

### Requirement: Field-level comparative zone visualization
The system SHALL provide an adaptive comparative layout displaying all dynamically provisioned monitoring zones simultaneously, enabling immediate field-level contrast of water levels and moisture conditions across arbitrary zone counts.

#### Scenario: Comparing field conditions across quadrants Q1 through Q4
- **WHEN** the user opens the Field Monitoring screen
- **THEN** all active monitoring zones returned by the backend are rendered in an adaptive comparative matrix or list displaying status badges, moisture levels, and water depths for side-by-side assessment across dynamic zones.

### Requirement: Dedicated quarter monitoring zone analysis view
The system SHALL provide a dedicated analysis screen/view for any selected monitoring zone in the field, displaying real-time water level depth, soil moisture percentage, sensor online/offline status, battery level, RSSI, SNR, and the last update timestamp.

#### Scenario: Navigating to individual quarter zone analysis
- **WHEN** the user selects any monitoring zone from the Field Monitoring screen or Dashboard zone cards
- **THEN** the application opens the Zone Analysis screen displaying detailed telemetry, hardware diagnostics, and historical performance for that specific zone.

