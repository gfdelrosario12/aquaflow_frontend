## 1. Transport and configuration hardening

- [x] 1.1 Extend `ApiConfig` to validate HTTPS base URLs, support an explicit local/test HTTP override, and fail closed for insecure non-test configurations.
- [x] 1.2 Update `ApiClient` to refuse requests when transport configuration is insecure and map TLS/connectivity failures to typed transport-security or connectivity errors.
- [x] 1.3 Confirm production builds use platform TLS verification only (no trust-all / certificate-bypass paths) and document environment `--dart-define` usage for base URL without embedding secrets.

## 2. Secure storage, session, and auth hardening

- [x] 2.1 Audit `SecureApiTokenStore` / `SecureStorageService` usage to ensure only access/refresh tokens are persisted and passwords are never written to secure storage, preferences, or caches.
- [x] 2.2 Strengthen `AuthNotifier` / auth repository session restore, logout, and refresh-failure paths to clear tokens and transition to unauthenticated with user-safe security messages.
- [x] 2.3 Enforce login input validation (empty/whitespace identifier or password) before calling auth services; ensure password controllers/memory are cleared after login attempts where practical.

## 3. Diagnostics redaction and API error mapping

- [x] 3.1 Add a shared sensitive-data redaction helper for Authorization headers, tokens, and password fields.
- [x] 3.2 Wire redaction into any API request diagnostics/logging paths so secrets are never emitted in clear text.
- [x] 3.3 Distinguish authorization (403) failures from generic errors in `ApiClient` / `ApiErrorKind` and ensure irrigation/auth callers can present unauthorized warnings without retrying non-idempotent commands.

## 4. Irrigation command security

- [x] 4.1 Extend `IrrigationCommandGate` (and Control confirmation flow) to require authenticated session and irrigation authorization before dispatch, keeping target locked to `ENTIRE FIELD`.
- [x] 4.2 Ensure start/stop commands use backend irrigation endpoints only, never direct LoRaWAN/hardware access, with timeouts and no automatic replay on failure.
- [x] 4.3 Preserve in-flight duplicate/conflict suppression and map timeout, auth, forbidden, and controller failures to clear Control UI fault/unauthorized states without Q1–Q4 remediation actions.

## 5. Offline cache credential isolation

- [x] 5.1 Audit offline cache write paths to exclude tokens, passwords, and Authorization headers from persisted envelopes.
- [x] 5.2 Verify offline/degraded irrigation gating still requires live authenticated backend/controller confirmation and creates no offline command queue.

## 6. Verification

- [x] 6.1 Add unit tests for HTTPS rejection, redaction helper, token-only secure storage, and 403/timeout mapping for irrigation commands.
- [x] 6.2 Add widget/controller tests for login validation, session clear on auth failure, unauthorized irrigation blocking, and absence of zone-level irrigation actions in security error paths.
- [x] 6.3 Run relevant Flutter tests and fix regressions introduced by the hardening work.
