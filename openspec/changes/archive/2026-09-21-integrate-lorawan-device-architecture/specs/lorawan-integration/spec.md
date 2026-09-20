## Purpose

Establishes the production LoRaWAN integration architecture for AquaSense dynamic sensor nodes, including device identity mapping (DevEUI, JoinEUI, AppKey, DevAddr), uplink payload ingestion, binary decoding, multi-gateway frame deduplication, timestamp normalization, downlink command boundaries, Class A receive window management, device connectivity tracking, and message broker interface boundaries.

## ADDED Requirements

### Requirement: End-to-end LoRaWAN production architecture and layer isolation
The system SHALL enforce a strict layered production architecture: `Flutter Android/Web client` <-> `Backend API / Realtime Layer` <-> `Message Broker (MQTT/AMQP)` <-> `LoRaWAN Network Server (LNS)` <-> `LoRaWAN Gateway` <-> `Distributed Sensor Nodes (ESP32/RFM95W)`. The Flutter application client MUST NOT attempt direct wireless, radio, Bluetooth, or peer-to-peer communication with LoRaWAN sensor nodes or field gateway hardware.

#### Scenario: Flutter app consumes sensor telemetry
- **WHEN** a user views sensor node telemetry or diagnostics in the Flutter mobile application
- **THEN** the application fetches data exclusively from the backend REST API or WebSocket channel and never opens a direct LoRaWAN or radio connection to sensor nodes.

#### Scenario: Sensor node transmits uplink data
- **WHEN** an ESP32 sensor node transmits an RF uplink packet
- **THEN** the packet is received by a LoRaWAN Gateway, forwarded to the LoRaWAN Network Server (LNS), published to the backend Message Broker, processed by the backend telemetry ingestion service, and delivered to the Flutter app via WebSocket.

### Requirement: Centralized irrigation controller isolation from LoRaWAN nodes
The system SHALL enforce complete architectural separation between telemetry-only LoRaWAN sensor nodes and the centralized field irrigation controller. Sensor nodes, monitoring zones, and LNS uplink events MUST NOT directly trigger, control, or message field pumps, valves, or irrigation equipment. All field irrigation actuations SHALL be dispatched strictly through the centralized field irrigation controller by backend AWD supervision or authorized human manual commands.

#### Scenario: Sensor node reports critically dry soil moisture
- **WHEN** a LoRaWAN sensor node transmits an uplink indicating soil moisture below the AWD threshold
- **THEN** the uplink is decoded and processed by the backend AWD analysis engine, which evaluates field-wide eligibility before issuing a field-level command to the central irrigation controller; the sensor node itself never executes pump commands.

### Requirement: LoRaWAN device identity mapping and dynamic zone binding
The system SHALL map dynamic sensor nodes to immutable LoRaWAN device identities (`devEui`, `joinEui`/`appEui`, `appKey`, `devAddr`) stored in the backend registry. Sensor nodes SHALL be dynamically bound to Monitoring Zones and Monitoring Points in the database without hardcoding node IDs or quadrant codes (Q1/Q2/Q3/Q4).

#### Scenario: Provisioning a LoRaWAN sensor node
- **WHEN** an authorized operator provisions a new sensor node by providing its 64-bit `devEui` and 128-bit `appKey` and associating it with "Monitoring Zone 3"
- **THEN** the backend registers the LoRaWAN identity in the network server registry, binds the node to "Monitoring Zone 3", and begins associating incoming uplinks matching `devEui` with that zone without relying on hardcoded node identifiers.

### Requirement: Uplink frame ingestion, binary decoding, and payload normalization
The backend ingestion service SHALL consume raw uplink JSON/protobuf messages from the LNS message broker, decode binary sensor payloads into normalized physical measurements (soil moisture percentage, water table depth mm, battery voltage V, internal temperature °C), extract gateway metadata (RSSI, SNR, Frequency, Spreading Factor), validate payload checksums, and convert device timestamps to ISO 8601 UTC server timestamps.

#### Scenario: Ingesting raw LoRaWAN uplink message
- **WHEN** the LNS message broker publishes an uplink topic `application/1/device/+/event/up`
- **THEN** the backend ingestion service decodes the binary payload bytes into structured numerical measurements, validates payload CRC/checksum, attaches RSSI and SNR metadata, and persists a normalized `SensorMeasurement` record.

#### Scenario: Rejecting invalid or corrupted uplink payload
- **WHEN** an uplink frame arrives with corrupted payload bytes or failed checksum validation
- **THEN** the backend drops the invalid measurement, logs a payload decoding error event, and increments the device error counter without corrupting zone measurement history.

### Requirement: Multi-gateway frame deduplication and frame counter validation
The system SHALL deduplicate multi-gateway uplink frames arriving for the same transmission using `devEui` and uplink frame counter (`fCntUp`) within a configurable deduplication window (default 1000ms), selecting the frame with optimal SNR/RSSI while incrementing gateway reception count metrics. The system MUST validate frame counter sequencing and reject replay attacks.

#### Scenario: Duplicate uplink frames from multiple gateways
- **WHEN** three distinct LoRaWAN gateways receive and forward the same uplink frame (`fCntUp: 42`) for `devEui: 0004A30B001F1234` within 200ms
- **THEN** the backend ingestion service processes the measurement once, selects the gateway metadata with highest SNR, records gateway reception metrics for all three gateways, and discards duplicate payload processing.

#### Scenario: Out-of-order or replayed frame counter
- **WHEN** an uplink frame arrives with an `fCntUp` lower than or equal to the last confirmed frame counter for an active session
- **THEN** the backend flags the frame as a potential duplicate/replay attempt, logs a diagnostic warning, and discards the payload.

### Requirement: Downlink command boundaries and Class A window management
The backend SHALL enforce downlink command queuing for Class A LoRaWAN sensor nodes, queuing downlink payloads (such as transmission interval reconfigurations or calibration adjustments) until the next Class A receive window following an uplink frame. Downlink commands MUST be tracked with `fCntDown`, delivery confirmation status (`queued`, `transmitted`, `acknowledged`, `expired`), and uninhibited timeout policies.

#### Scenario: Queuing a transmission interval update downlink
- **WHEN** an operator updates a LoRaWAN node's transmission interval from 300s to 60s
- **THEN** the backend queues a Class A downlink frame with `fCntDown` in the LNS downlink queue and marks command status as `queued`, transmitting it immediately after the node's next uplink transmission.

### Requirement: Device status and connectivity state machine
The system SHALL maintain real-time connectivity status for every registered LoRaWAN device based on heartbeat timers, missed frame counter thresholds, and RSSI/SNR signal levels, transitioning device state deterministically across `unprovisioned`, `online`, `degraded`, `offline`, and `stale`.

#### Scenario: LoRaWAN node misses expected heartbeat window
- **WHEN** a sensor node configured for a 300-second reporting interval sends no uplinks for 900 seconds (3 missed intervals)
- **THEN** the backend connectivity monitor transitions the device status from `online` to `degraded`/`stale`, emits a real-time WebSocket connectivity alert to active clients, and updates the device diagnostic badge.

