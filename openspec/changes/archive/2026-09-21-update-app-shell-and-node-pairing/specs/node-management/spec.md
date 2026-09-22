## ADDED Requirements

### Requirement: Hardware-activated node pairing mode discovery
The system SHALL support detecting physical sensor nodes that have entered discoverable pairing mode via a physical button press on the node hardware, enabling rapid pairing and assignment to dynamic monitoring zones without manual DevEUI or MAC entry.

#### Scenario: Discovering node activated by hardware pairing button
- **WHEN** an operator presses the physical pairing button on a sensor node and initiates discovery in the application
- **THEN** the application detects the node's broadcasted hardware identifier and presents a pairing confirmation dialog with dynamic zone assignment options.
