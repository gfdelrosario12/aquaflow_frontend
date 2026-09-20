## Context

AquaSense already has token-based authentication: `AuthNotifier` / `AuthRepositoryImpl`, `SecureApiTokenStore`, and a shared `ApiClient` with coordinated token refresh. The `mobile-security` hardening change enforced HTTPS, redaction, and data minimization. What doesn't exist is any concept of who the user is authorized to act on — tokens today carry identity but no field membership or role claims. Features like node lifecycle management and irrigation control already reference role names (`admin`, `operator`, `viewer`) as strings in a few specs but have no canonical definition, no token-level enforcement path, and no `UserSession` model that exposes role.

See proposal.md for the motivation. See specs for the behavioral contracts.

## Goals / Non-Goals

**Goals:**
- Extend the JWT contract so the backend embeds `fieldId` and `role` claims; extend `UserSession` and `AuthToken` to parse and expose them.
- Add a `UserRole` domain enum (`fieldAdmin`, `operator`, `viewer`) as the canonical Flutter-side vocabulary.
- Extend `AuthNotifier` / auth state so resolved role and field are first-class values available to UI and repositories.
- Distinguish `insufficientRole` (403) from `unauthenticated` (401) as separate typed API failure kinds; route each through the right response handler.
- Add invite-only account registration and membership suspension/reactivation surface in the `AuthRepository` interface.
- Add `AuthorizationEventLogger` interface for authentication and authorization audit events (login, logout, 403 denial, account lifecycle).
- Update node management, irrigation, and API client wiring to use the canonical `UserRole` enum instead of ad-hoc role strings.

**Non-Goals:**
- Backend implementation (JWT issuer, field membership table, invitation email delivery, audit log persistence) — this change defines Flutter-client contracts and UI behaviors; backend alignment is expected but its internal design is out of scope here.
- Multi-field switching at the session level — the current deployment is single-field; `UserSession` carries one `(fieldId, role)` pair. Extensibility is preserved through the domain model but multi-field selection UI is deferred.
- Certificate pinning, biometrics, or MDM configuration.
- Offline command queues for privileged operations.
- Changing the secure storage mechanism or the `ApiClient` transport stack — those are addressed in `harden-mobile-security`.

## Decisions

### 1. Extend `UserSession` / `AuthToken` with field-scoped claims rather than a separate model

- **Decision**: Add `fieldId: String` and `role: UserRole` to `AuthToken` (parsed from JWT payload) and surface them as non-nullable fields on `UserSession`. `AuthNotifier` exposes `currentRole` and `currentFieldId` directly.
- **Rationale**: The session model is already the single source of truth for the Flutter app's auth state. Centralizing claims there avoids scattered JWT parsing across features.
- **Alternative considered**: A separate `FieldMembership` DTO fetched post-login via a `/me` endpoint — rejected because it adds a second network round-trip and a brief window where the session is authenticated but role-unknown, creating a race condition for UI gating.

### 2. `UserRole` enum with a safe fallback parse, not raw strings

- **Decision**: Define `enum UserRole { fieldAdmin, operator, viewer }` in `lib/core/auth/` with a `fromString` factory that returns `null` (treated as unauthorized) for unrecognized values.
- **Rationale**: Stringly-typed role comparisons across features are fragile. An enum enforces exhaustiveness in switch statements and centralizes mapping to human-readable labels. Returning `null` on unknown value means the session is treated as unauthorized rather than silently granting the wrong access level.
- **Alternative considered**: A constant class with string values was rejected because it provides no exhaustiveness guarantees and is harder to refactor.

### 3. Two distinct typed API failure kinds for 401 vs 403

- **Decision**: Add `ApiFailure.insufficientRole` alongside the existing `ApiFailure.unauthenticated`. The `ApiClient` error mapper routes HTTP 403 to `insufficientRole` and HTTP 401 (when refresh also fails) to `unauthenticated`. Callers handle them differently: `unauthenticated` clears the session; `insufficientRole` shows a warning and keeps the session alive.
- **Rationale**: The current code treats 403 as a generic unexpected error in most paths. Conflating it with 401 would either log the user out on every permission denial (bad UX) or fail to log them out on token expiry (security bug).
- **Alternative considered**: Treating 403 as a generic error and handling it only in the irrigation feature was rejected because the same distinction is needed in node management, auto-irrigation config, and any future privileged endpoint.

### 4. `AuthorizationGate` helper for UI-level role checks

- **Decision**: Add a thin `AuthorizationGate` widget and a `canPerform(UserRole required)` extension on `UserSession` so features can conditionally render controls without duplicating role comparisons. Gate checks are presentational only — they always have a backend counterpart.
- **Rationale**: Scattering inline `session.role == UserRole.operator` comparisons across features creates divergence risk. A central helper can be updated once if the permission matrix evolves.
- **Alternative considered**: Embedding the permission matrix in each feature's notifier was rejected as it duplicates logic and makes future matrix changes a multi-file edit.

