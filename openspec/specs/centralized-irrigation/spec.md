# centralized-irrigation Specification

## Purpose

Provides centralized irrigation system models, field-wide operational status abstractions, real-time telemetry dashboards, interactive control command pipelines, safety confirmation flows, authorization checks, and fault resilience for AquaSense.

## Requirements

### Requirement: Centralized field irrigation model
The application MUST model physical field irrigation as a single centralized system serving the entire field, distinct from individual telemetry monitoring zones.

#### Scenario: Displaying irrigation status
- **WHEN** the user views irrigation information in the Control or Home screen
- **THEN** system operational status (such as Main Pump state, System Mode, and Flow Rate) is presented as a unified field-wide entity.

### Requirement: Foundation-level control abstraction
The application MUST represent centralized control state models while isolating UI actions from production pump/valve hardware execution during the foundation phase.

#### Scenario: Interacting with centralized control screen
- **WHEN** the user navigates to the Control screen
- **THEN** centralized field-level system status and simulated override abstractions are presented without invoking actual pump/valve hardware drivers.

### Requirement: Real-time centralized irrigation status display
The system SHALL present a comprehensive operational status dashboard for the single centralized irrigation system on the Control screen, including main pump status (Off, Pumping, Fault), main valve status (Closed, Open, Transitioning), controller state (Online, Offline, Local Override), current irrigation state (Idle, Irrigating, Command Pending, Error), start timestamp, elapsed/remaining duration, last command result, and fixed target indicator (`ENTIRE FIELD`).

#### Scenario: Viewing real-time centralized system operational status
- **WHEN** the user opens the Control screen
- **THEN** the system displays real-time telemetry for the main pump, main valve, central controller connectivity, current irrigation state, active duration, last command outcome, and fixed target `ENTIRE FIELD`.

### Requirement: Safe authorized irrigation command execution
The system SHALL require an authenticated session, explicit irrigation authorization, and a two-step confirmation dialog with safety warnings before dispatching `Start Field Irrigation` or `Stop Field Irrigation` commands through the backend API to the central controller. Commands MUST target only `ENTIRE FIELD` and MUST NOT address Q1–Q4 actuators.

#### Scenario: Requesting field irrigation activation with confirmation
- **WHEN** an authorized authenticated user taps the "Start Field Irrigation" action on the Control screen
- **THEN** the system presents a confirmation modal displaying field impact, safety warnings, and target confirmation before sending the start command to the backend irrigation endpoint.

#### Scenario: Blocking unauthorized control command attempts
- **WHEN** a user without irrigation control authorization attempts to execute a Start or Stop command
- **THEN** the system blocks command dispatch and displays an unauthorized access warning notification.

#### Scenario: Unauthenticated control command attempt
- **WHEN** an unauthenticated session attempts to dispatch a Start or Stop command
- **THEN** the system blocks the command, clears or denies the action, and directs the user to re-authenticate without exposing zone-level irrigation controls.

### Requirement: Command pipeline coordination and concurrency control
The system SHALL manage control commands through a multi-tier pipeline (Mobile App → Backend API → LoRaWAN/Messaging Gateway → Central Controller → Hardware Actuators) and strictly prevent duplicate, conflicting, or concurrent command dispatches while a command is in-flight. The mobile application MUST NOT open direct LoRaWAN, radio, or gateway hardware connections. Failed or timed-out start/stop commands MUST NOT be automatically replayed by the client.

#### Scenario: Preventing duplicate or contradictory commands during dispatch
- **WHEN** a command is in-flight or pending controller acknowledgment
- **THEN** the system disables control action triggers and rejects conflicting command requests until the active command completes or times out.

#### Scenario: Command failure is not auto-replayed
- **WHEN** a start or stop command fails or times out after submission
- **THEN** the system returns a typed failure, leaves the operator to explicitly retry if appropriate, and does not silently resubmit the same command.

### Requirement: Central controller and communication fault resilience
The system SHALL detect, model, and gracefully display controller fault conditions including command timeout, controller offline state, stale status telemetry, command execution failure, local manual/emergency stop override, and messaging link failure.

#### Scenario: Handling central controller offline or communication timeout
- **WHEN** the central controller loses connectivity or fails to acknowledge a dispatched command within the timeout window
- **THEN** the system transitions the control interface to a fault state, flags telemetry as stale or unconfirmed, and presents clear remediation guidance.

#### Scenario: Handling local emergency stop or manual override
- **WHEN** a local physical emergency stop or manual override occurs at the central controller
- **THEN** the system immediately updates the displayed state to Emergency Override, disables remote command triggers, and highlights the manual intervention alert.

### Requirement: Strict separation of irrigation recommendations from active control
The system SHALL clearly distinguish automated field-level AWD analytics recommendations (such as reflood suggested) from confirmed active hardware irrigation status, and strictly enforce that no quadrant-level (Q1–Q4) irrigation control interface exists.

#### Scenario: Presenting recommendation distinct from active hardware control
- **WHEN** an AWD analytics recommendation suggests field irrigation
- **THEN** the system displays the recommendation as an advisory insight, requiring explicit manual user action on the Central Control screen to initiate actual field-wide irrigation.

### Requirement: Security-clear irrigation command error handling
The system SHALL present distinct user-safe outcomes for authentication failure, authorization denial, timeout, connectivity loss, and controller rejection of irrigation commands, without revealing secrets or offering Q1–Q4 zone irrigation remediation.

