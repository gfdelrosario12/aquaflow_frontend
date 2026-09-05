# AquaSense Offline Boundary

Offline support is exposed through `ConnectivityNotifier`, `OfflineRepository`, `OfflineResource`, and `OfflineRecoveryCoordinator`.

Cache entries are versioned envelopes with source, confirmation, fetched/confirmed timestamps, and resource-specific freshness windows. Cached actuator state is display-only: `CacheSource.cache` and non-live confirmation levels never authorize irrigation commands.

The production storage implementation is intentionally injectable through `OfflineStorage`; `MemoryOfflineStorage` and `JsonOfflineStorage` support tests and local development. A persistent encrypted implementation can replace the seam without changing domain consumers.

Centralized irrigation commands require online backend reachability, authentication, current controller confirmation, live confirmation metadata, and `ENTIRE FIELD` scope. No commands are queued while offline. Q1-Q4 data remains read-only monitoring context.
