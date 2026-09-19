## Context

AquaSense currently includes baseline ESP32 node discovery and interval adjustment models (`Esp32Node`, `TransmissionConfig`, `MockNodeRepository`), and decoupled topological entities (`Field`, `MonitoringZone`, `MonitoringPoint`, `SensorNode`, `Sensor`, `Measurement`). However, full lifecycle management operations—such as provisioning, hardware identity challenge verification, maintenance toggles, atomic node replacement, and decommissioning—are not yet wired into the data and presentation layers.

See `proposal.md` for motivation and background.

## Goals / Non-Goals

**Goals:**
- Provide a robust domain lifecycle state machine for sensor nodes: `discovered`, `provisioned`, `active`, `maintenance`, `disabled`, `replaced`, and `decommissioned`.
- Implement atomic node replacement that swaps a physical hardware node at a monitoring zone/point while strictly maintaining historical telemetry continuity under the logical monitoring zone.
- Support secure device registration and identity verification using hardware identifiers (MAC / DevEUI) and commissioning tokens.
- Establish backend REST contracts (`/api/nodes/**`) with typed DTOs and repository integration.
- Implement role-based UI controls permitting `operator` and `admin` roles to execute lifecycle actions, while enforcing read-only presentation for `viewer` roles.
- Ensure runtime dynamic updates without requiring Flutter application rebuilds or manual app restarts.

**Non-Goals:**
- Direct hardware flashing or Bluetooth Low Energy (BLE) pairing over mobile radios (provisioning occurs over backend REST/gateway channels).
- Granting monitoring sensor nodes actuation capabilities (centralized irrigation controller guardrail remains strictly enforced).
- Deleting historical agronomic measurements when a sensor node is decommissioned or replaced.

## Decisions

### Decision 1: Node Lifecycle State Machine & Transition Rules
Physical sensor nodes will follow an explicit lifecycle state machine:
- `discovered`: Uncommissioned node detected by gateway or network.
- `provisioned`: Identity verified, credentials issued, awaiting field deployment.
- `active`: In production, transmitting telemetry mapped to a monitoring zone.
- `maintenance`: Temporarily offline or undergoing battery swap/sensor recalibration; alerts suppressed.
- `disabled`: Administratively suspended due to malfunction or errant sensor readings.
- `replaced`: Terminal state for hardware that has been swapped out for a replacement node.
- `decommissioned`: Permanently retired hardware.

*Alternatives considered*:
- Using ad-hoc booleans (`isOnline`, `isActive`). Rejected because booleans cannot represent distinct phases like `maintenance` vs `disabled` vs `decommissioned`.

### Decision 2: Atomic Node Replacement Architecture
When a physical node is replaced:
1. The target `MonitoringPoint` remains constant.
2. The old node is updated to state `replaced` with `replacedByNodeId` and `replacedAt` audit metadata.
3. The replacement node is assigned to the `MonitoringPoint` and `MonitoringZone`, transitioning to `active` state.
4. Historical measurements remain associated with the `MonitoringPoint` ID, ensuring continuous AWD analytics and charts without data fragmentation.

*Alternatives considered*:
- Overwriting the existing node's MAC address in-place. Rejected because it destroys hardware traceability, warranty logging, and historical failure analysis.
- Creating a completely new monitoring zone. Rejected because it breaks seasonal AWD water depth comparisons for that physical field sector.

### Decision 3: Secure Device Identity Verification
Each physical node possesses a permanent factory hardware identifier (EUI-48 MAC `AA:BB:CC:DD:EE:FF` or EUI-64 `AA:BB:CC:FF:FE:DD:EE:FF`) and a commissioning key.
- Registration requires submitting the hardware ID and commissioning token to `POST /api/nodes/register`.
- The backend validates uniqueness against known inventories before issuing operational tokens.
- Role checks enforce that only `admin` and `operator` user roles can execute lifecycle mutations; `viewer` roles are restricted to read-only views.

### Decision 4: REST API Boundary & DTO Schema
The system introduces standard REST endpoints:
- `GET /api/nodes`: List nodes with optional filtering by field ID, zone ID, and lifecycle state.
- `GET /api/nodes/unassigned`: Retrieve discovered, unassigned nodes available for commissioning.
- `POST /api/nodes/register`: Register an uncommissioned node (`macAddress`, `name`, `hardwareModel`, `firmwareVersion`, `commissioningToken`).
- `POST /api/nodes/{id}/provision`: Provision and bind to a field and zone (`fieldId`, `zoneId`, `coordinates`).
- `POST /api/nodes/{id}/lifecycle`: Transition lifecycle status (`state`, `reason`, `notes`).
- `POST /api/nodes/{id}/replace`: Atomic replacement (`replacementNodeId`, `reason`, `transferCalibration`).
- `PATCH /api/nodes/{id}`: Update mutable metadata (`name`, `transmissionInterval`, `coordinates`).
- `DELETE /api/nodes/{id}`: Decommission node.

## Risks / Trade-offs

- **[Risk] Concurrent node replacement collisions** → *Mitigation*: Backend uses atomic database transactions and version locking; client handles HTTP 409 Conflict with state re-sync.
- **[Risk] Operator mistakenly replacing wrong node** → *Mitigation*: Multi-step confirmation dialog displaying current node telemetry, zone name, and new node hardware ID before executing replacement.
- **[Risk] Stale cached state after lifecycle change** → *Mitigation*: Notifiers immediately invalidate local cache and re-fetch node list upon receiving backend response or real-time lifecycle event.

