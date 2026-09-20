## Context

See `proposal.md` for motivation and system requirements.

The AquaSense platform requires a production architecture for integrating physical LoRaWAN end-devices (ESP32 microcontrollers with RFM95W radio transceivers) into the field monitoring stack. The system involves six key components:
1. **Flutter Mobile/Web Application**: User interface for field operators and managers.
2. **Backend API & Realtime Layer**: REST API and WebSocket coordinator for client interactions.
3. **Message Broker**: MQTT/AMQP event bus bridging network servers and backend microservices.
4. **LoRaWAN Network Server (LNS)**: ChirpStack or The Things Network (TTN) managing device joins, MAC commands, and frame validation.
5. **LoRaWAN Gateway**: Multi-channel outdoor gateways receiving sub-GHz RF signals and forwarding IP packets to LNS.
6. **Distributed Sensor Nodes**: Dynamic ESP32/RFM95W nodes deployed in agricultural monitoring zones.
7. **Centralized Field Irrigation Controller**: Dedicated field-wide controller handling pumps and valves.

## Goals / Non-Goals

**Goals:**
- Define the end-to-end data flow: `Flutter` <-> `Backend API/WS` <-> `Message Broker` <-> `LNS` <-> `LoRaWAN Gateway` <-> `Sensor Nodes`.
- Strictly isolate Flutter application clients from direct radio/wireless communication with LoRaWAN end-devices or gateways.
- Maintain complete separation between telemetry-only LoRaWAN sensor nodes and centralized field irrigation pump/valve controls.
- Provide dynamic identity mapping (`devEui` -> `nodeId` -> `zoneId`) supporting arbitrary node scaling without hardcoding node IDs or quadrant codes (Q1/Q2/Q3/Q4).
- Specify uplink payload decoding, multi-gateway frame deduplication (1000ms window), frame counter (`fCntUp`) validation, and UTC timestamp normalization.
- Define Class A downlink command queuing (`fCntDown`) and status lifecycle.
- Specify real-time WebSocket distribution of LoRaWAN telemetry and connectivity diagnostics to Flutter clients.

**Non-Goals:**
- Direct peer-to-peer or local radio communication between Flutter mobile apps and LoRaWAN nodes.
- Direct actuation of pumps or valves by individual LoRaWAN sensor nodes or monitoring zones.
- Hardcoding fixed quadrant identifiers or static node counts.

## Architecture & System Topology

```
+-----------------------------------------------------------------------------------+
|                              FLUTTER APPLICATION                                  |
|                 (Android / Web Client - Presentation & State)                     |
+------------------------------------------+----------------------------------------+
                                           | HTTPS REST / WSS WebSocket
                                           v
+-----------------------------------------------------------------------------------+
|                        BACKEND API & REALTIME SERVICE                             |
|  - Telemetry Ingestion Service      - Dynamic Identity & Zone Mapping Registry    |
|  - Payload Decoder & Normalizer     - Frame Deduplicator & FCnt Validator         |
|  - Realtime WebSocket Coordinator   - AWD Analysis Engine (Centralized)         |
+---------------------+------------------------------------+------------------------+
                      | MQTT / AMQP                        | Dedicated REST / Bus
                      v                                    v
+-------------------------------+             +----------------------------------+
|  MESSAGE BROKER (MQTT/AMQP)   |             |  CENTRAL IRRIGATION CONTROLLER   |
+---------------+---------------+             |  - Main Pump & Valve Hardware    |
                | MQTT topics                 |  - Field-Wide Execution Scope    |
                v                             +----------------------------------+
+-------------------------------+
| LORAWAN NETWORK SERVER (LNS)  |
| (ChirpStack / TTN)            |
+---------------+---------------+
                | Semtech UDP / Basic Station
                v
+-------------------------------+
|       LORAWAN GATEWAY         |
| (Multi-channel Outdoor RF)    |
+---------------+---------------+
                | LoRa RF (Sub-GHz)
                v
+-------------------------------+
|   DISTRIBUTED SENSOR NODES    |
| (ESP32 / RFM95W End-Devices)  |
+-------------------------------+
```

## Decisions

### Decision 1: Architecture Layering & Strict Client Isolation
- **Choice**: The Flutter application communicates *exclusively* with the Backend API and WebSocket layer using secure HTTPS/WSS protocols. The backend interfaces with the Message Broker / LNS.
- **Rationale**: Isolates mobile clients from radio hardware complexities, LNS credentials, and network protocols. Ensures uniform security enforcement, role-based access control, and centralized audit logging.
- **Alternatives Considered**: Direct WebSockets from Flutter to LNS (rejected: exposes LNS API keys and bypasses domain security/auditing).

