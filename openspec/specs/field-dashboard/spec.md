# field-dashboard Specification

## Purpose
Provides a unified field-level dashboard experience (AquaSense Home/Dashboard) summarizing overall water condition, AWD assessment, Q1–Q4 zone telemetry comparisons, centralized irrigation activity, active alerts, and field recommendations.

## Requirements

### Requirement: Field condition and AWD summary
The system SHALL present an overall field water condition summary, AWD assessment status, and latest update timestamp at the top of the dashboard view.

#### Scenario: Displaying field water condition and AWD status
- **WHEN** the user opens the Home/Dashboard view
- **THEN** the overall field condition (e.g. Optimal Water Level, Reflux Needed, or Flooded), AWD assessment status, and last synced timestamp are clearly rendered.

### Requirement: Monitoring zones relative moisture summary
The system SHALL display telemetry summaries for monitoring zones Q1, Q2, Q3, and Q4 as read-only monitoring points, highlighting relative moisture contrasts across zones.

#### Scenario: Summarizing zone moisture contrasts
- **WHEN** the user views the monitoring zones section on the dashboard
- **THEN** Q1, Q2, Q3, and Q4 display soil moisture and water depth metrics, identifying which zones are wetter or drier without presenting any zone-level irrigation controls.

### Requirement: Centralized field irrigation status integration
The system SHALL display the operational status (running/idle, flow rate, pressure) of the single centralized irrigation system serving the entire field.

#### Scenario: Inspecting centralized irrigation state
- **WHEN** the user views the centralized irrigation section on the dashboard
- **THEN** the status indicates whether field-wide centralized irrigation is currently active or idle, with direct access to centralized system controls.

### Requirement: Active alerts and recommended action guidance
The system SHALL evaluate field-wide telemetry to display active alerts and specific field recommendations indicating whether irrigation is required and what action should be taken.

#### Scenario: Displaying field recommendations and alerts
- **WHEN** active telemetry or AWD calculations indicate dry conditions or threshold alerts
- **THEN** the dashboard presents prioritized alert banners and actionable field recommendations (e.g., "Field requires 2-hour pulse irrigation", "No action needed").

### Requirement: Comprehensive UI state handling
The system SHALL support loading, empty, stale-data, and error presentation states using reusable design-system feedback components.

#### Scenario: Handling stale telemetry data
- **WHEN** the last received telemetry timestamp exceeds the acceptable freshness threshold
- **THEN** a prominent stale-data warning banner is rendered while retaining cached field metrics.

#### Scenario: Handling dashboard telemetry fetch error
- **WHEN** loading dashboard data fails due to a network or repository error
- **THEN** a standardized error state component is rendered with a retry button.

