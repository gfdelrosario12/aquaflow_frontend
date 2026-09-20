## 1. Domain & State Models

- [x] 1.1 Create `ManualIrrigationCommand`, `ManualOverrideState`, and `ManualControlState` domain models in `lib/features/irrigation/domain/` with strict `ENTIRE FIELD` targeting.
- [x] 1.2 Implement Riverpod `ManualControlNotifier` and state management logic for manual override supervisor state transitions in `lib/features/irrigation/presentation/providers/`.

## 2. Data Layer & API Integration

- [x] 2.1 Update `IrrigationRepository` and HTTP client methods to support manual start, manual stop, override duration update, and emergency stop backend endpoints.
- [x] 2.2 Wire backend telemetry stream and WebSocket/Realtime update handling to synchronize manual control states across application sessions.

## 3. Presentation & User Interface

- [x] 3.1 Implement `ManualControlScreen` dedicated tab with real-time field hardware telemetry card, target scope badge (`ENTIRE FIELD`), and duration selector widget.
- [x] 3.2 Implement `ManualControlConfirmationDialog` requiring explicit confirmation, duration selection, and optional override rationale input.
- [x] 3.3 Implement high-priority, uninhibited `EmergencyStopButton` interlock widget on the Manual Control screen.
- [x] 3.4 Integrate navigation entry point for Manual Control tab in main mobile app shell/tab bar.

## 4. Audit Integration & Authorization Enforcement

- [x] 4.1 Enforce `operator` / `fieldAdmin` role check in `ManualControlNotifier` and UI action handlers to block unauthorized users (`viewer`).
- [x] 4.2 Connect `AccountAuditRepository` to dispatch `AccountAuditEvent` records for all manual start, stop, override, and emergency stop actions with explicit human account attribution.

## 5. Testing & Verification

- [x] 5.1 Add unit tests for `ManualControlNotifier`, domain state machine transitions, and target payload validation.
- [x] 5.2 Add widget tests for `ManualControlScreen`, confirmation modal, emergency stop interlock, and authorization role gating.
- [x] 5.3 Run `dart analyze` and full test suite to verify 0 errors and 100% test pass rate.

