## MODIFIED Requirements

### Requirement: Authentication events are audited
The system SHALL audit all authentication events, including successful logins, failed login attempts, logouts, token refreshes, and session expirations.

#### Scenario: Successful login is audited
- **WHEN** an authenticated user logs in successfully
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: authentication`, `action: user.login`, `result: success`, and metadata containing the request ID and source IP

#### Scenario: Failed login is audited
- **WHEN** an authentication attempt fails due to invalid credentials
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: authentication`, `action: user.login`, `result: failed`, and metadata containing the failure reason and source IP

#### Scenario: Logout is audited
- **WHEN** an authenticated user logs out
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: authentication`, `action: user.logout`, `result: success`

#### Scenario: Token refresh is audited
- **WHEN** an access token is refreshed
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: authentication`, `action: user.token_refresh`, `result: success` or `result: failed` depending on the outcome

#### Scenario: Session expiration is audited
- **WHEN** an authenticated session expires
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: authentication`, `action: user.session_expired`, `result: success`
