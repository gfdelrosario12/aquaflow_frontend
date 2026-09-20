## Context

See `proposal.md` and `specs/realtime-updates/spec.md`.
The AquaFlow Flutter frontend currently relies on REST calls for field status and manual intervention. To support dynamic LoRaWAN sensor node additions, real-time telemetry, AWD analytics updates, centralized manual/automatic irrigation state changes, and live audit event streams across Android and Web clients, a robust backend-driven real-time update engine is required.

## Goals / Non-Goals

**Goals:**
- Provide a unified, authenticated WebSocket event channel for dynamic sensor measurements, node status, LoRaWAN device updates, AWD analysis results, centralized irrigation state, manual override operations, and account audit logs.
- Implement bootstrap state resynchronization via REST on connection establishment and reconnection.
- Support observable connection lifecycle states (`connected`, `reconnecting`, `degraded`, `closed`) with fallback REST polling when real-time channels are unavailable or degraded.
- Enforce strict domain scope validation: dynamic node ID scopes for node telemetry/lifecycle events, and `ENTIRE FIELD` scope for centralized irrigation/manual control events.
- Dynamically integrate state updates into Riverpod providers without requiring application rebuilds.

**Non-Goals:**
- Direct Flutter client communication with LoRaWAN gateways, network servers, or MQTT brokers.
- Zone-specific irrigation control actuators or zone-scoped manual overrides.
- Offline peer-to-peer mesh synchronization between client devices.

## Decisions

### 1. Unified Event Envelope and Stream Transport
- **Decision:** Use a single authenticated WebSocket connection carrying standard JSON-enveloped events.
- **Envelope Structure:**
  ```json
  {
    "event_id": "evt_123456789",
    "version": "1.0",
    "event_type": "node_discovered | lorawan_telemetry | irrigation_state_changed | manual_control_executed | audit_event",
    "timestamp": "2026-09-21T00:57:00Z",
    "sequence": 1042,
    "scope": {
      "target": "FIELD | NODE",
      "id": "ENTIRE FIELD | node_lora_8f3a"
    },
    "payload": {}
  }
  ```
- **Rationale:** Standardizing the event envelope allows a single core stream service (`RealtimeClient`) to perform authentication, sequence check, deduplication, and scope validation before passing payloads to domain-specific feature adapters.

### 2. State Reconciliation Pattern (REST Bootstrap + WebSocket Stream)
- **Decision:** Combine REST snapshot hydration with real-time stream processing.
- **Workflow:**
  1. Client establishes WebSocket connection.
  2. Simultaneously, client triggers `bootstrapState()` via REST API to retrieve authoritative current state snapshot along with the latest backend `sequence_id`.
  3. Real-time events with `sequence <= bootstrap.sequence_id` are ignored to prevent duplicate/stale overwrites.
  4. Subsequent stream events update domain state reactively.
- **Alternatives Considered:** Stream replay over WebSocket upon reconnect. Rejected because REST snapshot endpoint is lighter, cacheable, and simpler to maintain.

### 3. Dynamic Node Adapter and Riverpod Integration
- **Decision:** Implement a centralized `RealtimeEventNotifier` in Riverpod that fanning out events to feature providers:
  - `dynamicNodeListNotifierProvider`: Handles `node_discovered`, `node_status_updated`, `node_reassigned`, `node_replaced`.
  - `telemetryStateNotifierProvider`: Handles `lorawan_telemetry`, `lorawan_device_status`.
  - `centralIrrigationNotifierProvider`: Handles `irrigation_state_changed`, `manual_control_executed`.
  - `auditLogNotifierProvider`: Handles `audit_event_logged`.
  - `awdAnalyticsNotifierProvider`: Handles `awd_analysis_completed`.
- **Rationale:** Keeps UI widgets decoupled from WebSocket details while enabling dynamic widget rendering when nodes are registered or modified at runtime.

### 4. Bounded Reconnection and Fallback Polling Strategy
- **Decision:** Exponential backoff reconnect strategy (1s, 2s, 4s, 8s, max 30s) up to 5 attempts. If re-establishment fails or stream stays silent past freshness threshold (e.g. 60s without heartbeat/event), transition to `degraded` state and initiate 15s REST fallback polling.
- **Rationale:** Prevents UI from displaying stale field telemetry or missing critical manual control updates when mobile network connections drop.

## Risks / Trade-offs

- **[Risk] Sequence Gap / Missed Events during disconnect** → **Mitigation:** On reconnect, client always performs REST bootstrap fetch before resuming stream processing.
- **[Risk] High CPU load from frequent JSON parsing on Web/Android** → **Mitigation:** Parse raw JSON streams in background isolate using Flutter's `compute()` or lightweight isolate pool when payload rate is high.
- **[Risk] Invalid zone-scoped events attempting manual irrigation override** → **Mitigation:** Scope validator immediately drops any irrigation event containing non-`ENTIRE FIELD` scopes and logs a security warning event.

