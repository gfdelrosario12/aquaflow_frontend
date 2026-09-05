## 1. Connectivity and Cache Foundations

- [x] 1.1 Add network connectivity detection with online, offline, degraded, synchronizing, and recovery states.
- [x] 1.2 Define typed cache envelopes containing resource key, schema version, source, fetched/confirmed time, freshness metadata, and confirmation level.
- [x] 1.3 Implement local persistence abstraction with a production-ready storage seam, injectable fake storage, bounded writes, and cache schema migration/invalidation.
- [x] 1.4 Define resource-specific freshness/expiration policies for field data, measurements/history, AWD analysis, alerts, devices/gateway, and irrigation state.

## 2. Offline-Aware Data Access

- [x] 2.1 Implement cache-aware repository decorators that prefer validated live REST/realtime data and return eligible cached snapshots when offline or requests fail.
- [x] 2.2 Persist field summary, Q1-Q4 measurements, historical visualization data, AWD results, alerts, and device/gateway status with source and stale metadata.
- [x] 2.3 Persist the last confirmed centralized irrigation state separately with live-confirmation metadata and prevent cached state from satisfying live checks.
- [x] 2.4 Expose cache hit, stale, expired, unavailable, and last-confirmed timestamps through domain-facing offline state without leaking storage types to screens.

## 3. Recovery and Synchronization

- [x] 3.1 Implement network recovery detection with debounced, deduplicated synchronization triggers.
- [x] 3.2 Synchronize/revalidate cached resources in dependency order and update each cache entry only after successful response validation.
- [x] 3.3 Preserve failed resource caches during partial recovery and expose per-resource retry/error state without clearing unrelated data.
- [x] 3.4 Coordinate REST recovery sync with realtime bootstrap/events so older responses cannot overwrite newer confirmed state.

## 4. Presentation and Irrigation Safety

- [x] 4.1 Add shared offline/degraded banners, stale labels, cache-source indicators, loading states, retry actions, and recovery feedback to relevant screens.
- [x] 4.2 Ensure cached pump/valve state is never labeled live or confirmed and is rendered as stale/unconfirmed context when displayed.
- [x] 4.3 Gate centralized irrigation commands on online network state, authenticated backend session, and current controller connectivity confirmation.
- [x] 4.4 Reject offline/uncertain irrigation commands before network submission, do not queue them implicitly, and explain the safety restriction to operators.
- [x] 4.5 Preserve Q1-Q4 as read-only monitoring data and keep all irrigation behavior centralized at `ENTIRE FIELD`.

## 5. Verification and Documentation

- [x] 5.1 Add cache envelope serialization, migration, bounded storage, and resource TTL/expiration tests.
- [x] 5.2 Add connectivity transition, offline read, stale/expired display, recovery sync, partial failure, and retry tests.
- [x] 5.3 Add irrigation safety tests proving cached pump/valve state cannot authorize commands and offline commands never reach transport.
- [x] 5.4 Add Q1-Q4 monitoring scope and centralized `ENTIRE FIELD` isolation tests.
- [x] 5.5 Document storage configuration, freshness policies, stale-state semantics, recovery behavior, and live-confirmation command gating.
- [x] 5.6 Run `flutter analyze`, focused offline-support tests, and the full `flutter test` suite.
