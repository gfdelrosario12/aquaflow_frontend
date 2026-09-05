## Purpose

Provides health monitoring, telemetry link quality analysis, and diagnostic inspection across the four monitoring sensor nodes (Q1-Q4), the LoRaWAN gateway, and the centralized field irrigation controller for AquaSense.

## Requirements

### Requirement: Quad-zone monitoring node diagnostic inspection
The system SHALL present individual diagnostic cards for monitoring nodes Q1, Q2, Q3, and Q4 detailing online/offline state, battery voltage and percentage, RSSI, SNR, last seen timestamp, last telemetry measurement, communication status, and health status (`Healthy`, `Degraded`, `Offline`, `Stale`, or `Error`).

#### Scenario: Inspecting monitoring node telemetry health
- **WHEN** the user opens the Device Diagnostics screen
- **THEN** diagnostic metrics (battery, RSSI, SNR, last seen, last measurement, and health badge) are displayed for each quadrant node Q1-Q4.

### Requirement: Field LoRaWAN Gateway health diagnostics
The system SHALL display connectivity status, last communication timestamp, uplink/downlink network packet stats, backhaul status, and health state for the field LoRaWAN gateway.

#### Scenario: Inspecting field gateway connectivity and network health
- **WHEN** the user views the Gateway Diagnostics section of the Device Diagnostics screen
- **THEN** gateway connectivity state, packet transmission stats, last communication timestamp, and health status are rendered.

### Requirement: Centralized irrigation controller diagnostic reporting
The system SHALL display connectivity state, main pump status, distribution valve status, last command type, command result outcome, last communication timestamp, and target scope (`ENTIRE FIELD`) for the single centralized field irrigation controller.

#### Scenario: Inspecting centralized controller operational diagnostics
- **WHEN** the user views the Central Controller section of the Device Diagnostics screen
- **THEN** controller online/offline state, main pump state, valve state, last command execution result, and target `ENTIRE FIELD` are displayed.

### Requirement: Strict isolation of monitoring nodes from irrigation controls
The system MUST maintain clear diagnostic separation between telemetry monitoring nodes (Q1-Q4) and the central irrigation controller, strictly excluding any quadrant-level or zone-specific irrigation control actions.

#### Scenario: Verifying read-only nature of monitoring node diagnostics
- **WHEN** the user inspects diagnostic details for monitoring nodes Q1, Q2, Q3, or Q4
- **THEN** telemetry diagnostic parameters are presented as strictly read-only health metrics with zero pump/valve activation controls.

### Requirement: Standardized diagnostic health state management
The system SHALL model and display system health using standardized diagnostic states (`Healthy`, `Degraded`, `Offline`, `Stale`, `Error`), supporting loading, empty state, stale data warnings, and communication error handling.

#### Scenario: Displaying degraded or offline hardware health state
- **WHEN** a sensor node or controller experiences missed heartbeats, low battery, or RF degradation
- **THEN** the system updates its health badge to Degraded or Offline and highlights recommended diagnostic steps.
