## MODIFIED Requirements

### Requirement: Monitoring query and irrigation command isolation
The system SHALL allow dynamic zone identifiers for independent monitoring queries but SHALL restrict irrigation mutations to the centralized entire-field system. The mobile application MUST NOT communicate directly with LoRaWAN devices or gateway hardware.

#### Scenario: Query an individual monitoring quarter
- **WHEN** a monitoring repository requests a quarter or quarter measurements for Q1, Q2, Q3, or Q4
- **THEN** the API service sends a read/query request scoped to that quarter without creating or addressing a quarter-level irrigation controller.

#### Scenario: Send an irrigation command
- **WHEN** a caller requests irrigation start or stop
- **THEN** the repository requires the target scope `ENTIRE FIELD`, calls the centralized irrigation endpoint, and rejects any Q1-Q4 or zone-specific target before making a network request.

#### Scenario: Mobile app communicates with field hardware
- **WHEN** the app needs gateway or irrigation hardware state
- **THEN** it communicates with the AquaSense REST API and never opens a direct LoRaWAN, radio, or gateway hardware connection.

#### Scenario: LoRaWAN device telemetry isolation
- **WHEN** the Flutter mobile application requests LoRaWAN device telemetry or status
- **THEN** the backend API service handles LNS message decoding and returns parsed domain models over REST or WebSocket, isolating the client app from raw LoRaWAN frames and network server credentials.

