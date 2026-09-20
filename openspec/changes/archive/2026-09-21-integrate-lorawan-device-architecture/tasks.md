## 1. Domain & State Models

- [x] 1.1 Create `LoRaWANIdentity` and `LoRaWANLinkQuality` domain models in `lib/features/nodes/domain/` with DevEUI, JoinEUI, AppKey, FCntUp, FCntDown, and RSSI/SNR fields.
- [x] 1.2 Update `SensorNode` and `SensorMeasurement` models to handle optional `LoRaWANIdentity` metadata and server-normalized UTC timestamps.
- [x] 1.3 Create Riverpod providers for LoRaWAN device registration and state tracking in `lib/features/nodes/presentation/providers/`.

## 2. API Integration & Realtime Data Layer

- [x] 2.1 Implement `LoRaWANApiService` client and DTO serialization for `/api/lorawan/devices`, `/api/lorawan/telemetry`, and downlink command queuing.
- [x] 2.2 Wire backend WebSocket channel handling (`lorawanTelemetry` and `lorawanDeviceStatus`) into `RealtimeCoordinator` to stream decoded frames directly to Flutter state.

## 3. UI Presentation & Diagnostics Integration

- [x] 3.1 Update `NodeManagementScreen` and node registration dialog to accept 64-bit DevEUI and AppKey credentials without hardcoding node IDs or quadrant codes.
- [x] 3.2 Update `DeviceDiagnosticsScreen` to display LoRaWAN link quality cards (RSSI, SNR, FCntUp/FCntDown, Gateway ID, battery voltage) for registered sensor nodes.
- [x] 3.3 Add downlink command queued indicator badge for transmission interval reconfigurations in node detail view.

## 4. Architectural Verification & Isolation Interlocks

- [x] 4.1 Enforce client-side architectural interlock ensuring zero direct radio, LoRaWAN, or gateway hardware connections are opened by the Flutter application.
- [x] 4.2 Verify complete isolation between LoRaWAN sensor nodes/monitoring zones and centralized field pump/valve controls.

## 5. Testing & Static Analysis

- [x] 5.1 Add unit tests for `LoRaWANIdentity` serialization, frame deduplication metadata parsing, and Riverpod state transitions.
- [x] 5.2 Add widget tests for node registration with DevEUI, LoRaWAN diagnostics inspector, and downlink status badges.
- [x] 5.3 Run `dart analyze` and full Flutter test suite to verify 0 errors and 100% test pass rate.

