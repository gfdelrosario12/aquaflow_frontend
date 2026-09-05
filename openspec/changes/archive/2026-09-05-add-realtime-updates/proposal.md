## Why

AquaSense operators currently depend on manual refreshes or periodic REST reads to see changing field conditions, device health, irrigation state, and alerts. A backend-mediated real-time channel is needed so the mobile app can present timely updates while remaining resilient when connectivity is intermittent and preserving the centralized irrigation architecture.

## What Changes

- Add a real-time client boundary using a backend-mediated channel such as WebSocket, with the backend remaining responsible for receiving LoRaWAN/MQTT field data.
- Support validated real-time events for water measurements from Q1-Q4, sensor status changes, gateway status, centralized irrigation state, irrigation events, controller events, and alerts.
- Add connection lifecycle state, authentication integration, reconnect/backoff behavior, duplicate-event handling, event validation, and app foreground/background handling.
- Update relevant Flutter state providers and screens reactively without requiring manual refresh when the real-time channel is connected.
- Gracefully degrade to REST polling or cached state when the channel is unavailable, stale, unauthorized, or malformed.
- Preserve the distinction between independently identified monitoring events and the single centralized entire-field irrigation system.
- Never create real-time zone-specific irrigation controls or direct mobile-to-LoRaWAN/MQTT communication.

## Capabilities

### New Capabilities
- `realtime-updates`: Provides backend-mediated real-time event transport, validation, deduplication, connection lifecycle management, state fan-out, and REST/cache fallback for AquaSense monitoring, diagnostics, alerts, and centralized irrigation state.

### Modified Capabilities

## Impact

- **Transport**: New WebSocket/realtime client, event envelope parsing, authentication, reconnect policy, and fallback polling coordination.
- **Domain/data**: Typed event models, validators, deduplication state, connection state, and adapters into existing repository/notifier contracts.
- **Presentation**: Home/field monitoring, diagnostics, alerts, and centralized control state providers update from real-time events while exposing connection/degraded indicators.
- **Lifecycle**: App foreground/background and logout behavior start, pause, resume, or close the channel safely.
- **Safety**: Monitoring events may carry Q1-Q4 identifiers, but irrigation events and state remain scoped to the centralized `ENTIRE FIELD` system.
- **Testing**: Event parsing/validation, duplicate suppression, reconnect behavior, fallback polling, lifecycle transitions, and scope-isolation tests.
