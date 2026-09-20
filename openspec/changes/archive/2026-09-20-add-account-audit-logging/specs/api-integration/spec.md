## MODIFIED Requirements

### Requirement: Unified audit history REST API endpoints
The system SHALL provide REST API service endpoints and DTO mappings for the unified audit history, including `/api/audit/events` (GET, paginated list with filters), `/api/audit/events/{eventId}` (GET, single event), and `/api/audit/events` (POST, internal backend-only emission). All audit log entries MUST include typed actor metadata (`actor.type: user | system | emergencyOverride`, `actor.id: String`, `actor.displayName: String`).

#### Scenario: Fetching audit history
- **WHEN** an authorized user views the audit history
- **THEN** the system SHALL issue a GET request to `/api/audit/events` with filters for category, actor, target, time range, and result, and SHALL decode the response into `AccountAuditEvent` domain models

#### Scenario: Fetching a single audit event
- **WHEN** an authorized user selects an audit event from the audit history UI
- **THEN** the system SHALL issue a GET request to `/api/audit/events/{eventId}` and SHALL decode the response into a single `AccountAuditEvent` domain model

#### Scenario: Unauthorized user attempts audit history access
- **WHEN** a user without audit history permissions attempts to access `/api/audit/events`
- **THEN** the system SHALL return a 403 Forbidden response and SHALL create an audit event with `result: denied` and `category: authorization`
