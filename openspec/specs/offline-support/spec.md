## Purpose

Provides network-aware local persistence, cache freshness semantics, stale-state presentation, recovery synchronization, and safe offline behavior for AquaSense data and centralized irrigation actions.

## Requirements

### Requirement: Network and degraded connectivity state
The system SHALL detect network availability and expose online, offline, degraded, synchronizing, and recovery states to repositories and relevant screens.

#### Scenario: Network becomes unavailable
- **WHEN** connectivity detection reports that the backend cannot be reached
- **THEN** the application enters offline or degraded state, presents an offline indicator, and uses eligible cached data without treating it as live.

### Requirement: Persisted cache coverage
The system SHALL persist the most recent field information, Q1-Q4 monitoring measurements, historical data required for basic visualization, AWD analysis results, alerts, device/gateway status, and the last confirmed centralized irrigation state using versioned cache envelopes.

#### Scenario: Operator opens the app offline
- **WHEN** no backend connection is available and a valid cache exists
- **THEN** the relevant screens load the newest eligible cached snapshots with source and freshness metadata.

### Requirement: Cache freshness and stale-state semantics
The system SHALL apply resource-specific expiration/staleness rules and SHALL clearly identify cached or stale information. Expired data SHALL not be presented as current backend-confirmed state.

#### Scenario: Cached monitoring data exceeds its freshness window
- **WHEN** a Q1-Q4 measurement or device snapshot is older than its configured freshness threshold
- **THEN** the application labels it stale, preserves it only as contextual information when allowed, and exposes retry/recovery feedback.

#### Scenario: Cached irrigation state is displayed
- **WHEN** the last confirmed pump or valve state is loaded from cache
- **THEN** the UI identifies it as cached/stale/unconfirmed and never labels it as live confirmed controller state.

### Requirement: Recovery synchronization
The system SHALL synchronize or revalidate eligible cached resources when connectivity returns, update cache entries only after successful validation, and preserve failed resource caches with visible recovery errors.

#### Scenario: Connectivity returns after offline use
- **WHEN** network and backend connectivity are restored
- **THEN** the application performs a deduplicated recovery sync, refreshes eligible resources, updates successful cache entries, and clears degraded indicators only after validation succeeds.

#### Scenario: Recovery sync partially fails
- **WHEN** one resource refresh fails while other resources succeed
- **THEN** successful resources become current, the failed resource retains its prior cache with an error/stale marker, and the UI offers retry without clearing unrelated data.

### Requirement: Loading, offline, and recovery presentation
The system SHALL provide loading states, offline/degraded banners, stale labels, retry actions, and recovery feedback consistently for screens using cached or backend data.

#### Scenario: Cache and backend are unavailable
- **WHEN** no eligible cache exists and the backend cannot be reached
- **THEN** the screen presents an explicit unavailable/error state and does not render fabricated field, device, or irrigation values.

### Requirement: Safe centralized irrigation command gating
The system MUST block centralized irrigation commands when the application cannot currently confirm backend and controller connectivity. Cached pump or valve state SHALL NOT authorize or simulate a command, and no implicit offline command queue SHALL be created.

#### Scenario: Operator attempts irrigation while offline
- **WHEN** the app has no confirmed backend/controller connectivity
- **THEN** the irrigation command is rejected before network submission, the UI explains that live confirmation is required, and no pump or valve action is represented as accepted.

#### Scenario: Operator attempts irrigation with live confirmation
- **WHEN** the app is online with an authenticated backend session and current controller connectivity confirmation
- **THEN** a permitted command may target only `ENTIRE FIELD` and its result is shown from backend/controller confirmation.

### Requirement: Monitoring and irrigation scope isolation
The offline cache and recovery architecture SHALL allow Q1-Q4 monitoring data to be stored and queried independently while preserving irrigation as one centralized `ENTIRE FIELD` system. It MUST NOT create zone-specific irrigation settings or controls.

#### Scenario: Q1-Q4 cached measurements are viewed
- **WHEN** an operator views cached monitoring data for Q1, Q2, Q3, or Q4
- **THEN** the data remains read-only monitoring context and exposes no pump, valve, or zone irrigation action.

### Requirement: Offline cache excludes credentials
The system MUST NOT store access tokens, refresh tokens, passwords, or Authorization headers in offline cache envelopes or plaintext preferences. Session tokens SHALL remain exclusively in secure platform storage managed by the authentication boundary.

#### Scenario: Cache write excludes secrets
- **WHEN** the application persists field, monitoring, alert, device, or irrigation status snapshots for offline use
- **THEN** the cache payload contains domain telemetry/state only and does not include authentication tokens or passwords.

### Requirement: Offline paths cannot bypass irrigation authorization
The offline and degraded-connectivity paths SHALL continue to require an authenticated session and live backend/controller confirmation before allowing centralized irrigation commands, and MUST NOT use cached credentials or stale auth state to authorize pump or valve actions.

#### Scenario: Stale auth cannot authorize irrigation offline
- **WHEN** the operator is offline or the session is unauthenticated
- **THEN** irrigation start/stop remains blocked and no offline command queue is created.
