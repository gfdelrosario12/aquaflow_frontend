## Why

AquaSense dynamic sensor nodes must be discoverable and registrable at runtime. Integrating node scanning and registration into the Field and Node management views allows operators to scan nearby BLE/Wi-Fi or LoRaWAN nodes and bind them to monitoring zones. Registering new nodes dynamically expands the field's monitoring zones (e.g. adding Zone 5, Zone 6, etc.), proving that the field is not limited to a static four-quadrant setup.

## What Changes

- Integrate node scanner/registration action into the Field Monitoring view header and toolbar.
- Support scanning discovered nodes (MAC address, RSSI, hardware model) or entering 64-bit DevEUI/AppKey credentials for LoRaWAN nodes.
- Automatically provision new monitoring zones when a registered node is assigned to a new monitoring zone identifier (e.g. Zone 5 East, Zone 6 West).
- Update `node-management` and `monitoring-zones` specifications to require dynamic node scanning/addition and dynamic zone count expansion.

## Capabilities

### Modified Capabilities

- `node-management`: Require node scanning and registration dialog integration with automatic zone assignment.
- `monitoring-zones`: Mandate dynamic monitoring zone count expansion when new nodes are registered or provisioned.

## Impact

- `lib/features/field/presentation/field_screen.dart`
- `lib/features/nodes/presentation/widgets/node_registration_dialog.dart`
- `lib/features/zones/data/datasources/zone_data_source.dart`
- `lib/features/nodes/data/repositories/node_repository.dart`
