## MODIFIED Requirements

### Requirement: Quadrant monitoring zones definition
The application MUST model monitoring zones as dynamically configurable observational zones within a field supporting arbitrary zone counts (such as 1, 2, 4, 6, 8, or more), providing soil moisture, water level, and environmental telemetry while strictly avoiding hardcoded quadrant limitations.

#### Scenario: Displaying telemetry for monitoring zones
- **WHEN** the user views zone telemetry in the Field or Home screens
- **THEN** readings for all dynamically configured monitoring zones in the field are displayed independently with moisture and water level metrics, regardless of whether 1, 2, 4, 6, 8, or more zones are provisioned.

### Requirement: Dedicated quarter monitoring zone analysis view
The system SHALL provide a dedicated analysis screen/view for any selected monitoring zone in the field, displaying real-time water level depth, soil moisture percentage, sensor online/offline status, battery level, RSSI, SNR, and the last update timestamp, while routing dashboard zone interactions directly to the Field tab.

#### Scenario: Navigating to individual quarter zone analysis
- **WHEN** the user selects any monitoring zone from the Field Monitoring screen
- **THEN** the application opens the Zone Analysis screen displaying detailed telemetry, hardware diagnostics, and historical performance for that specific zone.

#### Scenario: Interacting with dashboard zone cards
- **WHEN** the user selects any monitoring zone card from the Home Dashboard screen
- **THEN** the application routes directly to the main Field tab to present overall field context across dynamic zones.
