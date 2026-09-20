## 1. Domain Model — UserRole and Field-Scoped Session

- [x] 1.1 Define `UserRole` enum (`fieldAdmin`, `operator`, `viewer`) with `fromString` factory (returns `null` for unrecognized values) in `lib/features/auth/domain/models/user_role.dart`
- [x] 1.2 Extend `AuthToken` model in `lib/features/auth/domain/models/` to parse and expose `fieldId` (String?) and `role` (UserRole?) claims from JWT payload
- [x] 1.3 Extend `UserSession` model in `lib/features/auth/domain/models/` to surface `fieldId` and `role` from the stored token; expose a `canPerform(UserRole required)` method that returns false when role is null or below required level
- [x] 1.4 Update `MockAuthService` / mock datasource in `lib/features/auth/data/datasources/` to return a token payload with stub `fieldId` and `role` claims so development and tests work without a real backend
- [x] 1.5 Add unit tests for `UserRole.fromString` (valid values, unrecognized value returns null) and `UserSession.canPerform` (permission matrix cases)

## 2. API Failure Types — Distinguish 401 from 403

- [x] 2.1 Add `insufficientRole` variant to the API failure/error type in `lib/core/api/api_errors.dart`, distinct from the existing `unauthenticated` variant
- [x] 2.2 Update the 4xx error mapper in `lib/core/api/api_client.dart` to route HTTP 403 responses to `ApiFailure.insufficientRole` and HTTP 401 (after failed refresh) to `ApiFailure.unauthenticated`
- [x] 2.3 Update existing 403-handling paths in `lib/features/control/` (irrigation) and any other callers that currently map 403 to a generic error, to handle `insufficientRole` as a distinct case
- [x] 2.4 Add unit tests for error mapper: HTTP 403 → `insufficientRole`, HTTP 401 after refresh failure → `unauthenticated`, that the two variants are not conflated

## 3. Auth State — Field-Scoped Claims in AuthNotifier

- [x] 3.1 Update `AuthNotifier` / auth controller in `lib/features/auth/presentation/controllers/` to resolve `fieldId` and `role` from the token after successful login and store them in the auth state
- [x] 3.2 Update the session restoration path (app launch with existing tokens) to parse and validate `fieldId` and `role` claims; treat missing or unrecognized role as unauthorized (clear session, prompt re-login)
- [x] 3.3 Update the 403 response handler path: `insufficientRole` failures preserve the session and surface a role-insufficient warning; `unauthenticated` failures clear the session and redirect to login (no mixing of the two paths)
- [ ] 3.4 Add widget/integration tests: login with stub role token populates auth state correctly; session restore with missing role claim clears session; 403 does not log user out

## 4. AuthorizationGate — UI Role-Check Helper

- [x] 4.1 Create `AuthorizationGate` widget in `lib/core/widgets/` that accepts a `requiredRole` and a `child` widget, hiding or disabling child when the current session's role is insufficient
- [x] 4.2 Export `AuthorizationGate` through `lib/core/widgets/widgets.dart`
- [x] 4.3 Wrap irrigation control action buttons (Start/Stop Field Irrigation) in `lib/features/control/presentation/control_screen.dart` and control widgets with `AuthorizationGate(requiredRole: UserRole.operator)` to hide them for `viewer` sessions
- [x] 4.4 Wrap node lifecycle mutation controls (register, provision, lifecycle transitions, replace, decommission) in `lib/features/nodes/presentation/` widgets with `AuthorizationGate(requiredRole: UserRole.operator)`
- [x] 4.5 Wrap node transmission interval configuration controls in `lib/features/nodes/presentation/` with `AuthorizationGate(requiredRole: UserRole.operator)`
- [x] 4.6 Wrap fault lockout clearance action in `lib/features/control/presentation/control_screen.dart` with `AuthorizationGate(requiredRole: UserRole.operator)`
- [ ] 4.7 Add widget tests for `AuthorizationGate`: child rendered for sufficient role, child hidden/disabled for insufficient role, child rendered for `field_admin` in all operator-gated spots

