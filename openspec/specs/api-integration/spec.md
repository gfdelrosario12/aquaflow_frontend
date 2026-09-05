## Purpose

Provides the AquaSense mobile application's shared REST transport, API DTOs and services, authentication lifecycle integration, repository adapters, typed error handling, and centralized irrigation safety boundary.

## Requirements

### Requirement: Shared REST transport configuration
The system SHALL provide a shared REST client configured with an environment-specific HTTPS base URL, JSON request/response handling, authentication header injection, request timeouts, response decoding, and safe request diagnostics that redact secrets.

#### Scenario: API service sends a configured request
- **WHEN** a repository invokes an API service
- **THEN** the client sends the request to the configured HTTPS base URL with JSON headers, the current access token when available, and the configured timeout policy.

#### Scenario: Diagnostics redact sensitive headers
- **WHEN** request diagnostics are recorded for an authorized call
- **THEN** Authorization values and token or password fields are redacted while preserving non-sensitive transport metadata.

### Requirement: API endpoint coverage
The system SHALL provide API service methods for `/api/auth/login`, `/api/auth/logout`, `/api/fields`, `/api/fields/{id}`, `/api/quarters`, `/api/quarters/{id}`, `/api/measurements`, `/api/analytics`, `/api/analytics/water-level`, `/api/irrigation/status`, `/api/irrigation/start`, `/api/irrigation/stop`, `/api/alerts`, `/api/devices`, and `/api/gateway`.

#### Scenario: Feature repository requests backend data
- **WHEN** a feature repository requests authentication, field, monitoring, measurement, analytics, alert, device, gateway, or irrigation data
- **THEN** the corresponding API service calls the documented endpoint and returns a typed result or typed failure.

### Requirement: DTO serialization and domain mapping
The system SHALL represent API requests and responses with endpoint-specific DTOs and SHALL map DTOs into existing domain models without requiring domain or presentation code to parse JSON.

#### Scenario: Backend response is decoded
- **WHEN** an API service receives a valid JSON response
- **THEN** it decodes the response into a DTO and maps it into the repository's existing domain contract.

#### Scenario: Backend response is invalid
- **WHEN** a response is missing required fields or has an unsupported shape
- **THEN** the service returns a typed decoding failure and does not expose a partially parsed domain object.

### Requirement: Authentication and token refresh lifecycle
The system SHALL support login and logout through the authentication API and SHALL attach access tokens to authorized requests, refresh expired tokens through the authentication boundary, and clear the authenticated session when refresh fails.

#### Scenario: Authorized request encounters an expired token
- **WHEN** an authorized request receives an authentication-expired response and a refresh token is available
- **THEN** the client performs one coordinated refresh, retries the original eligible request once with the new token, and returns its result.

#### Scenario: Token refresh fails
- **WHEN** token refresh fails or no refresh token is available
- **THEN** the client clears the authenticated session and returns an authentication failure without retrying indefinitely.

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

### Requirement: Repository implementations preserve domain boundaries
The system SHALL provide REST-backed repository implementations for authentication, fields, monitoring quarters, measurements, AWD analytics, alerts, devices, gateway status, and centralized irrigation while preserving existing repository abstractions and injectable mock implementations.

#### Scenario: Production repository replaces a mock repository
- **WHEN** the application selects API-backed repositories
- **THEN** existing feature notifiers and screens consume the same domain-facing interfaces without direct HTTP or DTO dependencies.

### Requirement: Monitoring query and irrigation command isolation
The system SHALL allow Q1-Q4 identifiers for independent monitoring queries but SHALL restrict irrigation mutations to the centralized entire-field system. The mobile application MUST NOT communicate directly with LoRaWAN devices or gateway hardware.

#### Scenario: Query an individual monitoring quarter
- **WHEN** a monitoring repository requests a quarter or quarter measurements for Q1, Q2, Q3, or Q4
- **THEN** the API service sends a read/query request scoped to that quarter without creating or addressing a quarter-level irrigation controller.

#### Scenario: Send an irrigation command
- **WHEN** a caller requests irrigation start or stop
- **THEN** the repository requires the target scope `ENTIRE FIELD`, calls the centralized irrigation endpoint, and rejects any Q1-Q4 or zone-specific target before making a network request.

#### Scenario: Mobile app communicates with field hardware
- **WHEN** the app needs gateway or irrigation hardware state
- **THEN** it communicates with the AquaSense REST API and never opens a direct LoRaWAN, radio, or gateway hardware connection.

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
