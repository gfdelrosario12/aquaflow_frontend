## Why

AquaSense operators need useful field context when connectivity is intermittent, but cached data must never be mistaken for live backend confirmation, especially for pump and valve state. Offline support should preserve recent monitoring and analysis context while explicitly degrading confidence and blocking unsafe centralized irrigation commands until backend/controller connectivity is confirmed.

## What Changes

- Add network detection and an offline/degraded connectivity state shared by relevant screens and repositories.
- Persist the most recent field summary, Q1-Q4 measurements, historical visualization data, AWD analysis results, alerts, device/gateway status, and last confirmed centralized irrigation state.
- Add cache metadata, expiration/staleness rules, schema/version handling, and cache invalidation or recovery behavior.
- Render cached information with explicit stale/offline labeling and loading states; never present cached pump or valve state as live confirmed state.
- Synchronize or refresh cached data when connectivity returns, with deterministic conflict and failure handling.
- Add offline banners, recovery feedback, retry behavior, and graceful fallbacks for screens using REST and real-time data.
- Block centralized irrigation commands while backend/controller connectivity cannot be confirmed; no emergency mechanism is introduced by this change.
- Preserve Q1-Q4 as monitoring zones and keep irrigation centralized for `ENTIRE FIELD`.

## Capabilities

### New Capabilities
- `offline-support`: Provides network-aware local persistence, cache freshness semantics, stale-state presentation, recovery synchronization, and safe offline behavior for AquaSense data and centralized irrigation actions.

### Modified Capabilities

## Impact

- **Infrastructure**: Network connectivity service, local persistence/cache repository, cache metadata and expiration policy.
- **Data and domain**: Offline-aware result/state models, cached snapshots, synchronization orchestration, and live-confirmation markers for irrigation telemetry.
- **Presentation**: Shared offline/degraded banners, stale labels, loading/error/retry states, and screen-specific cache indicators across field, analytics, alerts, diagnostics, and control.
- **Control safety**: Centralized irrigation command availability depends on confirmed backend/controller connectivity; cached pump/valve data remains informational only.
- **Testing**: Cache serialization/expiration, network transitions, recovery sync, stale rendering, command blocking, and Q1-Q4/`ENTIRE FIELD` scope safety.
