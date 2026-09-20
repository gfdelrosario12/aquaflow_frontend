## MODIFIED Requirements

### Requirement: User login authentication
The system SHALL provide a user authentication interface accepting valid user credentials (username/email and password) to obtain authentication session tokens. Upon successful credential validation the backend SHALL resolve the user's field membership, embed `fieldId` and `role` claims in the issued tokens, and return the field-scoped session to the client.

#### Scenario: Successful login with valid credentials and field membership
- **WHEN** the user inputs valid credentials and submits the login form
- **THEN** the system authenticates the user, resolves field membership, stores access and refresh tokens (with embedded field and role claims) in secure storage, and navigates to the application dashboard shell.

#### Scenario: Successful credentials but no field membership
- **WHEN** the user inputs valid credentials but has no field membership record
- **THEN** the backend refuses to issue a field-scoped token, the client displays a clear authorization error, and the user remains on the login screen without stored tokens.

#### Scenario: Failed login with invalid credentials
- **WHEN** the user inputs incorrect or missing credentials and submits the form
- **THEN** the system displays a clear error message, remains on the login view, and does not update session tokens.

### Requirement: Secure token storage and session persistence
The system SHALL persist only access and refresh tokens in secure platform storage rather than plaintext preferences, and MUST NOT persist user passwords or raw credential secrets after login completes. Stored tokens carry field and role claims and the Flutter client SHALL surface the resolved role from the token payload for UI gating purposes.

#### Scenario: App launch with existing valid session
- **WHEN** the user opens the application with valid persisted session tokens
- **THEN** the system automatically validates the session, resolves the user's role from the stored token claims, and directs the user directly to the application shell without requiring re-authentication.

#### Scenario: Password is not retained after login
- **WHEN** login succeeds and tokens are written to secure storage
- **THEN** the password is not written to secure storage, preferences, or offline cache.

### Requirement: User logout and session termination
The system SHALL allow authenticated users to log out, revoking active session tokens on the backend and clearing stored credentials from secure storage on the client.

#### Scenario: User initiates logout
- **WHEN** the user selects the logout action from settings or header menu
- **THEN** the system calls the backend logout endpoint to revoke the session, purges stored session tokens locally, and immediately redirects the interface to the Login screen.

### Requirement: Unauthorized response handling
The system SHALL catch 401 Unauthorized responses (unauthenticated or expired token) and 403 Forbidden responses (insufficient role) distinctly. A 401 SHALL clear tokens and redirect to login; a 403 SHALL display a role-insufficient warning without clearing the session.

#### Scenario: Session token expiration during operation
- **WHEN** an API call returns a 401 Unauthorized status or token refresh fails
- **THEN** the system invalidates the local session, purges stored tokens, and transitions the UI to the Login screen with an alert notification that does not reveal token contents.

#### Scenario: Role-insufficient 403 received during operation
- **WHEN** an API call returns 403 Forbidden due to insufficient role
- **THEN** the system displays a role-insufficient warning, retains the current authenticated session, and does not redirect to login.

## ADDED Requirements

### Requirement: Field membership and role resolution at login
The system SHALL parse the `fieldId` and `role` claims from the access token after a successful login and expose the resolved role through the `UserSession` domain model for use in UI authorization gates. The client MUST NOT derive authorization decisions from any source other than the token claims as interpreted by the backend.

#### Scenario: Role is resolved from token after login
- **WHEN** login succeeds and the access token is stored
- **THEN** the `UserSession` model exposes the `role` and `fieldId` from the token payload, allowing UI components to conditionally render privileged controls.

#### Scenario: Role resolution fails due to missing claim
- **WHEN** the token is missing a `role` or `fieldId` claim
- **THEN** the session is treated as unauthorized, tokens are cleared, and the user is prompted to re-authenticate.
