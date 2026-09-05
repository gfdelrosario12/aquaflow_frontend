## Context

AquaSense already has authentication with `flutter_secure_storage`, a shared `ApiClient` with timeouts and token refresh, irrigation command gating, and domain rules that keep Q1–Q4 monitoring-only. Gaps remain: HTTPS is a default URL rather than an enforced policy, diagnostics can leak sensitive headers/bodies, passwords and secrets hygiene are incomplete, authorization/security errors for irrigation are uneven, and offline caches must not become an alternate credential store. This change hardens those cross-cutting controls without redesigning features or talking directly to LoRaWAN hardware.

## Goals / Non-Goals

**Goals:**
- Enforce HTTPS-only backend base URLs for non-test/production configurations and rely on platform TLS certificate validation.
- Keep access/refresh tokens only in secure platform storage; never persist passwords; keep secrets out of source.
- Redact tokens, passwords, and Authorization headers from logs and request diagnostics.
- Clarify session expiration: refresh failure and unauthorized responses clear local session and return operators to login with a clear security message.
- Preserve and strengthen irrigation safety: authenticated + authorized + live confirmation, backend command chain only, timeouts, no automatic start/stop replay, in-flight duplicate prevention.
- Validate auth and control-sensitive inputs; validate API responses into typed failures without partial domain objects.
- Ensure security UI/errors never expose zone-level irrigation actions for Q1–Q4.

**Non-Goals:**
- Backend authorization policy authoring, OAuth provider setup, or server-side rate limiting.
- Certificate pinning (unless a future ops requirement appears); default system trust store is sufficient for this change.
- Direct LoRaWAN, BLE, or gateway hardware access from the mobile app.
- Biometric unlock, device attestation, or MDM/enterprise app wrapping.
- Changing Q1–Q4 monitoring UX beyond security guardrails.
- Automatic offline command queues for irrigation.

## Decisions

### 1. Harden existing `ApiConfig` / `ApiClient` rather than a new networking stack

- **Decision**: Extend `ApiConfig.fromEnvironment()` and `ApiClient` to validate `https:` scheme (allow `http:` only for explicit local/test overrides), keep connect/receive timeouts, and continue using the platform HTTP client TLS stack.
- **Rationale**: Transport policy already lives in one place; enforcing HTTPS there covers all feature repositories.
- **Alternative considered**: Per-feature URL checks were rejected as easy to miss and inconsistent.

### 2. Secure storage remains the only credential store

- **Decision**: Continue `SecureApiTokenStore` + `SecureStorageService` for access/refresh tokens. Explicitly forbid writing passwords, API keys, or raw Authorization headers to SharedPreferences/offline cache. Clear tokens on logout and auth failure.
- **Rationale**: Tokens already use secure storage; the hardening work is closing accidental plaintext paths and local data minimization.
- **Alternative considered**: Encrypting tokens inside SharedPreferences was rejected because OS-backed secure storage is the correct platform primitive.

### 3. Centralized sensitive-data redaction helper for diagnostics

- **Decision**: Add a small redaction utility used by any request diagnostics/logging so Authorization headers, tokens, and password fields are never printed in clear text (including debug builds where possible for sensitive keys).
- **Rationale**: Safe diagnostics are already required by api-integration; without a shared redactor, ad-hoc `print`/`debugPrint` will regress.
- **Alternative considered**: Disabling all HTTP diagnostics was rejected because connectivity debugging remains valuable when redacted.

### 4. Session expiration owned by auth + transport boundary

- **Decision**: Keep coordinated refresh in `ApiClient`. On refresh failure, 401 after refresh, or explicit logout, clear secure tokens and transition `AuthNotifier` to unauthenticated with a user-safe message (no token material in the message).
- **Rationale**: Matches existing architecture and avoids screens managing tokens.
- **Alternative considered**: Idle-timeout logout timers on-device were deferred; server token TTL + 401/refresh failure is the authoritative signal unless product later requires idle lock.

### 5. Irrigation security gates stay client-enforced and backend-authoritative

- **Decision**: Extend `IrrigationCommandGate` (and Control confirmation flow) to require authenticated session and irrigation authorization role before dispatch; always call backend `/api/irrigation/start|stop` only; never open LoRaWAN/hardware channels; never auto-retry start/stop; keep in-flight duplicate suppression; map timeout/auth/forbidden failures to clear UI errors without offering Q1–Q4 controls.
- **Rationale**: Client gates prevent accidental misuse; backend remains the real authority.
- **Alternative considered**: Client-only authorization flags without backend 403 handling were rejected as insufficient.

### 6. Secrets via compile-time / environment configuration only

- **Decision**: API base URL and any non-user secrets continue via `--dart-define` / environment injection. No hardcoded production credentials, private keys, or tokens in the repository.
- **Rationale**: Source control must not become a secret store.
- **Alternative considered**: Bundled `.env` checked into git was rejected.

### 7. Prefer ADDED security requirements over rewriting domain specs wholesale

- **Decision**: Introduce `mobile-security` for cross-cutting rules; delta-add/modify only the auth, API, irrigation, and offline requirements that must change behaviorally.
- **Rationale**: Keeps archive merges clean and avoids duplicating monitoring-zone prose that already forbids zone actuators.

## Risks / Trade-offs

- **[Risk: Local HTTP used during development breaks after HTTPS enforcement]** → **Mitigation**: Allow explicit test/dev override flag; document that production/staging builds MUST use HTTPS.
- **[Risk: Over-redaction hides useful debugging context]** → **Mitigation**: Redact known sensitive keys/headers only; retain method, path, status, and non-sensitive correlation ids.
- **[Risk: Client authz role checks diverge from backend]** → **Mitigation**: Treat client checks as UX guardrails; always honor backend 401/403 and clear or block accordingly.
- **[Risk: Operators confuse timeout with successful command]** → **Mitigation**: Typed timeout/error states; never mark irrigation as confirmed without backend/controller acknowledgment.
- **[Risk: Offline cache accidentally stores session material]** → **Mitigation**: Spec and tests asserting cache envelopes exclude tokens/passwords; tokens remain only in secure storage.

## Migration Plan

1. Add HTTPS validation, redaction helper, and secure-storage/data-minimization guards without changing UI flows.
2. Wire auth session clearing and security-safe error messages through existing `AuthNotifier` / API error kinds.
3. Strengthen irrigation gate + control confirmation error paths; keep mock repositories for tests.
4. Add unit/widget tests for HTTPS rejection, redaction, token-only secure storage, non-replay of irrigation commands, and offline cache credential exclusion.
5. Roll back by feature-flagging or reverting transport validation while leaving domain contracts intact.

## Open Questions

- Does the backend expose an explicit refresh endpoint and token TTL metadata the client should surface, or only opaque 401 + refresh-token exchange?
- Should production builds fail fast at startup on non-HTTPS base URLs, or only when the first API call is attempted?
- Will ops require certificate pinning later, or is system trust store the long-term policy?
- What exact role claim/field indicates irrigation authorization on the session/user profile?
