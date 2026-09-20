## Why

The current AquaSense backend treats authentication as identity-only — the app logs a user in and receives tokens, but nothing binds that identity to a specific agricultural field or restricts what that user may do once authenticated. As the platform approaches operator-facing features (node lifecycle management, irrigation control, automatic irrigation configuration), the absence of field membership and authorization roles means every authenticated user implicitly has access to everything. Hardening this now, before multi-field or multi-operator deployments, establishes a principled authorization boundary while the data model is still simple to extend.

## What Changes

- **NEW**: `FieldMembership` domain model — links an authenticated user account to one or more fields with an assigned role.
- **NEW**: `AuthorizationRole` enumeration derived from operational need: `field_admin`, `operator`, `viewer`. Roles govern what actions are permitted within a field scope, not globally.
- **NEW**: Field-scoped JWT claims — backend issues tokens that carry `fieldId` and `role` in their payload; the Flutter client forwards these and the backend enforces them.
- **NEW**: Permission matrix — maps roles to concrete permissions: sensor node lifecycle mutations, irrigation command dispatch, automatic irrigation configuration, field topology changes, and read-only monitoring.
- **NEW**: Backend authorization middleware — enforces role/permission requirements server-side for every sensitive endpoint; client-side restrictions are UI hints only.
- **NEW**: Account lifecycle operations — user registration (invite-only, admin-initiated), password change, account suspension/reactivation scoped to field access.
- **NEW**: Authentication event logging — records login, logout, token refresh, authorization failure, and account lifecycle changes with actor, timestamp, field context, and outcome.
- **MODIFIED**: `user-authentication` spec — add field-membership resolution at login, token claim content, and field-scoped session semantics.
- **MODIFIED**: `mobile-security` spec — add field-scoped authorization enforcement rule (no client-side-only restrictions on privileged operations).
- **MODIFIED**: `api-integration` spec — field-scoped token forwarding, 403 mapping for role-insufficient responses (distinct from 401 unauthenticated), and authorization header contract.
- **MODIFIED**: `centralized-irrigation` spec — authorization requirement for irrigation commands aligned with `operator` or `field_admin` role rather than an implicit "authorized session" assumption.
- **MODIFIED**: `node-management` spec — role enforcement aligned with defined role names (`field_admin`, `operator`, `viewer`) replacing generic role string references.

## Capabilities

### New Capabilities

- `field-scoped-authorization`: Defines field membership, the `field_admin`/`operator`/`viewer` role enumeration, the permission matrix, backend enforcement rules, account lifecycle, and authentication event logging.

### Modified Capabilities

- `user-authentication`: Session now resolves field membership and role at login; tokens carry field-scoped claims; account lifecycle covers invite-only registration and suspension.
- `mobile-security`: Adds the invariant that security-sensitive operations are enforced by the backend, not by Flutter client-side restrictions alone.
- `api-integration`: Token payload contract (field claims), 403-role-insufficient mapping distinct from 401-unauthenticated, and authorization failure forwarding to session manager.
- `centralized-irrigation`: Irrigation command authorization aligned with explicit `operator`/`field_admin` permission rather than vague "authorized session."
- `node-management`: Role names in lifecycle authorization aligned with the canonical `field_admin`/`operator`/`viewer` vocabulary.

## Impact

- **Backend**: New middleware on all sensitive API endpoints; JWT issuer must embed `fieldId` and `role` claims; field membership table/model required.
- **Flutter client**: `AuthRepository` and `UserSession` model extended with field membership and role; authorization checks in UI gated through session role rather than ad-hoc booleans; 403-role-insufficient responses handled distinctly from 401-unauthenticated.
- **Existing specs**: `user-authentication`, `mobile-security`, `api-integration`, `centralized-irrigation`, and `node-management` all have requirement-level behavior changes.
- **No breaking changes to the existing login/logout flow** — the endpoint contract and token storage mechanism are preserved; the token payload is extended with new claims.
- **No new Flutter dependencies** anticipated — role resolution is data-model work on top of existing secure token storage.
