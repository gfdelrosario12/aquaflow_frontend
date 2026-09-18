## MODIFIED Requirements

### Requirement: Typed event coverage
The system SHALL support validated events for water measurements identified by dynamic node IDs or legacy Q1-Q4 scopes, sensor and node status changes, gateway status, centralized irrigation state changes, irrigation events, controller events, alerts, and node transmission interval updates.

#### Scenario: Backend publishes a monitoring event
- **WHEN** the backend publishes a valid measurement or sensor-status event for a dynamic node ID or Q1–Q4
- **THEN** the real-time service validates it and updates the corresponding monitoring or diagnostics state without requiring manual refresh.

#### Scenario: Backend publishes a field event
- **WHEN** the backend publishes a valid gateway, irrigation, controller, or alert event
- **THEN** the real-time service validates it and updates the corresponding feature state without requiring manual refresh.

#### Scenario: Backend publishes a node transmission interval update
- **WHEN** the backend publishes a transmission interval updated event for a registered ESP32 node
- **THEN** the real-time service validates it and updates the node's active interval and adaptive status in real time.

### Requirement: Event validation and domain mapping
The system SHALL validate event version, event ID, event type, timestamp, sequence metadata, scope, and required payload fields before mapping an event into domain state. Valid monitoring scopes SHALL include dynamic node identifiers as well as quadrant identifiers. Invalid or unsupported events SHALL be rejected without mutating feature state.

#### Scenario: Malformed event is received
- **WHEN** an event has an unsupported version, missing required metadata, invalid payload fields, or an invalid scope
- **THEN** the service records a validation/degraded signal, discards the event, and preserves the last valid state.

#### Scenario: Valid dynamic node event is received
- **WHEN** an event with a valid dynamic node ID scope and valid payload arrives
- **THEN** the service successfully validates the event and dispatches it to registered node adapters.

