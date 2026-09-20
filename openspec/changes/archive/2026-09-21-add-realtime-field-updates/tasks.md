## 1. Domain & Core Real-Time Contracts

- [x] 1.1 Define real-time event envelope models, event types, dynamic scope objects, and JSON serialization methods.
- [x] 1.2 Implement event validation service enforcing event version, schema, dynamic node scopes, and ENTIRE FIELD scope for irrigation events.
- [x] 1.3 Create event deduplication and out-of-order sequence tracking logic.

## 2. Infrastructure & Connection Lifecycle Services

- [x] 2.1 Implement RealtimeWebSocketClient with authenticated connection handshake and heartbeat handling.
- [x] 2.2 Add exponential backoff reconnection manager and connection state stream (connected, reconnecting, degraded, closed).
- [x] 2.3 Implement REST bootstrap state hydration service to reconcile field state on initial connect and reconnect.
- [x] 2.4 Implement degraded mode handler with automatic fallback REST polling when WebSocket connection fails or stale threshold is reached.

## 3. Riverpod State Notifiers & Domain Fanning

- [x] 3.1 Create RealtimeEventNotifier to consume validated stream events and fan out to domain providers.
- [x] 3.2 Update dynamicNodeListNotifierProvider to dynamically register, update, reassign, and remove sensor nodes without app restart.
- [x] 3.3 Update telemetryStateNotifierProvider to ingest dynamic node LoRaWAN telemetry and connectivity status updates.
- [x] 3.4 Update centralIrrigationNotifierProvider and manualControlNotifierProvider for real-time field irrigation state changes and manual override events.
- [x] 3.5 Update auditLogNotifierProvider and awdAnalyticsNotifierProvider to update audit screens and AWD status live.

## 4. UI Integration & Diagnostics

- [x] 4.1 Implement real-time connection status banner/indicator across dashboard, monitoring, manual control, and audit views.
- [x] 4.2 Update field monitoring widgets to render dynamic node updates without fixed node/zone assumptions.

## 5. Verification & Testing

- [x] 5.1 Add unit tests for event validation, envelope parsing, and sequence deduplication.
- [x] 5.2 Add unit tests for connection lifecycle state transitions, exponential backoff, and REST bootstrap state hydration.
- [x] 5.3 Add widget tests for real-time connection status indicators and dynamic node list UI updates.
