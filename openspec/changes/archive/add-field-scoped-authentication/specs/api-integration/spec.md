## MODIFIED Requirements

### Requirement: Authentication and token refresh lifecycle
The system SHALL support login and logout through the authentication API, attach field-scoped access tokens (carrying `fieldId` and `role` claims) to authorized requests, refresh expired tokens through the authentication boundary, and clear the authenticated session when refresh fails.

#### Scenario: Authorized request encounters an expired token
- **WHEN** an authorized request receives an authentication-expired response and a refresh token is available
- **THEN** the client performs one coordinated refresh, retries the original eligible request once with the new token, and returns its result.

#### Scenario: Token refresh fails
- **WHEN** token refresh fails or no refresh token is available
- **THEN** the client clears the authenticated session and returns an authentication failure without retrying indefinitely.

#### Scenario: Refreshed token carries updated field-scoped claims
- **WHEN** a token refresh completes successfully
- **THEN** the new access token is stored and the `fieldId` and `role` claims from the refreshed token are applied to subsequent requests.

### Requirement: Authorization failure mapping
The system SHALL map HTTP 401 Unauthorized responses (expired or missing token) and HTTP 403 Forbidden responses (insufficient role or field mismatch) into distinct typed failures. A typed `unauthenticated` failure MUST trigger session clearance and login redirection; a typed `insufficientRole` failure MUST surface a role-insufficient warning without clearing the session. These two error types MUST NOT be conflated.

#### Scenario: 401 unauthenticated response
- **WHEN** an API call returns 401 Unauthorized
- **THEN** the service returns a typed `unauthenticated` failure, the session manager clears stored tokens, and the Flutter client redirects to login.

#### Scenario: 403 role-insufficient response
- **WHEN** an API call returns 403 Forbidden
- **THEN** the service returns a typed `insufficientRole` failure; the session is preserved and the Flutter client presents a role-insufficient warning without redirecting to login.

#### Scenario: Forbidden irrigation response
- **WHEN** an irrigation command API call returns 403
- **THEN** the service returns a typed `insufficientRole` failure and does not retry the command.

## ADDED Requirements

### Requirement: Field-scoped token forwarding
The system SHALL include the full access token (containing `fieldId` and `role` claims) in the `Authorization: Bearer` header on every authorized request. The client MUST NOT strip or modify field-scoped claims before transmission.

#### Scenario: Authorized request carries full field-scoped token
- **WHEN** a repository invokes an API service for a field-specific resource
- **THEN** the request includes the `Authorization: Bearer <token>` header where the token contains intact `fieldId` and `role` claims.

#### Scenario: Request for a mismatched field resource
- **WHEN** a request is sent for a resource belonging to a different `fieldId` than the one in the token
- **THEN** the backend returns 403, which the client maps to a typed `insufficientRole` failure.
