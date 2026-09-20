## Purpose

Defines field membership, the canonical role enumeration (`field_admin`, `operator`, `viewer`), the permission matrix governing all privileged operations, backend-enforced authorization rules, account lifecycle, and authentication event logging for AquaSense's field-scoped access control model.

## ADDED Requirements

### Requirement: Field membership model
The system SHALL associate every authenticated user account with one or more agricultural fields through a `FieldMembership` record that binds the user identity, the field identifier, and an assigned role. A user without a membership record for a given field MUST be treated as unauthorized for all operations on that field.

#### Scenario: User is a member of a field
- **WHEN** a user authenticates and the backend resolves their membership for the field
- **THEN** the issued access token carries `fieldId` and `role` claims corresponding to that membership.

#### Scenario: User has no membership for a field
- **WHEN** a user authenticates but has no membership record for the requested or only available field
- **THEN** the backend refuses to issue a field-scoped token and returns an authorization failure, preventing any field data access.

### Requirement: Canonical authorization role enumeration
The system SHALL define exactly three authorization roles for field-scoped access: `field_admin`, `operator`, and `viewer`. These roles are mutually exclusive per field membership and MUST NOT be extended or aliased client-side.

#### Scenario: Role enumeration is exhaustive
- **WHEN** the backend issues a field-scoped token
- **THEN** the `role` claim is exactly one of `field_admin`, `operator`, or `viewer`; any other value is rejected as invalid.

#### Scenario: Client receives an unrecognized role
- **WHEN** the Flutter client parses a token containing an unrecognized role string
- **THEN** the session is treated as unauthorized and the user is prompted to re-authenticate.

### Requirement: Permission matrix governing privileged operations
The system SHALL enforce the following permission matrix server-side. The Flutter client MAY reflect the same matrix in its UI, but client-side gating MUST NOT substitute for backend enforcement.

| Operation category | `viewer` | `operator` | `field_admin` |
|---|---|---|---|
| Read-only monitoring (telemetry, alerts, analytics) | ✓ | ✓ | ✓ |
| Irrigation command dispatch (start/stop field) | ✗ | ✓ | ✓ |
| Automatic irrigation configuration | ✗ | ✓ | ✓ |
| Node transmission interval configuration | ✗ | ✓ | ✓ |
| Node lifecycle mutations (register, provision, assign, rename, replace, decommission) | ✗ | ✓ | ✓ |
| Fault lockout clearance | ✗ | ✓ | ✓ |
| Field topology and zone configuration | ✗ | ✗ | ✓ |
| User account and membership management | ✗ | ✗ | ✓ |

#### Scenario: Viewer attempts a privileged operation
- **WHEN** an authenticated `viewer` submits a request for an operation in a category they are not permitted
- **THEN** the backend returns HTTP 403 with a role-insufficient error body and the operation is not executed.

#### Scenario: Operator attempts a field_admin-only operation
- **WHEN** an authenticated `operator` submits a request to manage user memberships or field topology
- **THEN** the backend returns HTTP 403 and the operation is not executed.

#### Scenario: field_admin performs full-permission operation
- **WHEN** an authenticated `field_admin` submits any operation in the permission matrix
- **THEN** the backend authorizes the request and executes the operation.

### Requirement: Backend authorization enforcement for all sensitive endpoints
The system SHALL enforce authorization on the backend for every API endpoint that performs a privileged operation. Authorization MUST be checked using the field-scoped claims in the authenticated token before processing the request. No sensitive operation MAY be protected solely by Flutter client-side logic.

#### Scenario: Valid token with sufficient role
- **WHEN** a request arrives with a valid JWT whose `role` claim meets the required permission for the endpoint
- **THEN** the backend processes the request normally.

#### Scenario: Valid token with insufficient role
- **WHEN** a request arrives with a valid JWT whose `role` claim is lower than required for the endpoint
- **THEN** the backend returns HTTP 403 without executing the operation, regardless of any client-side role checks already performed.

#### Scenario: Request with missing or invalid field claim
- **WHEN** a request arrives with a JWT that lacks a `fieldId` claim or carries a field ID that does not match the requested resource's field
- **THEN** the backend returns HTTP 403 and treats the mismatch as an authorization failure.

### Requirement: Field-scoped JWT claim contract
The system SHALL embed `fieldId` (string) and `role` (one of the canonical role values) as named claims in access tokens issued after successful field membership resolution at login. These claims SHALL be validated by the backend on every authorized request.

#### Scenario: Login resolves field membership to a single field
- **WHEN** a user authenticates and has exactly one field membership
- **THEN** the issued access token contains `fieldId` matching that field and `role` matching the user's role for that field.

#### Scenario: Token claims are validated on every request
- **WHEN** the backend receives an authorized request
- **THEN** it verifies both `fieldId` and `role` claims against the requested resource's field before allowing access.

### Requirement: Account lifecycle — invite-only registration
The system SHALL restrict new user account creation to an invite-only flow initiated by a `field_admin`. Self-registration without an admin-issued invitation token MUST be rejected.

#### Scenario: field_admin invites a new user
- **WHEN** a `field_admin` creates an invitation specifying a target email and intended role
- **THEN** the backend generates a time-limited invitation token, records the intended field membership, and delivers the invitation to the specified address.

#### Scenario: Invitation token accepted by new user
- **WHEN** a new user follows an invitation link and sets their credentials
- **THEN** the backend creates the account, establishes the field membership with the invited role, and invalidates the invitation token.

#### Scenario: Self-registration attempted without invitation
- **WHEN** a registration request arrives without a valid invitation token
- **THEN** the backend rejects it with an authorization error and no account is created.

### Requirement: Account lifecycle — suspension and reactivation
The system SHALL allow a `field_admin` to suspend a user's field membership, immediately invalidating any active sessions for that field, and to reactivate a suspended membership.

#### Scenario: field_admin suspends a user
- **WHEN** a `field_admin` suspends a user's field membership
- **THEN** the backend invalidates all active sessions for that user on that field and returns HTTP 403 on any subsequent request using the affected tokens.

#### Scenario: Suspended user attempts to use an existing session
- **WHEN** a user with a suspended field membership submits a request using a previously valid token
- **THEN** the backend returns HTTP 403 and the Flutter client clears the session and redirects to the login screen.

#### Scenario: field_admin reactivates a suspended user
- **WHEN** a `field_admin` reactivates a suspended membership
- **THEN** the user may authenticate and obtain a new field-scoped token with their original role restored.

### Requirement: Authentication event logging
The system SHALL record an immutable event log entry for each of the following: successful login (with field and role resolved), failed login attempt, logout, token refresh, authorization failure (403), account suspension, account reactivation, and invitation creation/acceptance. Each entry MUST capture actor identity, timestamp, field context, event type, and outcome.

#### Scenario: Successful login is logged
- **WHEN** a user authenticates successfully
- **THEN** an event log entry is created with actor identity, resolved `fieldId`, resolved `role`, login timestamp, and outcome `success`.

#### Scenario: Authorization failure is logged
- **WHEN** a request is rejected with HTTP 403 due to insufficient role or field mismatch
- **THEN** an event log entry is created with the actor identity, `fieldId` from the token, the requested endpoint, the required role, the actual role, and outcome `denied`.

#### Scenario: Account suspension event is logged
- **WHEN** a `field_admin` suspends a user's field membership
- **THEN** an event log entry is created with the admin's actor identity, the target user identity, `fieldId`, timestamp, and outcome `suspended`.
