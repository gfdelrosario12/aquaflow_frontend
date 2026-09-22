# field-dashboard Specification

## Purpose
Provides a unified field-level dashboard experience (AquaSense Home/Dashboard) summarizing overall water condition, AWD assessment, Q1–Q4 zone telemetry comparisons, centralized irrigation activity, active alerts, and field recommendations.
## Requirements
### Requirement: Field condition and AWD summary
The system SHALL present an overall field water condition summary, AWD assessment status, calculated analysis confidence badge (High, Medium, Low, or Insufficient), and latest update timestamp at the top of the dashboard view.

#### Scenario: Displaying field water condition and AWD status
- **WHEN** the user opens the Home/Dashboard view
- **THEN** the overall field condition (e.g. Optimal Water Level, Reflux Needed, or Flooded), AWD assessment status, confidence rating badge, and last synced timestamp are clearly rendered.

### Requirement: Monitoring zones relative moisture summary
The system SHALL display telemetry summaries for all dynamically provisioned monitoring zones in the active field as read-only monitoring points, highlighting relative moisture contrasts across dynamic zone counts, and SHALL route the user directly to the primary Field tab upon tapping any zone breakdown item.

#### Scenario: Summarizing zone moisture contrasts
- **WHEN** the user views the monitoring zones section on the dashboard
- **THEN** all active field monitoring zones display soil moisture and water depth metrics, dynamically identifying which zones are wettest or driest without presenting any zone-level irrigation controls.

#### Scenario: Tapping a monitoring zone card on dashboard
- **WHEN** the user taps any monitoring zone card or summary item on the Home dashboard
- **THEN** the application routes the user directly to the Field tab to inspect comprehensive field monitoring telemetry.

### Requirement: Centralized field irrigation status integration
The system SHALL display the operational status (running/idle, flow rate, pressure) of the single centralized irrigation system serving the entire field.

#### Scenario: Inspecting centralized irrigation state
- **WHEN** the user views the centralized irrigation section on the dashboard
- **THEN** the status indicates whether field-wide centralized irrigation is currently active or idle, with direct access to centralized system controls.

### Requirement: Active alerts and recommended action guidance
The system SHALL evaluate field-wide telemetry to display active alerts and specific field recommendations indicating whether irrigation is required, what action should be taken, and whether telemetry disparity or low confidence requires manual inspection.

#### Scenario: Displaying field recommendations and alerts
- **WHEN** active telemetry or AWD calculations indicate dry conditions, low confidence, or zone disparity alerts
- **THEN** the dashboard presents prioritized alert banners (including disparity and confidence warnings) and actionable field recommendations (e.g., "Run centralized irrigation pulse", "Inspect field distribution - high zone variance").

### Requirement: Comprehensive UI state handling
The system SHALL support loading, empty, stale-data, and error presentation states using reusable design-system feedback components.

#### Scenario: Handling stale telemetry data
- **WHEN** the last received telemetry timestamp exceeds the acceptable freshness threshold
- **THEN** a prominent stale-data warning banner is rendered while retaining cached field metrics.

#### Scenario: Handling dashboard telemetry fetch error
- **WHEN** loading dashboard data fails due to a network or repository error
- **THEN** a standardized error state component is rendered with a retry button.

### Requirement: Dynamic zone count header and contrast breakdown
The system SHALL render the dashboard field condition header and zone contrast summary dynamically based on the actual number of configured zones and active reporting nodes, displaying live counts, configured zone identifiers, and adaptive layout rows without hardcoding quadrant labels or fixed Q1–Q4 badges.

#### Scenario: Rendering dashboard zone breakdown for variable zone count
- **WHEN** the user views the Home/Dashboard screen for a field configured with 6 monitoring zones
- **THEN** the header displays "6 Zones Active" and the breakdown card renders all 6 configured zones with individual moisture bars, status chips, and contrast indicators.

#### Scenario: Empty monitoring zones state on dashboard
- **WHEN** a newly created field contains zero configured monitoring zones
- **THEN** the dashboard renders an empty-state card guiding the operator to provision or assign monitoring zones rather than displaying missing quadrant errors.

### Requirement: AWD confidence and data completeness presentation
The system SHALL visually inform the user of the confidence level of the field AWD evaluation on the dashboard header, indicating whether the recommendation is based on complete, degraded, or insufficient sensor telemetry.

#### Scenario: Displaying degraded confidence warning on dashboard
- **WHEN** the AWD analysis confidence is Medium or Low due to offline or stale nodes
- **THEN** an informative badge or chip indicates degraded telemetry coverage alongside the field water condition status.

