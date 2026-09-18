## ADDED Requirements

### Requirement: Multi-node dynamic zone aggregation
The system SHALL support aggregating telemetry from one or more dynamically assigned ESP32 sensor nodes within a monitoring zone, computing composite zone water level and soil moisture metrics while displaying individual node breakdowns.

#### Scenario: Displaying zone with multiple assigned nodes
- **WHEN** a monitoring zone contains multiple assigned ESP32 sensor nodes
- **THEN** the zone displays composite moisture and water level readings along with the count and health status of all member nodes.

### Requirement: Spatial view toggle on field monitoring screen
The system SHALL provide a view mode toggle on the Field Monitoring screen allowing users to switch seamlessly between the matrix/grid view and the spatial 2D field visualization.

#### Scenario: Toggling from matrix view to spatial field view
- **WHEN** the user taps the spatial view toggle button on the Field Monitoring screen
- **THEN** the layout transitions from the quadrant matrix cards to the interactive 2D spatial field visualizer.

