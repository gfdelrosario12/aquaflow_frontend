## MODIFIED Requirements

### Requirement: Detailed sensor telemetry and signal metrics
The system SHALL present detailed telemetry metrics for each monitoring zone including water level (cm), soil moisture (%), zone status/condition, sensor online/offline state, battery percentage, signal diagnostic metrics (RSSI in dBm and SNR in dB), and last measurement timestamp across any configured number of zones.

#### Scenario: Displaying telemetry and diagnostic signal metrics for a monitoring zone
- **WHEN** the user views a monitoring zone card or detailed inspector on the Field screen
- **THEN** water level, soil moisture, connection state (online/offline), battery percentage, RSSI, SNR, and last measurement timestamp are clearly displayed.

## ADDED Requirements

### Requirement: Dynamic responsive monitoring zone layout
The system SHALL dynamically render monitoring zones using an adaptive responsive layout that automatically adjusts column counts, card dimensions, and aspect ratios based on viewport width (single-column on narrow mobile, two-column on standard mobile, multi-column on tablet and desktop web) and the total number of configured zones, supporting arbitrary practical zone deployments (such as 1, 2, 4, 6, 8, or more zones).

#### Scenario: Rendering field monitoring on standard mobile screen
- **WHEN** the user opens the Field Monitoring screen on a mobile device with 360–600px width
- **THEN** the monitoring zones are rendered in an adaptive 2-column or 1-column scrollable grid with proportional card dimensions without RenderFlex overflow.

#### Scenario: Rendering field monitoring on tablet or desktop web
- **WHEN** the user opens the Field Monitoring screen on a device with width exceeding 720px
- **THEN** the monitoring zones expand into a multi-column responsive grid (3 or 4 columns) optimizing whitespace and card readability.

#### Scenario: Rendering odd or arbitrary numbers of zones
- **WHEN** a field is configured with 1, 3, 5, or 7 monitoring zones
- **THEN** the layout renders all configured zones cleanly without placeholder gaps, layout clipping, or assumed fixed pairs.

### Requirement: Configuration-driven zone labels and headers
The system SHALL derive all monitoring zone headers, section titles, card labels, and navigation titles dynamically from field configuration returned by the backend, strictly avoiding hardcoded quadrant nomenclature.

#### Scenario: Displaying dynamic field monitoring title and counts
- **WHEN** the field monitoring screen renders active monitoring zones
- **THEN** the section header displays dynamic counts and configured zone names (e.g., "Field Monitoring Zones (6 Active)") without referencing fixed Q1–Q4 quadrants.

