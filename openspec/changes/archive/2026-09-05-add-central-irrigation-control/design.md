## Context

AquaSense models field telemetry across four independent monitoring zones (Q1–Q4) while field irrigation is served exclusively by a single centralized controller, main pump, and main valve. See `proposal.md` for motivation. The frontend needs a robust, interactive control layer on `ControlScreen` reflecting the physical multi-tier execution path (Mobile App → Backend REST/GraphQL API → Messaging/LoRaWAN Gateway → Central Controller → Pump/Valve Actuators).

## Goals / Non-Goals

**Goals:**
- Provide full interactive centralized control (`Start Field Irrigation`, `Stop Field Irrigation`) with confirmation modals and safety disclaimers.
- Render real-time centralized system metrics: Pump status, Main Valve status, Central Controller status, active irrigation state, start timestamp, elapsed/remaining duration, last command status, and fixed target (`ENTIRE FIELD`).
- Enforce role-based authorization and prevent duplicate or contradictory in-flight commands.
- Implement comprehensive fault and state management: command timeout, controller offline, stale telemetry, execution failure, local manual emergency stop, and communication error.
- Enforce strict single-system isolation: ensure Q1–Q4 monitoring zones remain purely read-only without irrigation controls.

**Non-Goals:**
- Direct physical hardware driver integration (hardware actions are abstracted via `ControlRepository` and mock gateway services for API readiness).
- Quadrant-level or zone-specific valve control (strictly unsupported by physical field architecture).
- Multi-field switching (the app is scoped to one centralized rice field).

## Decisions

### 1. Control Domain & Pipeline Architecture
- **Decision**: Define immutable domain models: `CentralControllerStatus` (Enums: `online`, `offline`, `emergencyStop`), `PumpStatus` (`off`, `pumping`, `fault`), `MainValveStatus` (`closed`, `open`, `transitioning`), `ControlCommand` (type: `startIrrigation` / `stopIrrigation`, target: `entireField`, timestamp, requestedBy), and `ControlCommandResult` (`acknowledged`, `inProgress`, `completed`, `timedOut`, `rejected`, `failed`).
- **Rationale**: Clean separation between raw telemetry status and active command execution guarantees API compatibility when connecting real LoRaWAN gateways.

### 2. Safety Confirmation & Authorization Modal
- **Decision**: Implement `ControlConfirmationDialog` requiring explicit user confirmation, displaying target scope (`ENTIRE FIELD`), duration selection (if starting), safety disclaimers, and user authorization validation.
- **Rationale**: Prevents accidental pump triggers and ensures operators understand irrigation will apply to the entire field.

### 3. In-Flight Command Concurrency Lock
- **Decision**: The state notifier sets `isCommandPending = true` during command dispatch, disabling all trigger buttons on the UI and ignoring duplicate/contradictory command attempts.
- **Rationale**: Prevents race conditions and messaging queue flood on LoRaWAN networks.

### 4. Fault Handling State Machine
- **Decision**: Model system UI state via a unified Riverpod state provider `centralControlProvider` exposing states: `idle`, `irrigating`, `commandPending`, `controllerOffline`, `commandTimeout`, `commandFailed`, `emergencyStop`, and `staleTelemetry`.
- **Rationale**: Ensures intuitive visual indicators (alerts, badges, banners) for all hardware and network failure modes.

## Risks / Trade-offs

- **[Risk: High LoRaWAN transmission latency]** → *Mitigation*: Introduce explicit "Command Pending" state with countdown progress indicator and 30-second acknowledgment timeout.
- **[Risk: Local manual override at physical pump site]** → *Mitigation*: Central controller telemetry includes `emergencyStop` flag; when active, remote control triggers are locked out with an active alert banner.
- **[Risk: User confusion between AWD recommendation and active irrigation]** → *Mitigation*: Display explicit recommendation banner with direct link to Control screen; Control screen displays confirmed active hardware state rather than advisory recommendations.

