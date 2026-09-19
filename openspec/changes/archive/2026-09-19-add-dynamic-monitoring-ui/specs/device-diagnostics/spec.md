## MODIFIED Requirements

### Requirement: Quad-zone monitoring node diagnostic inspection
The system SHALL present individual diagnostic cards for all configured and discovered sensor nodes detailing online/offline state, battery voltage and percentage, RSSI, SNR, last seen timestamp, last telemetry measurement, communication status, and health status (`Healthy`, `Degraded`, `Offline`, `Stale`, or `Error`), supporting any number of deployed nodes.

#### Scenario: Inspecting monitoring node telemetry health
- **WHEN** the user opens the Device Diagnostics screen
- **THEN** diagnostic metrics (battery, RSSI, SNR, last seen, last measurement, and health badge) are displayed for all registered sensor nodes.

### Requirement: Strict isolation of monitoring nodes from irrigation controls
The system MUST maintain clear diagnostic separation between telemetry monitoring nodes and the central irrigation controller, strictly excluding any node-level or zone-specific irrigation control actions.

#### Scenario: Verifying read-only nature of monitoring node diagnostics
- **WHEN** the user inspects diagnostic details for any monitoring node
- **THEN** telemetry diagnostic parameters are presented as strictly read-only health metrics with zero pump/valve activation controls.

