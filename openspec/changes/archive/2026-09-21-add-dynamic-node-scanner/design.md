## Context

To make sensor node management and dynamic field expansion interactive, operators need a direct node scanner/adder workflow on the Field screen. Scanning or registering a new node can assign it to an existing zone or create a new monitoring zone (e.g. Zone 5, Zone 6), proving that monitoring points and zone counts are non-static and fully dynamic.

## Goals / Non-Goals

**Goals:**
- Add an "Add / Scan Node" action button on `FieldScreen` header toolbar.
- When tapped, fetch discovered nodes via `NodeRepository.fetchDiscoveredNodes()` and launch `NodeRegistrationDialog`.
- Support registering Wi-Fi/Bluetooth ESP32 or LoRaWAN nodes with dynamic zone assignment.
- Ensure `MockZoneDataSource` dynamically generates new monitoring zone instances when nodes are registered for new zone IDs (e.g. `zone-dynamic-east` -> Zone 5), updating both Field and Home dashboard representations.

**Non-Goals:**
- Physical hardware Bluetooth device pairing outside Flutter mock/REST API boundaries.

## Decisions

### 1. Header Toolbar Node Scanner Action in FieldScreen
- **Decision:** Add an `IconButton` / `AquaButton` for node registration in `FieldScreen._buildHeader()`.
- **Rationale:** Gives operators immediate access to scan and register new nodes without navigating away from the field view.

### 2. Dynamic Zone Creation in Mock Data Sources
- **Decision:** When `NodeRegistrationRequestDto` specifies a zone ID that doesn't exist yet, `MockZoneDataSource` synthesizes a new `MonitoringZone` instance with default/initial sensor metrics.
- **Rationale:** Demonstrates runtime field expansion when new sensor nodes are deployed.

## Risks / Trade-offs

- **[Risk] State mismatch between NodeRepository and ZoneRepository** → **Mitigation:** Refresh both `_loadZones()` and `_nodeRepository.fetchNodes()` upon successful registration in `FieldScreen`.