#### Scenario: Irrigation command times out
- **WHEN** the backend or controller does not acknowledge a dispatched field irrigation command within the timeout window
- **THEN** the Control UI enters a fault/unconfirmed state with remediation guidance and does not mark the command as successfully applied.

### Requirement: Centralized automatic irrigation supervisor state machine
The system SHALL maintain a supervisor state machine for field-level automatic irrigation control transitioning between `disabled`, `standby`, `evaluating`, `pendingAck`, `irrigating`, `cooldown`, and `faultLocked`. Monitoring zones and sensor nodes MUST NOT independently execute or bypass this supervisor.

#### Scenario: Normal automatic cycle execution
- **WHEN** the system is in `standby` and scheduled or event-driven evaluation confirms AWD reflood conditions are met
- **THEN** the supervisor transitions to `evaluating`, verifies pre-flight safety interlocks, dispatches the field start command, transitions to `pendingAck`, and enters `irrigating` upon controller acknowledgement.

#### Scenario: Transition to cooldown after automated irrigation
- **WHEN** an automated irrigation cycle reaches target fill volume or maximum duration
- **THEN** the supervisor dispatches a field stop command, transitions to `cooldown`, and prohibits any subsequent automated trigger for a configurable cooldown duration (minimum 60 minutes) to allow water infiltration and soil sensor stabilization.

#### Scenario: Transition to fault locked state on hardware or protocol failure
- **WHEN** the central controller reports a pump hardware fault, valve blockage, communication timeout, or sensor anomaly during an automated cycle
- **THEN** the supervisor dispatches a fail-safe emergency stop, transitions to `faultLocked`, sounds critical system alerts, and prevents further automated cycles until explicitly cleared by an authorized operator.

### Requirement: Autonomous decision and pre-flight safety interlock verification
The system SHALL verify all pre-flight safety interlocks prior to dispatching an automated field irrigation command, including controller online connectivity, absence of active hardware faults, non-stale telemetry, confidence score meeting the minimum threshold ($\ge 0.75$), current local time within allowed irrigation hours, rain delay inactivity, and duration capped by an absolute safety ceiling.

#### Scenario: Pre-flight check passes
- **WHEN** AWD analysis recommends reflood with high confidence, no active faults exist, controller is online, and time is within allowed operating window
- **THEN** pre-flight verification succeeds and the automated start command is prepared.

#### Scenario: Pre-flight check inhibited by weather or rain delay
- **WHEN** rain is actively detected or a rain delay forecast window is active
- **THEN** automated irrigation is inhibited, the supervisor remains in `standby`, and the reason is recorded in the evaluation log.

#### Scenario: Pre-flight check inhibited by conflicting zone conditions
- **WHEN** AWD analysis indicates high zone water depth disparity where drying zones need water but others remain flooded
- **THEN** automated irrigation is inhibited, an alert is raised advising physical inspection, and automated pumping is blocked.

### Requirement: Reliable command execution and acknowledgement lifecycle
The system SHALL execute automated irrigation commands through message broker/LoRaWAN gateway to the central controller with correlation IDs, timeout supervision (maximum 30 seconds), retry limits (maximum 2 retries with exponential backoff), and fail-safe hardware shutdown on communication loss.

#### Scenario: Controller acknowledges start command within timeout
- **WHEN** the backend dispatches a start command with correlation ID `cmd-<uuid>` and the controller replies with `ACK` and status `pumping` within 30 seconds
- **THEN** the command is marked active and the supervisor state transitions to `irrigating`.

#### Scenario: Controller fails to acknowledge start command
- **WHEN** no acknowledgement is received from the central controller after 2 retries
- **THEN** the command is aborted, no further retries are attempted, the supervisor transitions to `faultLocked`, and an alert notification is emitted.

### Requirement: Explicit automation actor attribution and audit trail
The system SHALL record all irrigation events in an immutable audit trail, explicitly distinguishing automated triggers (`actor: system/auto-awd`) from manual human operations (`actor: user/<userId>`), and storing triggering rationales, sensor telemetry snapshots, target duration, and execution outcome.

#### Scenario: Logging an automated irrigation trigger
- **WHEN** an automated irrigation cycle is initiated by the AWD supervisor
- **THEN** the audit log records an entry with actor `system/auto-awd`, the triggering AWD depth, confidence rating, active crop stage, and target duration.

#### Scenario: Logging a manual operator override
- **WHEN** an authenticated operator manually aborts an in-progress automated irrigation cycle
- **THEN** the audit log records an entry with actor `user/<userId>`, manual override type `operator_abort`, remaining duration, and reason.

### Requirement: Operator manual override and safety lockout recovery
The system SHALL allow authorized human operators to override automatic irrigation at any time, toggle automation mode (`enabled` / `disabled`), and review or clear `faultLocked` states after performing physical field inspection.

#### Scenario: Operator aborts active automated irrigation
- **WHEN** an authorized operator clicks "Emergency Stop" or "Stop Field Irrigation" on an automated cycle
- **THEN** the system immediately sends a high-priority stop command to the central controller, cancels the automated cycle, transitions to `standby` (or `disabled`), and alerts the backend.

#### Scenario: Operator clears fault lockout
- **WHEN** an operator with admin or operator privileges acknowledges and clears a resolved fault lockout
- **THEN** the system verifies controller health and transitions from `faultLocked` to `standby`.