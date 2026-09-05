# alert-management Specification

## Purpose

Provides real-time system alerts, notification categorization, severity tracking, contextual source attribution (centralized field irrigation vs Q1–Q4 monitoring nodes), and historical event inspection for AquaSense.

## Requirements

### Requirement: System alert categorization and severity presentation
The system SHALL categorize all notifications into clear severity levels (Informational, Warning, Critical) and present them in a centralized Alert List sorted by timestamp.

#### Scenario: Displaying alert list with severity indicators
- **WHEN** the user opens the Alerts screen
- **THEN** system alerts are presented with severity badges, timestamps, source labels, and read/unread status.

### Requirement: Comprehensive system event notification coverage
The system SHALL generate and display alerts for low water levels, AWD irrigation recommendations, sensor offline states, abnormal moisture/level readings, low battery levels, gateway communication faults, centralized irrigation start/stop events, central pump/valve failures, and central controller offline events.

#### Scenario: Inspecting system notification events
- **WHEN** critical or warning events occur in the field or irrigation hardware
- **THEN** corresponding alert entries are generated and highlighted in the alert list.

### Requirement: Contextual source scope attribution
The system MUST attribute irrigation-related alerts to the centralized irrigation system serving the `ENTIRE FIELD`, and attribute telemetry/sensor alerts to their specific originating monitoring node (`Q1`, `Q2`, `Q3`, `Q4`, or Gateway).

#### Scenario: Distinguishing centralized irrigation alerts from quadrant monitoring alerts
- **WHEN** an alert entry is rendered in the list or detail view
- **THEN** irrigation start/stop/failure alerts explicitly display the source as Centralized Irrigation (`ENTIRE FIELD`), while node alerts display their specific quadrant (`Q1`–`Q4`) or Gateway source.

### Requirement: Alert detail inspection, read state tracking, and action guidance
The system SHALL allow users to select an alert entry to view detailed information including event description, exact timestamp, source hardware ID, severity, read/unread status toggle, and actionable remediation steps.

#### Scenario: Viewing alert detail and marking as read
- **WHEN** the user selects an alert item from the list
- **THEN** the system opens the Alert Detail screen with contextual action guidance and marks the alert as read.

### Requirement: Robust alert hub state management
The system SHALL handle loading, empty alert history, stale telemetry warnings, and communication error states using standardized design system widgets.

#### Scenario: Presenting empty state when no alerts exist
- **WHEN** there are no active or historical system alerts
- **THEN** an empty state card is displayed informing the user that all field monitoring nodes and centralized irrigation systems are operating normally.

