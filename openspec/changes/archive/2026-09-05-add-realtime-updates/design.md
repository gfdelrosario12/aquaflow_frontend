## Context

AquaSense already has REST-backed repository and notifier abstractions for monitoring zones, diagnostics, alerts, analytics, and centralized irrigation. Real-time updates must complement those contracts rather than create a second domain model or control plane. The backend receives LoRaWAN/MQTT data and publishes authorized application events; the Flutter app consumes only the backend-mediated channel.

## Goals / Non-Goals

**Goals:**
- Add a transport-neutral real-time service boundary with a WebSocket-capable implementation and a fake implementation for tests.
- Define a versioned, typed event envelope with event ID, event type, sequence/timestamp, scope, and payload validation.
- Fan validated events into existing feature state through a central coordinator/notifier rather than direct widget subscriptions.
- Handle connection states, auth/session changes, app lifecycle, reconnect backoff, duplicate events, and graceful REST/cache fallback.
- Preserve Q1-Q4 as monitoring identifiers only and represent irrigation/controller events as centralized `ENTIRE FIELD` state.

**Non-Goals:**
- Direct LoRaWAN, MQTT, radio, BLE, or gateway hardware connections from the mobile app.
- Implementing backend brokers, LoRaWAN ingestion, event persistence, or server-side fan-out.
- Replacing REST as the authoritative bootstrap and fallback data source.
- Adding real-time controls for individual zones or quarters.

## Decisions

### 1. Backend-mediated channel with transport interface

- **Decision**: Define a `RealtimeTransport` interface with connect, authenticated subscribe, message stream, and close operations. Implement WebSocket transport against the backend channel and a fake transport for tests.
- **Rationale**: Keeps protocol details out of domain state and allows transport replacement without changing event consumers.
- **Alternative considered**: Direct socket handling in each screen was rejected because it duplicates lifecycle and reconnect policy.

### 2. Versioned typed event envelope

- **Decision**: Require an envelope containing `version`, `eventId`, `eventType`, `occurredAt`, `sequence`, `scope`, and `payload`. Parse known event types into typed events for measurement, sensor status, gateway, irrigation state/event, controller event, and alert updates.
- **Rationale**: Event IDs support duplicate suppression, sequence/timestamp support ordering/staleness checks, and typed payloads prevent malformed events from reaching domain state.
- **Alternative considered**: Passing arbitrary JSON maps downstream was rejected because it makes validation and scope enforcement inconsistent.

### 3. Central realtime coordinator and state adapters

- **Decision**: A `RealtimeCoordinator` owns the connection and dispatches typed events to feature adapters/notifiers. Adapters update existing state or invalidate/refetch through REST; widgets observe existing notifiers.
- **Rationale**: The coordinator centralizes connection policy while preserving current domain and presentation boundaries.
- **Alternative considered**: A global event bus consumed directly by widgets was rejected because it bypasses domain validation and complicates lifecycle cleanup.

### 4. Deduplication and ordering policy

- **Decision**: Track a bounded event-ID cache and ignore duplicate IDs. For sequence-aware streams, reject older sequence values per aggregate; otherwise accept newer timestamps and mark stale/out-of-order events as non-applying diagnostics.
- **Rationale**: Mobile reconnects and broker retries can deliver duplicates or delayed events; state must not regress silently.
- **Alternative considered**: Applying every event in arrival order was rejected because delayed events can overwrite current telemetry.

### 5. Connection lifecycle and fallback

- **Decision**: Model `disconnected`, `connecting`, `connected`, `reconnecting`, `degraded`, and `closed` states. Reconnect with bounded exponential backoff while foregrounded, pause/close when backgrounded, and resume with REST bootstrap. When disconnected or stale beyond a threshold, use REST polling and retain the last valid cached state.
- **Rationale**: Operators need useful data even when real-time delivery is unavailable, without creating aggressive battery/network behavior.
- **Alternative considered**: Permanent socket reconnect loops were rejected because they waste battery and obscure degraded service state.

### 6. Authentication and logout integration

- **Decision**: Open the channel only for an authenticated session, attach the access token during handshake/subscription, reconnect after token refresh, and close/clear subscriptions on logout.
- **Rationale**: Event streams may contain field and actuator data and must follow the existing authentication lifecycle.
- **Alternative considered**: Anonymous channel connections were rejected because they risk leaking operational telemetry.

### 7. Irrigation scope enforcement

- **Decision**: Measurement and sensor events may identify Q1-Q4. Irrigation state, irrigation events, and controller events must carry `ENTIRE FIELD`; invalid event scope is rejected and logged as a validation error. No event produces zone-level actuator controls.
- **Rationale**: Real-time data must reinforce the centralized irrigation architecture rather than introduce a hidden per-zone control model.
- **Alternative considered**: Treating every event with a quarter identifier uniformly was rejected because monitoring identity is not actuator scope.

## Risks / Trade-offs

- **[Risk: Event schema evolves independently of the mobile release]** -> **Mitigation**: Version envelopes, reject unsupported versions safely, and retain REST fallback.
- **[Risk: Duplicate or delayed messages regress displayed telemetry]** -> **Mitigation**: Event-ID cache, per-aggregate sequence checks, timestamp validation, and stale indicators.
- **[Risk: Reconnect storms drain battery]** -> **Mitigation**: Exponential backoff, foreground-only reconnecting, jitter, and capped attempts before degraded polling.
- **[Risk: Real-time and REST updates race]** -> **Mitigation**: Central coordinator serializes state application and uses event sequence/timestamps to prevent older bootstrap data from overwriting newer events.
- **[Risk: Unauthorized events reach the app]** -> **Mitigation**: Authenticate handshake/subscription, validate event scope, and drop invalid/unauthorized messages before adapters.

## Migration Plan

1. Add event models, validators, deduplication, connection state, and transport interfaces without changing existing screens.
2. Implement WebSocket transport and fake transport, then add coordinator adapters for monitoring, diagnostics, alerts, and centralized irrigation state.
3. Bootstrap state from REST on connect/resume and activate polling/cache fallback when disconnected or stale.
4. Wire existing notifiers/screens to coordinator-fed state and expose connection/degraded indicators.
5. Roll back by disabling real-time transport and continuing REST polling/mock behavior; no domain model rollback is required.

## Open Questions

- What backend WebSocket URL, subscription topic format, and authorization handshake are required?
- Does the backend guarantee per-aggregate sequence ordering, or must the mobile client rely on timestamps?
- What event freshness thresholds should trigger degraded polling for each resource type?
- Which REST polling intervals are acceptable for foreground and background modes?
