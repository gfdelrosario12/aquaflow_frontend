## 1. Real-Time Transport and Event Contract

- [x] 1.1 Add the WebSocket-capable transport dependency and environment-aware real-time URL/subscription configuration.
- [x] 1.2 Define `RealtimeTransport` and fake transport interfaces for connect, authenticated subscribe, message delivery, errors, and close operations.
- [x] 1.3 Define versioned event envelope models and typed events for measurements, sensor status, gateway status, centralized irrigation state/events, controller events, and alerts.
- [x] 1.4 Implement event decoding, required-field validation, supported-version checks, payload validation, and typed validation errors.
- [x] 1.5 Implement redacted event diagnostics so tokens and sensitive command data are never logged.

## 2. Connection, Authentication, and Lifecycle

- [x] 2.1 Implement connection states for disconnected, connecting, connected, reconnecting, degraded, and closed.
- [x] 2.2 Integrate authenticated channel handshake/subscription with the existing access-token and logout lifecycle.
- [x] 2.3 Implement bounded exponential reconnect backoff with jitter, duplicate-subscription prevention, and reconnect-attempt limits.
- [x] 2.4 Handle Flutter foreground/background lifecycle transitions by pausing/closing and resuming/bootstraping the real-time session safely.

## 3. Event Ordering, Fan-Out, and Fallback

- [x] 3.1 Implement bounded event-ID deduplication and per-aggregate sequence/timestamp ordering checks.
- [x] 3.2 Implement `RealtimeCoordinator` dispatching validated events to monitoring, diagnostics, analytics, alerts, and centralized irrigation state adapters.
- [x] 3.3 Add REST bootstrap and fallback polling coordination when the channel is unavailable, stale, unauthorized, or repeatedly failing.
- [x] 3.4 Retain and expose the last valid cached state while degraded, including freshness and connection indicators.
- [x] 3.5 Stop redundant fallback polling after a healthy real-time connection and bootstrap succeed.

## 4. Feature Integration and Safety

- [x] 4.1 Update monitoring, diagnostics, analytics, alert, and centralized-control notifiers/screens to consume coordinator updates without manual refresh.
- [x] 4.2 Enforce that Q1-Q4 identifiers are accepted only for monitoring event context and never create actuator controls.
- [x] 4.3 Enforce `ENTIRE FIELD` scope for irrigation/controller events and reject invalid zone-specific event scopes before state mutation.
- [x] 4.4 Verify the mobile real-time implementation communicates only with the backend service and has no direct LoRaWAN, MQTT broker, radio, BLE, or gateway hardware path.

## 5. Verification and Documentation

- [x] 5.1 Add event envelope, payload validation, typed mapping, malformed-event, and unsupported-version tests.
- [x] 5.2 Add transport tests for connection states, auth handshake, reconnect backoff, duplicate subscriptions, lifecycle transitions, and logout cleanup.
- [x] 5.3 Add deduplication, ordering, fallback polling, cached-state, and recovery tests.
- [x] 5.4 Add feature fan-out and irrigation-scope safety tests proving Q1-Q4 monitoring events remain read-only and centralized irrigation events remain field-level.
- [x] 5.5 Document real-time configuration, event envelope/versioning, freshness thresholds, fallback behavior, and backend-mediated architecture.
- [x] 5.6 Run `flutter analyze`, focused real-time tests, and the full `flutter test` suite.
