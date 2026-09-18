## ADDED Requirements

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

