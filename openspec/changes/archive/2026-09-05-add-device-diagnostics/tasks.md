## 1. Domain Models & Data Layer

- [x] 1.1 Create `DeviceDiagnostic`, `DeviceHealthStatus`, and `DeviceCategory` domain models in `lib/features/diagnostics/domain/models/`.
- [x] 1.2 Implement `DiagnosticsRepository` interface and `MockDiagnosticsRepository` in `lib/features/diagnostics/data/repositories/` providing health telemetry for sensor nodes Q1–Q4, LoRaWAN gateway, and central controller.
- [x] 1.3 Create `DiagnosticsNotifier` state provider in `lib/features/diagnostics/presentation/providers/diagnostics_provider.dart` supporting health polling, category filtering, and state management.

## 2. Presentation UI Screens & Components

- [x] 2.1 Create `DeviceDiagnosticsScreen` in `lib/features/diagnostics/presentation/device_diagnostics_screen.dart` featuring system health overview header, quadrant monitoring nodes (Q1–Q4) card grid, gateway status card, and central controller status card.
- [x] 2.2 Create `DeviceDetailDialog` in `lib/features/diagnostics/presentation/widgets/device_detail_dialog.dart` presenting raw RF metrics (RSSI, SNR), battery voltage/percent, last seen timestamp, and troubleshooting steps.
- [x] 2.3 Add navigation entry points from `SettingsScreen` and `MobileAppShell`.

## 3. Verification & Safety Enforcements

- [x] 3.1 Enforce strict architectural boundaries ensuring Q1–Q4 telemetry nodes display read-only health metrics without quadrant-level irrigation controls.
- [x] 3.2 Add comprehensive unit and widget tests in `test/device_diagnostics_test.dart` testing repository health logic, status badging, scope attribution, and modal interaction.
- [x] 3.3 Execute static analysis (`flutter analyze`) and test suite (`flutter test`) to verify zero static errors and 100% test pass rate.

