## MODIFIED Requirements

### Requirement: Typed event coverage
The system SHALL support validated real-time events for dynamic node discovery, node status changes, dynamic node replacement/reassignment, LoRaWAN telemetry, LoRaWAN device status, AWD analysis updates, centralized irrigation state changes, manual control operation events, automatic irrigation events, controller events, alerts, and audit log entries across Flutter Android and Web platforms.

#### Scenario: Backend publishes a monitoring event
- **WHEN** the backend publishes a valid measurement or sensor-status event for a dynamic node ID or Q1–Q4
- **THEN** the real-time service validates it and updates the corresponding monitoring or diagnostics state without requiring manual refresh.

#### Scenario: Backend publishes a dynamic node lifecycle event
- **WHEN** the backend publishes a node discovered, status updated, or reassigned event for a dynamic sensor node
- **THEN** the real-time service validates the event and dynamically updates active node registration and zone assignment state without requiring an application rebuild or manual refresh.

#### Scenario: Backend publishes LoRaWAN telemetry and device status events
- **WHEN** the backend publishes a LoRaWAN telemetry update or gateway/device connectivity status event
- **THEN** the real-time service validates it and updates the corresponding node sensor metrics and link connectivity status in real time.

#### Scenario: Backend publishes AWD analysis and manual control events
- **WHEN** the backend publishes an AWD analytics result, centralized irrigation state transition, manual control override event, or account audit log entry
- **THEN** the real-time service validates it and updates field monitoring and audit log screens without requiring manual refresh.

#### Scenario: Backend publishes a field event
- **WHEN** the backend publishes a valid gateway, irrigation, controller, or alert event
- **THEN** the real-time service validates it and updates the corresponding feature state without requiring manual refresh.

#### Scenario: Backend publishes a node transmission interval update
- **WHEN** the backend publishes a transmission interval updated event for a registered ESP32 node
- **THEN** the real-time service validates it and updates the node's active interval and adaptive status in real time.

### Requirement: Event validation and domain mapping
The system SHALL validate event version, event ID, event type, timestamp, sequence metadata, field scope, node scope, and required payload fields before mapping an event into domain state. Valid monitoring scopes SHALL include dynamic node identifiers as well as quadrant identifiers. Centralized irrigation and manual control events MUST be strictly scoped to `ENTIRE FIELD`. Invalid or unsupported events SHALL be rejected without mutating feature state.

#### Scenario: Malformed event is received
- **WHEN** an event has an unsupported version, missing required metadata, invalid payload fields, or an invalid scope
- **THEN** the service records a validation/degraded signal, discards the event, and preserves the last valid state.

#### Scenario: Valid dynamic node event is received
- **WHEN** an event with a valid dynamic node ID scope and valid payload arrives
- **THEN** the service successfully validates the event and dispatches it to registered node adapters.

#### Scenario: Centralized irrigation event with invalid scope is received
- **WHEN** an irrigation, manual control, or controller event contains a zone-specific identifier instead of `ENTIRE FIELD`
- **THEN** the real-time service rejects the event with a validation error and does not mutate irrigation control state.

### Requirement: Connection lifecycle and reconnect behavior
The system SHALL expose disconnected, connecting, connected, reconnecting, degraded, and closed states, SHALL reconnect with exponential backoff while foregrounded, SHALL bootstrap current state from authoritative REST endpoints upon successful reconnection, and SHALL close or pause the channel on logout/background lifecycle transitions.

#### Scenario: Real-time channel disconnects
- **WHEN** an established channel disconnects while the app is foregrounded
- **THEN** the service enters reconnecting/degraded state, retries with bounded backoff, and does not create duplicate subscriptions.

#### Scenario: App resumes after backgrounding
- **WHEN** the app returns to the foreground after the channel was paused or closed
- **THEN** the service bootstraps current state from REST, reconnects the authorized channel, and resumes event delivery.

#### Scenario: Channel re-establishes after network failure
- **WHEN** a broken real-time channel re-establishes connectivity
- **THEN** the service bootstraps current state from authoritative backend REST APIs to reconcile missed state changes, reconnects the authorized channel, and resumes live event processing.

### Requirement: REST polling and cached-state degradation
The system SHALL gracefully fall back to REST polling or the last valid cached state when real-time delivery is unavailable, stale beyond configured thresholds, unauthorized, or repeatedly failing. Fallback state and data freshness SHALL be observable to connected views.

#### Scenario: Channel remains unavailable
- **WHEN** reconnect attempts reach the configured limit or event freshness exceeds the threshold
- **THEN** the service enters degraded mode, starts appropriate REST polling, and displays the last valid state with a connection/freshness indicator.

#### Scenario: Channel recovers after polling
- **WHEN** a healthy real-time connection is re-established
- **THEN** the service performs a bootstrap resynchronization, stops redundant fallback polling, and returns to connected event-driven updates.

