## ADDED Requirements

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

