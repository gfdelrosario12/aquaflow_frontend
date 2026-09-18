## Purpose

Establishes the core agricultural field domain model, separating logical monitoring locations from physical sensor hardware and supporting dynamic node counts with extensible sensor capabilities.

## ADDED Requirements

### Requirement: Field root aggregate and boundary definition
The system SHALL model `Field` as the top-level deployment boundary containing geographic boundaries, acreage, soil classification, active crop growth stage, active AWD threshold configuration, and dynamic collections of monitoring zones, monitoring points, and the centralized irrigation controller.

#### Scenario: Querying field deployment configuration
- **WHEN** the application loads field data for an authenticated user session
- **THEN** the system returns the field aggregate with its geographic boundaries, active crop stage, assigned monitoring zones, and centralized irrigation system status.

### Requirement: Separation of logical monitoring location from physical sensor node
The system SHALL decouple the logical observation location (`MonitoringPoint`) from the physical hardware device (`SensorNode`), such that a physical node can be assigned, unassigned, replaced, or serviced without breaking the continuity or historical measurements of the logical monitoring point.

#### Scenario: Replacing a physical sensor node at an existing monitoring point
- **WHEN** an operator replaces a faulty sensor node at Monitoring Point 3 with a newly commissioned node
- **THEN** the historical water level and soil moisture records for Monitoring Point 3 remain intact and continuous under the new physical node's telemetry stream.

### Requirement: Extensible sensor node hardware identity and metadata
The system SHALL represent `SensorNode` with hardware identity attributes including unique MAC address or DevEUI, hardware revision, firmware version string, battery percentage, battery voltage, radio signal metrics (RSSI and SNR), last communication timestamp, and transmission interval configuration.

#### Scenario: Inspecting physical sensor node hardware status
- **WHEN** an operator or administrator inspects a sensor node in diagnostics or settings
- **THEN** the system displays the node's unique hardware identifier, firmware version, battery health metrics, radio signal strength, and current reporting interval.

### Requirement: Extensible multi-sensor transducer representation
The system SHALL support multiple sensor channels per physical node, allowing a single `SensorNode` to host one or more distinct `Sensor` transducers (such as perforated tube water level, soil moisture at multiple depths, soil temperature, and ambient humidity) with independent units, depth offsets, and calibration parameters.

#### Scenario: Ingesting multi-sensor payload from a single node
- **WHEN** a physical sensor node transmits a telemetry uplink containing both tube water depth and dual-depth soil moisture (15cm and 30cm)
- **THEN** the system parses each sensor reading into an independent `Measurement` associated with its corresponding `Sensor` entity and the parent `MonitoringPoint`.

### Requirement: Formal sensor node lifecycle state machine
The system SHALL enforce a formal lifecycle state machine for physical sensor nodes comprising `discovered`, `provisioning`, `active`, `maintenance`, `offline`, `replaced`, and `decommissioned` states.

#### Scenario: Provisioning a discovered node
- **WHEN** an operator claims an unassigned node in `discovered` state, assigns it to a monitoring point, and confirms datum calibration
- **THEN** the node transitions to `active` state and begins participating in field telemetry aggregation.

#### Scenario: Detecting an offline sensor node
- **WHEN** an active sensor node fails to report heartbeats for longer than three times its configured transmission interval
- **THEN** the system flags the node state as `offline` and generates a non-critical connectivity alert while keeping the logical point identity valid.

### Requirement: Preservation of centralized irrigation guardrails
The system MUST model all monitoring zones, monitoring points, and sensor nodes as strictly read-only observational entities, prohibiting any local valve or pump control triggers on individual monitoring points, and reserving all irrigation actuation exclusively for the field's centralized irrigation system.

#### Scenario: Attempting to trigger irrigation on a monitoring point
- **WHEN** a client or user attempts to issue an actuation command targeting an individual monitoring point or sensor node
- **THEN** the system rejects the operation and enforces that irrigation commands can only target the field's centralized irrigation controller.