### Decision 2: Message Broker Integration Pattern
- **Choice**: Backend services subscribe to MQTT topics published by the LNS (e.g. `application/+/device/+/event/up`) and publish downlinks to `application/+/device/+/command/down`.
- **Rationale**: Decouples the LNS from backend processing, supports sub-second event ingestion, and enables resilient message queuing during temporary backend service restarts.
- **Alternatives Considered**: LNS HTTP Webhooks (rejected: higher overhead, less resilient under burst uplink conditions).

### Decision 3: Multi-Gateway Frame Deduplication & Metric Selection
- **Choice**: The backend deduplication pipeline buffers incoming frames by `devEui` + `fCntUp` for 1000ms. The frame received with the highest SNR is chosen for telemetry payload extraction, while gateway reception stats (RSSI/SNR per gateway) are recorded for network diagnostics.
- **Rationale**: Multiple gateways frequently pick up the same RF transmission. Processing every duplicate would corrupt telemetry history and artificially inflate measurement counts.
- **Alternatives Considered**: Gateway-level deduplication in LNS only (rejected: backend needs individual gateway RSSI/SNR metrics for diagnostic visibility).

### Decision 4: Dynamic Identity & Zone Binding Model
- **Choice**: Implement a dynamic mapping table (`dev_eui` -> `node_id` -> `zone_id` -> `field_id`). Node registration accepts `devEui`, `joinEui`, `appKey`, display label, and target `zoneId`.
- **Rationale**: Completely removes hardcoded node IDs (e.g. `NODE-01`) or fixed quadrant labels (`Q1`-`Q4`). Supports arbitrary field topologies and dynamic node replacements.
- **Alternatives Considered**: Hardcoded node array (rejected: fails user requirement for dynamic multi-zone agricultural scaling).

### Decision 5: Class A Downlink Command Queuing
- **Choice**: Downlink requests (e.g. changing transmission interval or calibration offsets) are queued in the LNS downlink queue. The backend tracks command status (`queued`, `transmitted`, `acknowledged`, `expired`).
- **Rationale**: LoRaWAN Class A end-devices only open receive windows immediately following an uplink transmission. Commands cannot be pushed synchronously on demand.
- **Alternatives Considered**: Class C continuous listening (rejected: ESP32 battery-powered nodes require Class A sleep cycles to maintain battery life).

## Data Models & Interfaces

### 1. LoRaWAN Node Identity Domain Model (`lib/features/nodes/domain/lorawan_identity.dart`)
```dart
class LoRaWANIdentity {
  final String devEui;        // 64-bit Hex string (EUI-64)
  final String joinEui;       // 64-bit Hex string (AppEUI)
  final String? devAddr;      // 32-bit Hex string (active session)
  final int fCntUp;           // Last uplink frame counter
  final int fCntDown;         // Last downlink frame counter
  final String lastGatewayId; // Gateway EUI that received best signal
  final double lastRssi;      // RSSI in dBm
  final double lastSnr;       // SNR in dB
  final DateTime? lastSeen;   // Server-normalized UTC timestamp
}
```

### 2. LoRaWAN Telemetry Metadata (`lib/features/diagnostics/domain/lorawan_diagnostics.dart`)
```dart
class LoRaWANDeviceDiagnostics {
  final String devEui;
  final String nodeName;
  final String zoneId;
  final String zoneName;
  final LoRaWANLinkQuality linkQuality;
  final int fCntUp;
  final int fCntDown;
  final String gatewayId;
  final double batteryVoltage;
  final int batteryPercentage;
  final DeviceHealthStatus healthStatus;
  final DateTime lastSeen;
}
```

## Risks / Trade-offs

- **[Risk] RF signal degradation or packet loss in dense crop canopy** → *Mitigation*: Track RSSI/SNR metrics in device diagnostics, support Adaptive Data Rate (ADR), and flag node status as `degraded` if heartbeats miss 2 intervals or `stale` after 3 missed intervals.
- **[Risk] Out-of-order frame counters (`fCntUp`) due to network retransmissions** → *Mitigation*: Enforce strictly increasing frame counter validation per device session; log replay warnings for invalid counters.
- **[Risk] User expectation of instant downlink execution** → *Mitigation*: Flutter UI displays explicit "Downlink Queued (Will apply on next node uplink)" status badges for pending configuration changes.

## Migration Plan

1. **Domain & Data Layer**: Implement `LoRaWANIdentity`, `LoRaWANDeviceDiagnostics`, and update `SensorNode` / `SensorMeasurement` models to handle optional LoRaWAN link metadata.
2. **API & Realtime Integration**: Add REST endpoints `/api/lorawan/devices` and WebSocket topic listeners for `lorawanTelemetry` events.
3. **UI & Diagnostics**: Update `NodeManagementScreen` to support DevEUI provisioning and update `DeviceDiagnosticsScreen` to display LoRaWAN link quality cards.
4. **Verification**: Run `dart analyze` and Flutter test suite to verify zero regressions across existing node management and diagnostics capabilities.

