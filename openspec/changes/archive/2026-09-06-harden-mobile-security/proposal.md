## Why

AquaSense already authenticates operators and routes irrigation through the backend, but security posture is still uneven: HTTPS and TLS expectations are implicit, logs and diagnostics can leak tokens or credentials, session and local-storage boundaries need hardening, and sensitive irrigation actions need clearer failure, timeout, and duplicate-prevention behavior. Hardening now closes those gaps before production field deployment without changing the Q1–Q4 monitoring-only and centralized irrigation model.

## What Changes

- Enforce HTTPS (and appropriate TLS/certificate handling) for all backend REST communication; reject insecure transport in production configurations.
- Keep authentication tokens exclusively in secure platform storage; never persist passwords or other unnecessary secrets locally; keep credentials and secrets out of source code.
- Redact tokens, passwords, and other sensitive fields from logs, crash diagnostics, and safe request diagnostics.
- Strengthen authentication/session expiration behavior (refresh failure, idle/expired session clearing, clear security-related UI errors).
- Harden API response validation and typed security/auth failure mapping with explicit request timeouts.
- Enforce authenticated and authorized centralized irrigation commands only via the backend command chain (Mobile → API → gateway → controller); never talk directly to LoRaWAN/hardware.
- Improve irrigation command safety: timeout handling, no automatic replay of non-idempotent start/stop, duplicate/in-flight prevention, and clear security-related error messaging.
- Apply input validation on auth and control-sensitive inputs.
- Preserve Q1–Q4 as monitoring-only; security controls and error paths MUST NOT invent or expose zone-level irrigation operations.

## Capabilities

### New Capabilities
- `mobile-security`: Cross-cutting mobile security posture covering HTTPS/TLS transport rules, secrets hygiene, sensitive-data redaction, local data minimization, security error presentation, and input validation for auth and control flows.

### Modified Capabilities
- `user-authentication`: Strengthen secure-storage-only token persistence, forbid password retention, and clarify session expiration / security-error redirect behavior.
- `api-integration`: Require HTTPS-only backend transport, safe diagnostics, certificate/TLS handling expectations, and stronger security-oriented error/timeout behavior for authorized requests.
- `centralized-irrigation`: Tighten auth/authz gating, command-chain-only dispatch, failure/timeout/duplicate prevention, and security-clear error handling without zone-level control surfaces.
- `offline-support`: Ensure offline/local caches never store credentials or tokens outside secure storage and that offline paths cannot bypass irrigation authorization.

## Impact

- **Core services**: `SecureStorageService`, `ApiTokenStore`, `ApiClient`/`ApiConfig`, logging/diagnostics helpers, and possibly auth/irrigation gating utilities under `lib/core/`.
- **Auth feature**: login/session controllers and repositories under `lib/features/auth/` for expiration, secure storage, and validation hardening.
- **Control feature**: confirmation/command pipeline under `lib/features/control/` for authz, timeouts, and non-replayable command safety.
- **Dependencies**: continue using `flutter_secure_storage` and environment-configured API base URLs; no secrets in repo source.
- **Domain invariants**: Q1–Q4 remain monitoring-only; irrigation remains `ENTIRE FIELD` via backend only.
