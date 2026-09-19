## ADDED Requirements

### Requirement: Telemetry freshness and data quality tracking
The system SHALL evaluate each monitoring zone's telemetry for freshness (time elapsed since last measurement), data reliability status (valid, stale, outlier, or uncalibrated), and effective spatial weight in field-wide AWD analysis.

#### Scenario: Visualizing zone data quality in zone details
- **WHEN** a monitoring zone's sensor node has not reported within the freshness timeout or is identified as an outlier
- **THEN** the zone details view displays an amber or warning badge indicating degraded telemetry quality and whether the zone is excluded from the active field average.

