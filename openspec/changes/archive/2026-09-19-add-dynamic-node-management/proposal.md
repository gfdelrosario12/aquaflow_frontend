## Why

AquaSense currently operates with foundational ESP32 node discovery and interval adjustment, but lacks a complete, backend-driven sensor node lifecycle management system. Physical sensor nodes frequently require provisioning, battery servicing, sensor recalibration, physical replacement due to field damage, and eventual decommissioning. 

Without a dynamic, backend-governed node management architecture, adding or swapping physical nodes in an agricultural field requires hardcoded configurations or application redeployments, and replacing a faulty node risks severing historical agronomic measurements from the monitoring zone. This change establishes end-to-end dynamic node lifecycle operations, secure provisioning, identity verification, and non-destructive node replacement so operators can manage arbitrary node topologies entirely through backend APIs and the mobile application.

## What Changes

- **Complete Node Lifecycle State Management**: Support formal lifecycle states (`discovered`, `provisioned`, `active`, `maintenance`, `disabled`, `replaced`, `decommissioned`) with strict transition validation.
- **Node Management Operations**: Implement operator workflows for registering uncommissioned nodes, provisioning device credentials, assigning and reassigning to monitoring zones/points, renaming display labels, putting nodes into maintenance, disabling, and decommissioning.
- **Atomic Node Replacement with Data Preservation**: Support replacing a physical node assigned to a monitoring zone with a new node while strictly preserving historical moisture and water level measurements and maintaining a replacement audit log.
- **Hardware Identity & Secure Provisioning**: Verify unique hardware identity (MAC address / DevEUI and hardware revision) with secure provisioning tokens and challenge verification before granting telemetry uplink rights.
- **Sensor Capabilities Descriptor**: Model node sensor capabilities dynamically (supported transducers, measurement ranges, calibration offsets, multi-depth soil moisture channels).
- **Backend API Boundaries & DTOs**: Define robust REST contracts for node registration, lifecycle state changes, zone assignment, replacement, and metadata updates (`/api/nodes/**`).
- **Role-Based Authorization**: Restrict node provisioning, renaming, reassigning, and decommissioning to users with `operator` or `admin` roles, keeping node details strictly read-only for `viewer` roles.
- **Dynamic Frontend Reflection**: Ensure newly provisioned or replaced nodes immediately update local state and UI components without requiring application restarts or code rebuilds.

## Capabilities

### Modified Capabilities
- `node-management`: Expand requirements to define full sensor node lifecycle state transitions (register, provision, assign, reassign, rename, disable, replace, maintain, decommission), secure device identity verification, atomic node replacement with telemetry preservation, and sensor capability descriptors.
- `api-integration`: Expand API endpoint coverage to include REST services, DTOs, and error mappings for node lifecycle operations (`/api/nodes`, `/api/nodes/register`, `/api/nodes/{id}/provision`, `/api/nodes/{id}/lifecycle`, `/api/nodes/{id}/replace`).

## Impact

- **Domain Models**: Enhance `Esp32Node` and `SensorNode` entities with lifecycle state enums, capability descriptors, provisioning metadata, and replacement tracking.
- **Repositories & Services**: Implement node lifecycle methods in `NodeRepository` and `NodeService` backed by standard REST client endpoints.
- **Presentation**: Update node management UI, dialogs, and diagnostic sheets to expose lifecycle action triggers (maintenance mode, replace node, decommission) guarded by role-based authorization.
- **Testing**: Add unit and widget tests validating lifecycle transitions, atomic replacement invariant preserving historical measurements, and API serialization.

