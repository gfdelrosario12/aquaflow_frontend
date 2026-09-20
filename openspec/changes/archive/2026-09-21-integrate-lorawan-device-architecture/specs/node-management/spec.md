## MODIFIED Requirements

### Requirement: Secure device identity verification and provisioning
The system SHALL verify physical sensor node identities during commissioning using a stable hardware identifier (MAC address or 64-bit LoRaWAN DevEUI) paired with a cryptographically verified provisioning secret, AppKey, or challenge token. Unverified or duplicate hardware identifiers MUST be rejected.

#### Scenario: Provisioning a verified node
- **WHEN** an operator provisions a discovered node with its valid factory secret or provisioning token
- **THEN** the system validates device identity, assigns cryptographic session credentials, and transitions the node from `discovered` to `provisioned` state.

#### Scenario: Rejecting duplicate or unauthorized device registration
- **WHEN** a registration request arrives with a hardware MAC address or DevEUI already commissioned or an invalid authorization token
- **THEN** the system rejects the registration with a validation error and prevents unauthorized telemetry ingestion.

#### Scenario: Provisioning a LoRaWAN ESP32 sensor node with DevEUI and AppKey
- **WHEN** an authorized operator registers an ESP32 LoRaWAN sensor node by providing its 64-bit `devEui`, `joinEui`, and `appKey`
- **THEN** the backend registers the node credentials with the LoRaWAN Network Server, verifies uniqueness, and binds the node to its assigned monitoring zone.

### Requirement: Node field and irrigation zone assignment
The system SHALL permit operators to assign or reassign any registered sensor node (Wi-Fi/Bluetooth ESP32 or LoRaWAN RFM95W) to a specific agricultural field and monitoring/irrigation zone without hardcoding node identifiers or quadrant labels (Q1/Q2/Q3/Q4).

#### Scenario: Assigning a node to an irrigation zone
- **WHEN** the operator assigns a registered node to "Zone 1 (North Quadrant)" within "Field A"
- **THEN** the node telemetry is associated with that zone and appears in zone-level aggregated telemetry views.

#### Scenario: Dynamic zone mapping without hardcoded quadrant identifiers
- **WHEN** an operator assigns a newly provisioned LoRaWAN node with `devEui: 0004A30B001F9876` to a newly created monitoring zone "Zone 5 - East Field"
- **THEN** the system dynamically associates all incoming uplinks for that `devEui` with "Zone 5 - East Field" without requiring code changes or hardcoded quadrant identifiers.

