## MODIFIED Requirements

### Requirement: Dynamic ESP32 node diagnostic telemetry and interval inspection
The system SHALL present diagnostic telemetry for all registered dynamic sensor nodes (Wi-Fi ESP32 and LoRaWAN end-devices), including node hardware address/DevEUI, online/offline status, battery percentage and voltage, RSSI, SNR, frame counters (`fCntUp`, `fCntDown`), gateway ID, last seen timestamp, active transmission interval, adaptive rate status, and spatial coordinates.

#### Scenario: Inspecting dynamic ESP32 node diagnostic health
- **WHEN** the user opens the Device Diagnostics screen and selects a registered ESP32 node
- **THEN** the diagnostic inspector displays the node's MAC address, signal metrics, battery voltage, active transmission interval, and coordinates.

#### Scenario: Inspecting LoRaWAN sensor node diagnostic metrics
- **WHEN** the user inspects diagnostic details for a registered LoRaWAN sensor node
- **THEN** the diagnostic inspector displays `devEui`, link quality metrics (RSSI, SNR), uplink frame counter `fCntUp`, downlink frame counter `fCntDown`, receiving gateway ID, battery voltage, and active reporting interval.

