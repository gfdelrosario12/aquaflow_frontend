## MODIFIED Requirements

### Requirement: Dynamic ESP32 node discovery and registration
The system SHALL support discovering uncommissioned ESP32 sensor nodes detected on the network and allow authorized operators to register them with a human-readable name, hardware identifier (MAC address or 64-bit LoRaWAN DevEUI), and target field/zone, dynamically expanding the active monitoring zones upon registration.

#### Scenario: Discovering and registering a new ESP32 node
- **WHEN** an authorized operator opens the node registration interface and selects an unassigned discovered ESP32 node
- **THEN** the system registers the node, assigns its display identifier, binds it to the target zone, and confirms successful commissioning without requiring app reloads.

#### Scenario: Registering a node to a new monitoring zone
- **WHEN** an operator registers a new node and assigns it to a newly created monitoring zone (such as "Zone 5 - East")
- **THEN** the system dynamically adds the new monitoring zone to the field monitoring state and updates overall field metrics without hardcoding quadrant limits.
