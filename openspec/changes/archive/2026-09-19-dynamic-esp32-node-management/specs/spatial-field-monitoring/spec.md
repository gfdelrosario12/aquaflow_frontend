## Purpose

Provides spatial positioning coordinate management and 2D spatial field map visualization for dynamically placed ESP32 sensor nodes.

## ADDED Requirements

### Requirement: Dual spatial coordinate representation
The system SHALL support storing and presenting dual spatial coordinates for each sensor node: global geographic coordinates (WGS84 latitude and longitude) and optional field-local Cartesian coordinates (X and Y offsets in meters from the field reference origin).

#### Scenario: Storing and displaying dual coordinates
- **WHEN** an operator inputs latitude `14.1524`, longitude `121.2431`, and local offsets `X: 25.0m, Y: 40.0m` for a node
- **THEN** both coordinate representations are persisted and displayed in the node's spatial telemetry inspector.

### Requirement: Interactive 2D spatial field visualization
The system SHALL provide an interactive 2D spatial field visualizer that plots sensor nodes as interactive markers positioned within the field boundary according to their local coordinates or normalized geographic bounds.

#### Scenario: Viewing nodes on the spatial field visualizer
- **WHEN** the user opens the spatial view on the Field screen
- **THEN** all assigned nodes are rendered at their corresponding relative positions with status badges indicating connectivity, battery level, and moisture level.

### Requirement: Spatial node selection and telemetry inspection
The system SHALL allow users to tap any node marker on the spatial visualization to open a detailed telemetry and hardware inspector for that specific node without navigating away from the field view.

#### Scenario: Tapping a node marker on the field map
- **WHEN** the user selects a node marker on the spatial field canvas
- **THEN** an inspector card or bottom sheet opens showing real-time water level, soil moisture, battery status, signal strength, transmission interval, and coordinates.

