## Context

AquaSense already has REST repositories, a backend-mediated realtime channel, feature notifiers, and centralized irrigation control. Offline support must sit below those consumers as an explicit cache/network state boundary. Cached monitoring and analysis can help operators orient themselves, but cached actuator state cannot be treated as live confirmation and must never authorize a command.

## Goals / Non-Goals

**Goals:**
- Detect network availability and expose online, offline, degraded, synchronizing, and recovery states.
- Persist typed snapshots for field summary, Q1-Q4 measurements/history, AWD results, alerts, devices/gateway, and the last confirmed centralized irrigation state.
- Attach freshness metadata, source, schema version, and confirmation level to every cached snapshot.
- Define per-resource expiration/staleness policy and clear UI semantics for loading, cached, stale, unavailable, and live-confirmed data.
- Synchronize or revalidate cached resources after connectivity returns, with safe handling of partial failures and concurrent realtime/REST updates.
- Block centralized irrigation commands unless backend and controller connectivity are currently confirmed; no emergency mechanism is introduced.

**Non-Goals:**
- Implementing an emergency irrigation control path.
- Treating cached pump/valve state as command authorization or live telemetry.
- Replacing REST/realtime services or changing domain ownership of Q1-Q4 monitoring and centralized irrigation.
- Persisting sensitive authentication secrets in the general-purpose cache.

## Decisions

### 1. Typed cache envelope with confidence metadata

- **Decision**: Persist each resource as a typed cache envelope containing schema version, resource key, fetched/confirmed time, expiration/stale thresholds, source (`rest`, `realtime`, or `cache`), and confirmation level (`live`, `recent`, `stale`, `unconfirmed`).
- **Rationale**: Consumers can render cached context while distinguishing it from current backend-confirmed state, especially for irrigation telemetry.
- **Alternative considered**: Persisting raw JSON without metadata was rejected because screens cannot safely determine freshness or confidence.

### 2. Resource-specific freshness policy

- **Decision**: Configure freshness windows by resource class: short windows for device/gateway and irrigation status, moderate windows for field/measurement/alerts, and longer windows for historical measurements and AWD analysis. Expiration makes data unavailable for safety-sensitive use while stale data may remain viewable with a banner.
- **Rationale**: A single cache timeout would either discard useful history too aggressively or leave operational state misleadingly fresh.
- **Alternative considered**: One global TTL was rejected because controller state and historical analytics have different risk profiles.

### 3. Repository decorator and cache-first read policy

- **Decision**: Wrap existing REST/realtime repositories with an offline-aware data source. Read live data when online; on failure or offline status, return the newest valid cached snapshot with explicit metadata. Writes for centralized irrigation are never queued implicitly.
- **Rationale**: Existing feature consumers keep their domain interfaces while offline behavior remains centralized and testable.
- **Alternative considered**: Adding cache logic inside each screen was rejected because it duplicates stale semantics and creates inconsistent safety behavior.

### 4. Recovery synchronization coordinator

- **Decision**: On network recovery, synchronize/revalidate resource snapshots in dependency order, deduplicate concurrent work, update caches only after successful validation, and retain failed resource caches with recovery errors.
- **Rationale**: Partial backend availability should not erase useful cached data or create a false all-clear state.
- **Alternative considered**: Clearing all cache before recovery was rejected because it causes empty screens and loses operator context.

### 5. Live confirmation gate for irrigation

- **Decision**: Centralized irrigation command authorization requires online network state, a non-stale authenticated backend session, and current controller connectivity confirmation from REST/realtime. Cached pump/valve state is display-only and cannot satisfy the gate. Commands target `ENTIRE FIELD` only.
- **Rationale**: Stale actuator state can be unsafe; blocking is preferable to pretending a command was accepted.
- **Alternative considered**: Queuing commands for later replay was rejected because delayed irrigation can become unsafe and no emergency mechanism is authorized here.

### 6. Presentation state and recovery signals

- **Decision**: Expose shared connectivity/cache metadata so screens render offline banners, stale labels, loading states, retry/recovery feedback, and live-confirmed badges consistently.
- **Rationale**: Operators need to understand both the value and confidence of what they see.
- **Alternative considered**: A single generic error state was rejected because offline cached data is useful but must be clearly qualified.

## Risks / Trade-offs

- **[Risk: Cached storage grows with history]** -> **Mitigation**: Bound historical entries, enforce per-resource size/TTL limits, and evict oldest data first while preserving the latest operational snapshots.
- **[Risk: Device clock differs from backend time]** -> **Mitigation**: Prefer backend timestamps and store server-confirmed freshness metadata; treat uncertain timestamps conservatively.
- **[Risk: Recovery sync races with realtime events]** -> **Mitigation**: Apply source sequence/timestamp ordering and serialize cache writes per resource key.
- **[Risk: Operators misread stale actuator state]** -> **Mitigation**: Use explicit stale/unconfirmed labels, disable control actions, and never call cached state live.
- **[Risk: Network flaps cause sync loops]** -> **Mitigation**: Debounce recovery events, cap retries, and expose degraded status until a complete validation succeeds.

## Migration Plan

1. Add connectivity, cache envelope, persistence, and freshness policy services without changing existing domain models.
2. Decorate REST/realtime reads and notifiers with cache-aware results and shared banners/metadata.
3. Add the centralized irrigation live-confirmation gate and disable offline command submission.
4. Add recovery synchronization and cache migration/schema invalidation for future changes.
5. Roll back by disabling cache decorators and offline UI while retaining existing REST/realtime behavior; no cache contents are treated as authoritative during rollback.

## Open Questions

- Which local persistence implementation should be selected for production scale and encryption requirements?
- What exact freshness windows should operations approve for each resource class?
- Should historical measurement retention be configurable by deployment or fixed by the backend contract?
- Which controller heartbeat endpoint/event is authoritative for the live-command gate?
