## ADDED Requirements

### Requirement: Sensor node lifecycle REST service and endpoint coverage
The system SHALL provide dedicated REST service client endpoints and typed DTO serialization for dynamic sensor node lifecycle management, covering node listing (`GET /api/nodes`), unassigned discovery (`GET /api/nodes/unassigned`), registration (`POST /api/nodes/register`), provisioning (`POST /api/nodes/{id}/provision`), metadata and interval updates (`PATCH /api/nodes/{id}`), lifecycle transitions (`POST /api/nodes/{id}/lifecycle`), atomic node replacement (`POST /api/nodes/{id}/replace`), and decommissioning (`DELETE /api/nodes/{id}`).

#### Scenario: Repository executes node lifecycle REST operations
- **WHEN** the node repository initiates a registration, provisioning, lifecycle transition, or replacement call
- **THEN** the API service serializes typed DTO requests, attaches authorization headers, sends the request to the corresponding node endpoint, and maps response payloads to typed node models or typed failures.

#### Scenario: Node replacement endpoint preserves zone telemetry continuity
- **WHEN** the replacement endpoint `POST /api/nodes/{id}/replace` is called with replacement node ID and target zone ID
- **THEN** the backend updates the node mappings, emits replacement events, and returns the updated zone and node representations with historical measurement continuity verified.