## 5. Role-Insufficient Warning Presentation

- [ ] 5.1 Add a role-insufficient snackbar/dialog helper in `lib/core/widgets/` (or reuse existing error presentation) that displays a user-safe message without revealing role claim values or token contents
- [ ] 5.2 Wire the `insufficientRole` failure kind through the control feature's error handler in `lib/features/control/presentation/` to show the role-insufficient warning
- [ ] 5.3 Wire the `insufficientRole` failure kind through the node management feature's error handler in `lib/features/nodes/presentation/` to show the role-insufficient warning
- [ ] 5.4 Verify the role-insufficient warning does not expose token contents, role strings, or JWT claim names in the displayed message

## 6. Account Lifecycle — AuthRepository Extension

- [ ] 6.1 Add `Future<Result> acceptInvitation(String invitationToken, String email, String password)` to the `AuthRepository` interface in `lib/features/auth/domain/`
- [ ] 6.2 Add `Future<Result> createInvitation(String email, UserRole role)` to the `AuthRepository` interface (field_admin operation)
- [ ] 6.3 Implement both methods in the mock `AuthRepositoryImpl` in `lib/features/auth/data/repositories/`: `acceptInvitation` accepts any non-empty token; `createInvitation` is a no-op in mock mode
- [ ] 6.4 Implement both methods in the REST `AuthRepositoryImpl` targeting `/api/auth/register` (accept invitation) and `/api/auth/invite` (create invitation) — align endpoint names with backend once confirmed
- [ ] 6.5 Add an invitation acceptance screen in `lib/features/auth/presentation/` reachable from the login screen for users following an invitation link
- [ ] 6.6 Add unit tests for mock invitation acceptance (valid token succeeds, empty token fails) and that `createInvitation` is only callable from a `field_admin` session

## 7. AuthorizationEventLogger

- [ ] 7.1 Define `AuthorizationEventLogger` interface in `lib/features/auth/domain/` with methods: `logLogin`, `logLogout`, `logAuthorizationDenied`, `logAccountLifecycle` — all fire-and-forget (return void, swallow errors with debug warning)
- [ ] 7.2 Implement no-op `MockAuthorizationEventLogger` in `lib/features/auth/data/`
- [ ] 7.3 Implement `RestAuthorizationEventLogger` that POSTs to `/api/auth/events`; failures are caught and logged as debug warnings, never propagated to callers
- [ ] 7.4 Wire `logLogin` call into `AuthNotifier` on successful login
- [ ] 7.5 Wire `logLogout` call into `AuthNotifier` on successful logout
- [ ] 7.6 Wire `logAuthorizationDenied` call in `ApiClient` or auth error handler when an `insufficientRole` failure is resolved
- [ ] 7.7 Add unit test confirming `RestAuthorizationEventLogger` failure does not propagate to the caller

## 8. API Token Forwarding — Field-Scoped Claims

- [ ] 8.1 Verify `lib/core/api/api_client.dart` attaches the full access token (containing field-scoped claims) in `Authorization: Bearer` headers on authorized requests — no stripping or modification of claims before transmission
- [ ] 8.2 Confirm token refresh in `api_client.dart` stores and applies the new token's `fieldId` and `role` claims after a successful refresh, updating `AuthNotifier` state accordingly
- [ ] 8.3 Add a test confirming the Authorization header value in outgoing requests matches the stored token without modification

## 9. Validation and Final Wiring

- [ ] 9.1 Run `flutter analyze` and resolve any static analysis errors introduced by the new `UserRole` enum, extended models, and `AuthorizationGate` widget
- [ ] 9.2 Run the full test suite (`flutter test`) and fix any test failures caused by the updated `AuthToken`, `UserSession`, or `ApiFailure` types
- [ ] 9.3 Perform a manual smoke test: log in with a stub `viewer` token and verify irrigation command controls and node lifecycle controls are hidden; log in with `operator` token and verify they are visible and functional; verify a simulated 403 response shows the role-insufficient warning without logging the user out
