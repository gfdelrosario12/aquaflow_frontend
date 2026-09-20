## Why

AquaSense currently manages centralized irrigation through automatic AWD analysis and simple hardware state triggers, but operators lack a dedicated, secure, and isolated Manual Control interface for emergency flushes, canal maintenance, manual pulse reflooding, or system overrides. Furthermore, manual actions must be strictly separated from automatic sensor-driven execution to prevent state conflicts, must enforce explicit multi-step authorization and confirmation, must operate strictly at the field level (`ENTIRE FIELD`), and must create immutable audit events attributed to the authenticated human account.

## What Changes

- **Dedicated Manual Control Tab/Interface**: Introduce a dedicated Manual Control interface/tab in the AquaFlow Flutter application separate from the automatic supervisor and monitoring screens.
- **Strict Field-Level Actuation Scope**: Guarantee that manual start, stop, pulse, and override operations target the field's centralized irrigation system (`ENTIRE FIELD`). Zone- or quadrant-level actuation buttons are strictly prohibited.
- **Explicit Authorization and Confirmation UX**: Enforce `operator` or `fieldAdmin` role checks before enabling manual controls. Require confirmation dialogs capturing optional override rationale and target runtime limits before dispatching manual commands.
- **Automatic / Manual Supervisor State Machine**: Define deterministic state transitions when manual intervention occurs (`standby` → `manualOverride` → `cooldown` → `standby`). Define automatic resumption policies and cooldown timers following manual override completion or emergency stop.
- **Tamper-Resistant Account Audit Emission**: Every manual command dispatch (start, stop, override, duration change) must emit a unified `AccountAuditEvent` identifying the authenticated account (`user/<userId>`), command target, timestamp, result outcome, and rationale.

## Capabilities

### New Capabilities
- `manual-irrigation-control`: Dedicated manual irrigation control interface, confirmation UX, manual override state lifecycle, and field-wide pump/valve control.

### Modified Capabilities
- `centralized-irrigation`: Define manual override supervisor state transitions, manual priority over automatic rules, and auto-resumption rules.
- `user-authentication`: Require explicit `operator` or `fieldAdmin` role authorization for manual irrigation command dispatch.
- `account-audit-logging`: Emit unified `AccountAuditEvent` records for all manual irrigation commands with explicit human actor attribution.

## Impact

- **Domain Models & State**: New `ManualIrrigationCommand`, `ManualOverrideState`, and `ManualControlNotifier` in `lib/features/irrigation/domain/` and `presentation/`.
- **UI Components**: Dedicated `ManualControlScreen` / tab with real-time telemetry card, duration selector, confirmation dialog with rationale input, and emergency stop interlock button.
- **API & Repositories**: Integration with `/api/irrigation/start`, `/api/irrigation/stop`, `/api/irrigation/manual-override` endpoints and `IrrigationRepository`.
- **Audit Logging**: Emits `AccountAuditEvent` records via `AccountAuditRepository` with actor attribution.
- **Real-Time Integration**: Synchronizes manual override state across all active client sessions via `RealtimeCoordinator`.

