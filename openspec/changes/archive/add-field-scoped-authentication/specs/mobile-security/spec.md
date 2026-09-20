## ADDED Requirements

### Requirement: Backend enforcement invariant for security-sensitive operations
The system SHALL enforce authorization for all security-sensitive operations exclusively through backend validation of field-scoped JWT claims. Flutter client-side role checks (hiding or disabling UI controls based on the session role) are permitted as a UX aid but MUST NOT substitute for server-side enforcement. Any operation that is restricted by role in the permission matrix MUST be validated by the backend before execution proceeds.

#### Scenario: Client hides a control and backend enforces the restriction
- **WHEN** a `viewer` user is authenticated and the Flutter client hides irrigation controls based on the resolved role
- **THEN** an attempt to invoke the corresponding backend endpoint through any other path (e.g., a direct API call) still receives HTTP 403 from the backend.

#### Scenario: Client-side role check is bypassed
- **WHEN** a request for a privileged operation reaches the backend without passing through the Flutter UI authorization check
- **THEN** the backend evaluates the JWT role claim independently and rejects requests with insufficient authorization.

### Requirement: Role-insufficient response presentation
The system SHALL present a distinct user-safe message when a backend 403 Forbidden response is received due to insufficient role, clearly communicating that the action requires higher authorization without revealing token contents, role claim values, or internal security details.

#### Scenario: 403 role-insufficient response for irrigation control
- **WHEN** a `viewer` submits an irrigation command that the backend rejects with 403
- **THEN** the UI displays a clear authorization warning (e.g., "You do not have permission to perform this action") and does not reveal the user's role string, token content, or which specific claim failed.

#### Scenario: 403 role-insufficient response for node lifecycle operation
- **WHEN** a `viewer` attempts a node lifecycle mutation that the backend rejects with 403
- **THEN** the UI displays a role-insufficient warning and retains the current authenticated session without redirecting to login.

## MODIFIED Requirements

### Requirement: Auth and control input validation
The system SHALL validate authentication credentials and irrigation command inputs before network submission, rejecting empty credentials, invalid irrigation targets other than `ENTIRE FIELD`, and malformed command parameters. Authorization role is resolved server-side; the client validates inputs before submission but does not substitute client-side role checks for backend authorization.

#### Scenario: Empty credentials rejected
- **WHEN** the user submits a login form with a missing identifier or password
- **THEN** the system blocks the network call and shows a validation error on the login view.

#### Scenario: Invalid irrigation target rejected
- **WHEN** a caller attempts an irrigation command with a Q1–Q4 or other non-`ENTIRE FIELD` target
- **THEN** the system rejects the command before network submission.

#### Scenario: Irrigation command rejected by backend due to insufficient role
- **WHEN** a valid irrigation command with target `ENTIRE FIELD` is submitted but the backend returns 403
- **THEN** the client displays a role-insufficient warning and does not retry the command automatically.
