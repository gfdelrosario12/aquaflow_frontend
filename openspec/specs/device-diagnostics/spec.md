## Purpose

Provides health monitoring, telemetry link quality analysis, and diagnostic inspection across the four monitoring sensor nodes (Q1-Q4), the LoRaWAN gateway, and the centralized field irrigation controller for AquaSense.
## Requirements
### Requirement: Quad-zone monitoring node diagnostic inspection
The system SHALL present individual diagnostic cards for all configured and discovered sensor nodes detailing online/offline state, battery voltage and percentage, RSSI, SNR, last seen timestamp, last telemetry measurement, communication status, and health status (`Healthy`, `Degraded`, `Offline`, `Stale`, or `Error`), supporting any number of deployed nodes.

#### Scenario: Inspecting monitoring node telemetry health
- **WHEN** the user opens the Device Diagnostics screen
- **THEN** diagnostic metrics (battery, RSSI, SNR, last seen, last measurement, and health badge) are displayed for all registered sensor nodes.

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
The system MUST maintain clear diagnostic separation between telemetry monitoring nodes and the central irrigation controller, strictly excluding any node-level or zone-specific irrigation control actions.

#### Scenario: Verifying read-only nature of monitoring node diagnostics
- **WHEN** the user inspects diagnostic details for any monitoring node
- **THEN** telemetry diagnostic parameters are presented as strictly read-only health metrics with zero pump/valve activation controls.

### Requirement: Standardized diagnostic health state management
The system SHALL model and display system health using standardized diagnostic states (`Healthy`, `Degraded`, `Offline`, `Stale`, `Error`), supporting loading, empty state, stale data warnings, and communication error handling.

#### Scenario: Displaying degraded or offline hardware health state
- **WHEN** a sensor node or controller experiences missed heartbeats, low battery, or RF degradation
- **THEN** the system updates its health badge to Degraded or Offline and highlights recommended diagnostic steps.

### Requirement: Dynamic ESP32 node diagnostic telemetry and interval inspection
The system SHALL present diagnostic telemetry for all registered dynamic ESP32 nodes, including node MAC address, online/offline status, battery percentage and voltage, RSSI, SNR, last seen timestamp, active transmission interval, adaptive rate status, and spatial coordinates.

#### Scenario: Inspecting dynamic ESP32 node diagnostic health
- **WHEN** the user opens the Device Diagnostics screen and selects a registered ESP32 node
- **THEN** the diagnostic inspector displays the node's MAC address, signal metrics, battery voltage, active transmission interval, and coordinates.

### Requirement: Direct node interval configuration entrypoint
The system SHALL provide an authorized action trigger within the device diagnostics detail inspector allowing operators to adjust the node's transmission interval or view adaptive rate history.

#### Scenario: Opening interval configuration from diagnostics
- **WHEN** an authorized user taps "Configure Transmission Interval" in the device detail inspector
- **THEN** an interval configuration dialog opens showing current interval presets and adaptive mode options.

