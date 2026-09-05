## 1. Domain Models & Control Pipeline Abstractions

- [x] 1.1 Create centralized control domain models (`CentralControllerState`, `PumpStatus`, `MainValveStatus`, `ControlCommand`, `ControlCommandResult`) in `lib/features/control/domain/models/`.
- [x] 1.2 Implement `ControlRepository` interface and `MockControlRepository` in `lib/features/control/data/repositories/` simulating backend API and LoRaWAN pipeline execution.
- [x] 1.3 Create Riverpod state provider and notifier managing control state transitions, in-flight command concurrency locks, and fault handling timers.

## 2. Interactive Control UI & Safety Confirmation

- [x] 2.1 Enhance `ControlScreen` in `lib/features/control/presentation/control_screen.dart` to display real-time pump, main valve, controller connectivity, current irrigation state, start time, duration, last command result, and fixed `ENTIRE FIELD` target indicator.
- [x] 2.2 Create `ControlConfirmationDialog` providing explicit safety warnings, duration selection for start commands, target verification, and user authorization validation.
- [x] 2.3 Implement fault, warning, and alert UI banners handling controller offline, command timeout, command execution failure, stale telemetry, and physical emergency stop/local override states.

## 3. Verification & Safety Enforcements

- [x] 3.1 Enforce strict architectural boundaries ensuring Q1–Q4 telemetry nodes are purely read-only without zone-level irrigation controls, and distinguish automated AWD recommendations from active irrigation.
- [x] 3.2 Add comprehensive unit and widget tests in `test/central_control_test.dart` verifying state machine transitions, concurrency lock prevention, confirmation modal behavior, and fault presentation states.
- [x] 3.3 Run static analysis (`flutter analyze`) and execute test suite (`flutter test`) to verify zero static errors and 100% test pass rate.

