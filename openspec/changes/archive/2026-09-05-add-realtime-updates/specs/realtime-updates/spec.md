## ADDED Requirements

### Requirement: Backend-mediated real-time transport
The system SHALL provide a real-time service that connects the Flutter application to backend-published events through an authenticated channel such as WebSocket. The mobile app MUST NOT connect directly to LoRaWAN, MQTT brokers, radio hardware, BLE devices, or gateways.

#### Scenario: App establishes an authenticated real-time session
- **WHEN** an authenticated operator brings the app to the foreground
- **THEN** the real-time service connects to the backend channel, authenticates the session, subscribes to authorized event streams, and exposes its connection state.

### Requirement: Typed event coverage
The system SHALL support validated events for water measurements identified by Q1-Q4, sensor status changes, gateway status, centralized irrigation state changes, irrigation events, controller events, and alerts.

#### Scenario: Backend publishes a monitoring event
- **WHEN** the backend publishes a valid measurement or sensor-status event for Q1, Q2, Q3, or Q4
- **THEN** the real-time service validates it and updates the corresponding monitoring or diagnostics state without requiring manual refresh.

#### Scenario: Backend publishes a field event
- **WHEN** the backend publishes a valid gateway, irrigation, controller, or alert event
- **THEN** the real-time service validates it and updates the corresponding feature state without requiring manual refresh.

### Requirement: Event validation and domain mapping
The system SHALL validate event version, event ID, event type, timestamp, sequence metadata, scope, and required payload fields before mapping an event into domain state. Invalid or unsupported events SHALL be rejected without mutating feature state.

#### Scenario: Malformed event is received
- **WHEN** an event has an unsupported version, missing required metadata, invalid payload fields, or an invalid scope
- **THEN** the service records a validation/degraded signal, discards the event, and preserves the last valid state.

### Requirement: Duplicate and out-of-order event handling
The system SHALL suppress duplicate event IDs and SHALL prevent older sequence or timestamp values from overwriting newer state for the same aggregate.

#### Scenario: Duplicate event is delivered after reconnect
- **WHEN** the same event ID is received more than once
- **THEN** only the first valid event changes application state.

#### Scenario: Delayed event arrives after newer state
- **WHEN** an event has an older sequence or timestamp than the latest accepted event for its aggregate
- **THEN** the service does not regress displayed state and exposes stale/out-of-order diagnostics when appropriate.

### Requirement: Connection lifecycle and reconnect behavior
The system SHALL expose disconnected, connecting, connected, reconnecting, degraded, and closed states, SHALL reconnect with bounded backoff while foregrounded, and SHALL close or pause the channel on logout/background lifecycle transitions.

#### Scenario: Real-time channel disconnects
- **WHEN** an established channel disconnects while the app is foregrounded
- **THEN** the service enters reconnecting/degraded state, retries with bounded backoff, and does not create duplicate subscriptions.

#### Scenario: App resumes after backgrounding
- **WHEN** the app returns to the foreground after the channel was paused or closed
- **THEN** the service bootstraps current state from REST, reconnects the authorized channel, and resumes event delivery.

### Requirement: REST polling and cached-state degradation
The system SHALL gracefully fall back to REST polling or the last valid cached state when real-time delivery is unavailable, stale, unauthorized, or repeatedly failing. Fallback SHALL be observable to relevant screens.

#### Scenario: Channel remains unavailable
- **WHEN** reconnect attempts reach the configured limit or event freshness exceeds the threshold
- **THEN** the service enters degraded mode, starts appropriate REST polling, and displays the last valid state with a connection/freshness indicator.

#### Scenario: Channel recovers after polling
- **WHEN** a healthy real-time connection is re-established
- **THEN** the service stops redundant fallback polling after a successful bootstrap and returns to connected event-driven updates.

### Requirement: Reactive feature state updates
The system SHALL fan validated real-time events into existing monitoring, diagnostics, alert, analytics, and centralized irrigation state abstractions so relevant screens update without manual refresh.

#### Scenario: Measurement and alert arrive while a screen is open
- **WHEN** a valid measurement and alert event are received
- **THEN** the field/analytics and alert state providers notify their listeners and the visible screens reflect the updates.

### Requirement: Centralized irrigation event scope
The system SHALL allow Q1-Q4 identifiers only for monitoring event context. Irrigation state changes, irrigation events, and controller events MUST represent the single centralized system with scope `ENTIRE FIELD`; real-time events MUST NOT create zone-specific irrigation controls.

#### Scenario: Invalid zone-scoped irrigation event is received
- **WHEN** an irrigation or controller event contains Q1, Q2, Q3, Q4, or another zone-specific actuator scope
- **THEN** the service rejects the event, records a validation error, and does not expose or create a zone-level control state.

#### Scenario: Central irrigation event is received
- **WHEN** a valid irrigation or controller event identifies `ENTIRE FIELD`
- **THEN** the centralized irrigation state is updated and existing field-level control views receive the event without creating per-zone actuators.
