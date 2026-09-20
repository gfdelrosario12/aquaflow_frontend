## Why

The AquaSense field monitoring system currently manages dynamic sensor nodes and telemetry, but lacks a formal architecture and interface contract for integrating physical LoRaWAN end-devices (ESP32/RFM95W nodes), LoRaWAN Network Servers (LNS, e.g. ChirpStack / TTN), message brokers (MQTT/AMQP), and backend telemetry processing. To scale deployment to multi-zone agricultural fields, AquaSense requires an architecture where Flutter clients communicate exclusively with the backend API and real-time streaming layer, while the backend handles LoRaWAN payload decoding, device identity mapping, deduplication, timestamp normalization, and zone binding. Centralized field irrigation execution must remain strictly decoupled from LoRaWAN sensor nodes.

## What Changes

- **LoRaWAN System Architecture & Layer Boundaries**: Establish the strict end-to-end production data flow: `Flutter Android/Web Client` <-> `Backend API / WebSocket Layer` <-> `Message Broker (MQTT/AMQP)` <-> `LoRaWAN Network Server (LNS)` <-> `LoRaWAN Gateway` <-> `Distributed Sensor Nodes (ESP32/RFM95W)`. Centralized field irrigation pumps/valves are isolated on dedicated controller channels.
- **Client Isolation**: Strictly prohibit Flutter application clients from attempting direct radio or peer-to-peer communication with LoRaWAN sensor nodes.
- **Dynamic Device Identity Mapping**: Bind dynamic sensor nodes to LoRaWAN credentials (`devEui`, `joinEui`/`appEui`, `appKey`, `devAddr`) and map them dynamically to field monitoring zones without hardcoding node IDs or quadrant codes (Q1/Q2/Q3/Q4).
- **Uplink Ingestion & Normalization**: Implement backend ingestion pipelines that receive raw LNS JSON/protobuf payloads, decode binary sensor frames, deduplicate multi-gateway frames, normalize timestamps, validate checksums, and publish standardized `SensorMeasurement` events.
- **Downlink & Configuration Command Boundaries**: Define downlink command queuing policies, FCntDown tracking, Class A receive window constraints, and distinguish telemetry-only sensor nodes from control-capable nodes.
- **Device Status & Connectivity Lifecycle**: Define RSSI, SNR, frame counter tracking, battery voltage parsing, heartbeat monitoring, and automatic connectivity transitions (`online`, `degraded`, `offline`, `unprovisioned`).
- **Telemetry & Real-Time Distribution**: Bridge decoded LoRaWAN sensor frames from the message broker to the backend telemetry database and emit realtime WebSocket updates to active Flutter clients.

## Capabilities

### New Capabilities

- `lorawan-integration`: Production architecture, identity mapping, uplink payload parsing, frame deduplication, downlink command boundaries, gateway tracking, link quality diagnostics (RSSI/SNR), and network server message broker integration for AquaSense LoRaWAN sensor nodes.

### Modified Capabilities

- `node-management`: Extend dynamic sensor node provisioning models to include LoRaWAN identity metadata (DevEUI, JoinEUI, AppKey) and dynamic zone association without hardcoded node or quadrant identifiers.
- `device-diagnostics`: Add LoRaWAN link quality metrics (RSSI, SNR, FCntUp, FCntDown, Gateway EUI) to node health and diagnostic telemetry pipelines.
- `api-integration`: Define backend API endpoints and WebSocket channels for LoRaWAN device telemetry and state updates, isolating Flutter clients from raw network server messages.

## Impact

- **Backend & Network Architecture**: Integrates LoRaWAN Network Server (ChirpStack/TTN) via MQTT message broker into backend ingestion microservices.
- **Data Models**: Updates `SensorNode` and `SensorMeasurement` models in frontend and backend to represent LoRaWAN link metadata (DevEUI, RSSI, SNR, Battery Voltage).
- **Frontend Presentation & Services**: Updates node management and diagnostics UI to display LoRaWAN network health, DevEUI identifiers, and gateway stats without changing existing client-backend security boundaries.
- **Centralized Irrigation**: Guarantees zero direct dependency between LoRaWAN sensor nodes and field pump/valve actuation.