### 5. Invite-only registration via a thin `AuthRepository` extension

- **Decision**: Add `Future<Result> acceptInvitation(String token, String email, String password)` and `Future<Result> createInvitation(String email, UserRole role)` to `AuthRepository`. The mock implementation accepts any non-empty token; the REST implementation calls `/api/auth/invite` and `/api/auth/register`.
- **Rationale**: The existing `AuthRepository` abstraction is the correct seam. Adding new methods here keeps session management centralized and avoids a separate `AccountRepository` for a small set of lifecycle operations.
- **Alternative considered**: A separate `AccountManagementRepository` was considered but rejected as premature decomposition for the current scope.

### 6. `AuthorizationEventLogger` as a fire-and-forget interface

- **Decision**: Define an `AuthorizationEventLogger` interface in `lib/core/auth/` with methods `logLogin`, `logLogout`, `logAuthorizationDenied`, `logAccountLifecycle`. Implementations POST to `/api/auth/events` (REST) or no-op (mock). Logging is non-blocking; failures are swallowed with a debug warning, never propagated to the caller.
- **Rationale**: Auth event logging is an audit concern, not a user-flow concern. Blocking the login success path on a log write would degrade the user experience and create a new failure mode.
- **Alternative considered**: Inline audit calls in `ApiClient` were rejected because they mix transport and audit concerns.

### 7. No multi-field session UI in this change

- **Decision**: `UserSession` stores a single `(fieldId, role)` pair. If the backend returns multiple memberships, the Flutter client uses the first resolved membership. Multi-field switching is not exposed in the UI.
- **Rationale**: The current deployment is single-field. Building multi-field switching before the data model is exercised in production adds complexity and UX decisions that aren't validated yet.
- **Alternative considered**: A field-picker screen post-login was prototyped conceptually but deferred.

## Risks / Trade-offs

- **[Risk: Backend doesn't yet embed `fieldId`/`role` claims in tokens]** → **Mitigation**: `AuthToken.fromJwt` treats missing claims as `null`, and `UserSession` with null role falls back to `viewer`-level UI gating with a dev warning. This keeps the app functional during backend rollout while not silently granting elevated access.
- **[Risk: Permission matrix in `canPerform` helper diverges from backend]** → **Mitigation**: The backend is always authoritative; client matrix changes are only UX refinements. 403 responses from the backend are surfaced as `insufficientRole` regardless of what the client matrix says.
- **[Risk: Invite token interception / replay]** → **Mitigation**: Token TTL and single-use enforcement are backend concerns; the Flutter client validates non-empty token and passes it server-side. Spec notes that expired/reused tokens return an auth failure.
- **[Risk: `AuthorizationEventLogger` POST failure creates gaps in the audit trail]** → **Mitigation**: Acknowledged trade-off — mobile clients are not a reliable audit log source. The backend should independently log all authorization decisions from the JWT validation middleware; the Flutter-side log is supplemental.
- **[Risk: Role enum exhaustiveness breaks on new backend roles]** → **Mitigation**: `UserRole.fromString` returns `null` for unknown values, which is treated as unauthorized. This is the safe failure mode.

## Migration Plan

1. Define `UserRole` enum and extend `AuthToken` / `UserSession` with field-scoped claim parsing. Update `MockAuthService` to return a token with `fieldId` and `role` claims so tests and development work immediately.
2. Add `ApiFailure.insufficientRole` and update `ApiClient` 4xx error mapper to route 403 to the new kind. Update existing 403-handling paths in irrigation and any other features that currently route 403 to a generic error.
3. Add `AuthorizationGate` widget and `canPerform` extension. Migrate node management and irrigation control surfaces to use them instead of ad-hoc role strings.
4. Add `acceptInvitation` and `createInvitation` to `AuthRepository`; add mock and REST implementations.
5. Add `AuthorizationEventLogger` interface, no-op mock, and REST implementation. Wire into `AuthNotifier` login/logout paths.
6. Add widget/unit tests: role resolution from token, 403 routing to `insufficientRole`, session preservation on 403, session clearance on 401, `canPerform` matrix, invite acceptance.
7. Coordinate with backend team to confirm JWT claim names (`fieldId`, `role`) and invitation/suspension endpoint contracts before wiring REST implementations.

## Open Questions

- What are the exact JWT claim key names the backend will use (`fieldId` / `role`, or `field_id` / `user_role`, etc.)? Flutter parsing is parameterized; alignment needed before REST implementation.
- Does the backend support membership suspension via a PATCH to the membership resource, or a dedicated `/api/auth/suspend` endpoint?
- Should `createInvitation` be accessible from a dedicated admin screen in this change, or only through settings (deferred to a follow-up)?
