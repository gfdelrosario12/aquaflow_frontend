## MODIFIED Requirements

### Requirement: Quadrant monitoring zones definition
The application MUST model monitoring zones as dynamically configurable observational zones within a field supporting arbitrary zone counts (such as 1, 2, 4, 6, 8, or more), providing soil moisture, water level, and environmental telemetry while strictly avoiding hardcoded quadrant limitations, and automatically expanding zone counts when new nodes and zones are provisioned.

#### Scenario: Displaying telemetry for monitoring zones
- **WHEN** the user views zone telemetry in the Field or Home screens
- **THEN** readings for all dynamically configured monitoring zones in the field are displayed independently with moisture and water level metrics, regardless of whether 1, 2, 4, 6, 8, or more zones are provisioned.

#### Scenario: Expanding monitoring zone count upon node registration
- **WHEN** a new sensor node is scanned and registered with a new zone assignment
- **THEN** the system dynamically instantiates the new monitoring zone, increments active zone count, and reflects the updated zone matrix in the Field and Home dashboards.
