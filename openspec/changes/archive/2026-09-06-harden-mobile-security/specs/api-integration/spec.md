## MODIFIED Requirements

### Requirement: Shared REST transport configuration
The system SHALL provide a shared REST client configured with an environment-specific HTTPS base URL, JSON request/response handling, authentication header injection, request timeouts, response decoding, and safe request diagnostics that redact secrets.

#### Scenario: API service sends a configured request
- **WHEN** a repository invokes an API service
- **THEN** the client sends the request to the configured HTTPS base URL with JSON headers, the current access token when available, and the configured timeout policy.

#### Scenario: Diagnostics redact sensitive headers
- **WHEN** request diagnostics are recorded for an authorized call
- **THEN** Authorization values and token or password fields are redacted while preserving non-sensitive transport metadata.

### Requirement: Timeout, retry, and error mapping
The system SHALL map timeout, connectivity, authentication, authorization, validation, server, decoding, and transport-security failures into typed API/repository errors and SHALL apply bounded retries only to eligible transient idempotent requests. Non-idempotent irrigation start or stop commands MUST NOT be automatically replayed.

#### Scenario: Idempotent request has a transient failure
- **WHEN** a GET request fails with an eligible transient network or server condition
- **THEN** the client retries according to the bounded backoff policy and ultimately returns a typed failure if all attempts fail.

#### Scenario: Non-idempotent command fails transiently
- **WHEN** an irrigation start or stop request fails after being sent
- **THEN** the client does not automatically replay the command and returns a typed failure for the caller to resolve.

#### Scenario: Request exceeds timeout
- **WHEN** a backend request does not complete within the configured timeout
- **THEN** the client returns a typed timeout failure without treating the operation as confirmed success.

## ADDED Requirements

### Requirement: HTTPS and TLS transport enforcement
The system SHALL enforce HTTPS for backend API communication in non-test configurations, use platform certificate validation, and return a typed transport-security failure when the base URL scheme is insecure or TLS cannot be established safely.

#### Scenario: Insecure scheme blocked
- **WHEN** API configuration resolves to an `http:` base URL without an explicit local/test override
- **THEN** the client refuses the request and returns a transport-security configuration failure.

### Requirement: Authorization failure mapping
The system SHALL map HTTP 403 Forbidden responses for sensitive operations into typed authorization failures distinct from generic unexpected errors so callers can present unauthorized warnings.

#### Scenario: Forbidden irrigation response
- **WHEN** an irrigation command API call returns 403
- **THEN** the service returns a typed authorization failure and does not retry the command.
