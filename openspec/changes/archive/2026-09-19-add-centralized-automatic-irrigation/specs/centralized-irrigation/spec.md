## ADDED Requirements

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

