## MODIFIED Requirements

### Requirement: Security events are audited
The system SHALL audit security-sensitive operations, including authentication failures, authorization denials, transport/TLS failures, and sensitive data redaction events.

#### Scenario: Insecure transport is rejected
- **WHEN** the system rejects an insecure `http:` API base URL in a non-test configuration
- **THEN** the system SHALL create an audit event with `actor.type: user` or `actor.type: system`, `category: security`, `action: security.transport_rejected`, `result: denied`, and metadata containing the rejected URL scheme and source

#### Scenario: Authorization denial is audited
- **WHEN** an authenticated user is denied access to a security-sensitive operation
- **THEN** the system SHALL create an audit event with `actor.type: user`, `category: authorization`, `action: authorization.denied`, `result: denied`, and metadata containing the operation attempted and the denial reason

#### Scenario: Sensitive data redaction event is recorded
- **WHEN** the system redacts sensitive data from logs or diagnostics
- **THEN** the system SHALL create an audit event with `actor.type: system`, `category: security`, `action: security.redaction`, `result: success`, and metadata containing the type of sensitive data redacted
