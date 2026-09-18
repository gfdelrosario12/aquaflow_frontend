# node-management Specification

## Purpose

Enables operator discovery, registration, field and zone assignment, transmission interval configuration, and adaptive rate tracking for dynamic ESP32 IoT sensor nodes.

## Requirements

### Requirement: Dynamic ESP32 node discovery and registration
The system SHALL support discovering uncommissioned ESP32 sensor nodes detected on the network and allow authorized operators to register them with a human-readable name, hardware identifier (MAC address), and target field.

#### Scenario: Discovering and registering a new ESP32 node
- **WHEN** an authorized operator opens the node registration interface and selects an unassigned discovered ESP32 node
- **THEN** the system registers the node, assigns its display identifier, and confirms successful commissioning without requiring app reloads.

### Requirement: Node field and irrigation zone assignment
The system SHALL permit operators to assign or reassign any registered ESP32 sensor node to a specific agricultural field and monitoring/irrigation zone.

#### Scenario: Assigning a node to an irrigation zone
- **WHEN** the operator assigns a registered node to "Zone 1 (North Quadrant)" within "Field A"
- **THEN** the node telemetry is associated with that zone and appears in zone-level aggregated telemetry views.

### Requirement: Node transmission interval configuration
The system SHALL display the active transmission interval (in seconds) for each node and allow users with `admin` or `operator` roles to configure the base reporting interval. Users with `viewer` roles MUST NOT be permitted to modify transmission intervals.

#### Scenario: Authorized operator updates transmission interval
- **WHEN** an authenticated user with `operator` or `admin` role updates the transmission interval of a node to 60 seconds
- **THEN** the system dispatches the configuration command to the backend and updates the displayed interval upon acknowledgment.

#### Scenario: Unauthorized viewer attempts interval configuration
- **WHEN** an authenticated user with `viewer` role accesses the node details
- **THEN** transmission interval controls are disabled or read-only, and unauthorized command attempts are blocked.

### Requirement: Real-time reflection of adaptive transmission changes
The system SHALL ingest backend-driven adaptive transmission interval updates over real-time event streams and immediately reflect the active interval and adaptation reason in the user interface.

#### Scenario: Backend automatically accelerates transmission during moisture dry-down
- **WHEN** the backend adjusts a node transmission interval from 300 seconds to 30 seconds due to rapid moisture depletion and publishes the event
- **THEN** the node's displayed interval updates to 30 seconds in real time with an adaptive indicator badge explaining the dry-down trigger.

