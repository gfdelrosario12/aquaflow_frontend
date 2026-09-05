## ADDED Requirements

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
