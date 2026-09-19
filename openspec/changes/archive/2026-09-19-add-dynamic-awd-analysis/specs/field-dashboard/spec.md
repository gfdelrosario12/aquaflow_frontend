## MODIFIED Requirements

### Requirement: Field condition and AWD summary
The system SHALL present an overall field water condition summary, AWD assessment status, calculated analysis confidence badge (High, Medium, Low, or Insufficient), and latest update timestamp at the top of the dashboard view.

#### Scenario: Displaying field water condition and AWD status
- **WHEN** the user opens the Home/Dashboard view
- **THEN** the overall field condition (e.g. Optimal Water Level, Reflux Needed, or Flooded), AWD assessment status, confidence rating badge, and last synced timestamp are clearly rendered.

### Requirement: Active alerts and recommended action guidance
The system SHALL evaluate field-wide telemetry to display active alerts and specific field recommendations indicating whether irrigation is required, what action should be taken, and whether telemetry disparity or low confidence requires manual inspection.

#### Scenario: Displaying field recommendations and alerts
- **WHEN** active telemetry or AWD calculations indicate dry conditions, low confidence, or zone disparity alerts
- **THEN** the dashboard presents prioritized alert banners (including disparity and confidence warnings) and actionable field recommendations (e.g., "Run centralized irrigation pulse", "Inspect field distribution - high zone variance").

## ADDED Requirements

### Requirement: AWD confidence and data completeness presentation
The system SHALL visually inform the user of the confidence level of the field AWD evaluation on the dashboard header, indicating whether the recommendation is based on complete, degraded, or insufficient sensor telemetry.

#### Scenario: Displaying degraded confidence warning on dashboard
- **WHEN** the AWD analysis confidence is Medium or Low due to offline or stale nodes
- **THEN** an informative badge or chip indicates degraded telemetry coverage alongside the field water condition status.

