## Purpose

Defines domain structures, telemetry data models, and monitoring views for independent field monitoring quadrants Q1, Q2, Q3, and Q4.

## ADDED Requirements

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
