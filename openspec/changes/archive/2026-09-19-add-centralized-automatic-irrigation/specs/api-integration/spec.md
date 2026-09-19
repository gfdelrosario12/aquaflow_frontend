## ADDED Requirements

### Requirement: Automatic irrigation configuration and audit trail API endpoints
The system SHALL provide REST API service endpoints and DTO mappings for automated irrigation management, including `/api/irrigation/auto-config` (GET, PUT), `/api/irrigation/auto-state` (GET), `/api/irrigation/auto-lockout/clear` (POST), and `/api/irrigation/audit-log` (GET). All audit log entries MUST include typed actor metadata (`actorType: system | user`, `actorId: String`).

#### Scenario: Fetching automatic irrigation configuration
- **WHEN** the application loads the automatic irrigation settings interface
- **THEN** it issues a GET request to `/api/irrigation/auto-config` and decodes the response into an `AutoIrrigationConfig` domain model.

#### Scenario: Updating automatic irrigation configuration
- **WHEN** an authorized operator modifies the automatic mode toggle or safety parameters
- **THEN** the application issues a PUT request to `/api/irrigation/auto-config` with validated payload and updates the active configuration.

#### Scenario: Fetching irrigation execution audit log
- **WHEN** the user views the irrigation history on the Control or Analytics screen
- **THEN** the system fetches `/api/irrigation/audit-log` and presents entries distinguishing automated cycles (`system/auto-awd`) from manual operator triggers (`user/<id>`).

#### Scenario: Clearing a fault lockout
- **WHEN** an authorized operator clears a fault lockout on the Control screen
- **THEN** the application dispatches a POST request to `/api/irrigation/auto-lockout/clear` with an optional resolution note, receiving the restored `standby` state.

