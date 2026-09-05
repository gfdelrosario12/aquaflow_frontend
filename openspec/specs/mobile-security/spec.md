# mobile-security Specification

## Purpose

Defines security hardening requirements for the AquaSense mobile application covering HTTPS-only backend transport, platform TLS certificate validation, sensitive data redaction in logs and diagnostics, secrets kept out of source code, local sensitive-data minimization, security-related error presentation, auth and control input validation, and the invariant that security controls preserve monitoring-only quarters.

## Requirements

### Requirement: HTTPS-only backend transport
The system SHALL require an HTTPS base URL for AquaSense backend communication in production and staging configurations and SHALL reject insecure `http:` base URLs unless an explicit local/test override is enabled.

#### Scenario: Production configuration uses HTTPS
- **WHEN** the app loads API configuration without a local/test override
- **THEN** the configured base URL uses the `https` scheme and the client proceeds with platform TLS certificate validation.

#### Scenario: Insecure base URL is rejected
- **WHEN** a non-test configuration supplies an `http:` API base URL
- **THEN** the system refuses to send backend requests and surfaces a configuration/security error without transmitting credentials.

### Requirement: Platform TLS certificate validation
The system SHALL rely on the platform TLS trust store for certificate validation and MUST NOT disable certificate verification or install custom trust-all handlers in production builds.

#### Scenario: TLS handshake uses system trust
- **WHEN** the shared REST client connects to the configured HTTPS API
- **THEN** the connection uses normal platform certificate validation without a trust-all or verification-bypass mode.

### Requirement: Sensitive data redaction in logs and diagnostics
The system SHALL redact authentication tokens, passwords, Authorization headers, and other secret fields from logs, crash diagnostics, and request diagnostics.

#### Scenario: Request diagnostics omit secrets
- **WHEN** safe request diagnostics are emitted for an authorized API call
- **THEN** Authorization header values, access/refresh tokens, and password fields are redacted or omitted while non-sensitive method, path, and status metadata may remain.

### Requirement: Secrets kept out of source code
The system MUST NOT embed production API credentials, private keys, access tokens, or passwords in application source. Backend base URLs and non-user configuration SHALL come from environment or build-time injection.

#### Scenario: Inspecting repository configuration
- **WHEN** developers review application source and checked-in configuration
- **THEN** no production credentials or long-lived API secrets are present; only placeholders or environment-driven values are used.

### Requirement: Local sensitive-data minimization
The system SHALL store only access and refresh tokens required for session continuity in secure platform storage and MUST NOT persist user passwords, raw Authorization headers, or unnecessary PII in local preferences or offline caches.

#### Scenario: Successful login persistence
- **WHEN** a user authenticates successfully
- **THEN** only session tokens (and non-secret display profile fields if needed) are retained locally, and the password is discarded from memory as soon as the login request completes.

### Requirement: Security-related error presentation
The system SHALL present clear, user-safe messages for authentication failure, authorization denial, transport/TLS configuration errors, and irrigation command security failures without revealing tokens, stack traces, or internal secrets.

#### Scenario: Authorization denied for irrigation
- **WHEN** a centralized irrigation command is rejected as unauthorized or forbidden
- **THEN** the UI shows an unauthorized/security warning and does not display token material or offer Q1–Q4 zone irrigation actions as remediation.

### Requirement: Auth and control input validation
The system SHALL validate authentication credentials and irrigation command inputs before network submission, rejecting empty credentials, invalid irrigation targets other than `ENTIRE FIELD`, and malformed command parameters.

#### Scenario: Empty credentials rejected
- **WHEN** the user submits a login form with a missing identifier or password
- **THEN** the system blocks the network call and shows a validation error on the login view.

#### Scenario: Invalid irrigation target rejected
- **WHEN** a caller attempts an irrigation command with a Q1–Q4 or other non-`ENTIRE FIELD` target
- **THEN** the system rejects the command before network submission.

### Requirement: Security controls preserve monitoring-only quarters
Security hardening MUST NOT introduce, imply, or expose zone-level irrigation operations for Q1–Q4. Monitoring queries remain read-only and irrigation remains a single centralized `ENTIRE FIELD` backend command path.

#### Scenario: Security error on monitoring screen
- **WHEN** a monitoring or authentication error occurs while viewing Q1–Q4 telemetry
- **THEN** the UI provides retry or re-authentication guidance without presenting zone pump, valve, or irrigation triggers.
