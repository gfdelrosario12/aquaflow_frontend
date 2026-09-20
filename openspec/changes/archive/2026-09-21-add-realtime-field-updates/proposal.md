## Why

AquaSense requires a comprehensive, backend-driven real-time update architecture to keep connected Flutter Android and Web applications synchronized with field operations. As monitoring nodes, sensor measurements, AWD analytics, alerts, and field-wide irrigation states change on the backend, clients must receive live updates via authenticated WebSockets without requiring app reloads or hardcoding fixed node counts. The backend remains the authoritative source of truth, while clients handle stream decoding, deduplication, state bootstrapping, and graceful fallback.

## What Changes

- **Backend-Driven Real-time Event Subscriptions**: Expand the real-time transport to cover dynamic sensor measurements, node status, alerts, AWD analysis results, centralized irrigation state transitions, automatic AWD triggers, manual override operations, and account audit events across Flutter Android and Web.
- **Dynamic Node Stream Integration**: Stream newly registered (`nodeDiscovered`), modified (`nodeLifecycleUpdated`), and replaced (`nodeReplaced`) node events so connected clients render node topology updates dynamically without application rebuilds.
- **Connection Lifecycle & Resynchronization**: Define connection states (`disconnected`, `connecting`, `connected`, `reconnecting`, `degraded`, `closed`), automatic exponential backoff reconnection, token refresh on reconnect, and full state bootstrapping from REST upon reconnecting.
- **Stale Data & Fallback Polling**: Implement stale data detection thresholds and fallback REST polling when WebSocket connectivity is lost or degraded.
- **Ordering & Deduplication**: Enforce event sequence numbers, ISO 8601 timestamps, and deduplication of duplicate event IDs.
- **Field & Irrigation Isolation**: Maintain strict field-level scoping (`ENTIRE FIELD`) for irrigation and controller events while allowing dynamic node IDs and zone scopes for telemetry events.

## Capabilities

### Modified Capabilities

- `realtime-updates`: Extend backend-driven real-time event contracts, dynamic node lifecycle stream handling, state resynchronization on reconnect, stale data degradation, and field/zone scope enforcement.

## Impact

- **Frontend Core Services**: Enhances `RealtimeCoordinator` and `RealtimeEvent` parsers in `lib/core/realtime/` to support node discovery, lifecycle, replacement, AWD analysis, and audit events.
- **Feature Providers**: Wires Riverpod state notifiers across `NodeManagementNotifier`, `LoRaWANNodeNotifier`, `AwdAnalyticsNotifier`, `ManualControlNotifier`, `AuditNotifier`, and `DiagnosticsNotifier` to consume live backend events.
- **Client Resilience**: Guarantees zero state drift by performing a full REST bootstrap resynchronization whenever a WebSocket connection is re-established.

