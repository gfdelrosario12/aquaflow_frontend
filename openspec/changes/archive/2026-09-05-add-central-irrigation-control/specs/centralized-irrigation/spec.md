## ADDED Requirements

### Requirement: Real-time centralized irrigation status display
The system SHALL present a comprehensive operational status dashboard for the single centralized irrigation system on the Control screen, including main pump status (Off, Pumping, Fault), main valve status (Closed, Open, Transitioning), controller state (Online, Offline, Local Override), current irrigation state (Idle, Irrigating, Command Pending, Error), start timestamp, elapsed/remaining duration, last command result, and fixed target indicator (`ENTIRE FIELD`).

#### Scenario: Viewing real-time centralized system operational status
- **WHEN** the user opens the Control screen
- **THEN** the system displays real-time telemetry for the main pump, main valve, central controller connectivity, current irrigation state, active duration, last command outcome, and fixed target `ENTIRE FIELD`.

### Requirement: Safe authorized irrigation command execution
The system SHALL require explicit user authorization and a two-step confirmation dialog with safety warnings before dispatching `Start Field Irrigation` or `Stop Field Irrigation` commands to the central controller.

#### Scenario: Requesting field irrigation activation with confirmation
- **WHEN** an authorized user taps the "Start Field Irrigation" action on the Control screen
- **THEN** the system presents a confirmation modal displaying field impact, safety warnings, and target confirmation before sending the start command.

#### Scenario: Blocking unauthorized control command attempts
- **WHEN** a user without irrigation control authorization attempts to execute a Start or Stop command
- **THEN** the system blocks command dispatch and displays an unauthorized access warning notification.

### Requirement: Command pipeline coordination and concurrency control
The system SHALL manage control commands through a multi-tier pipeline (Mobile App → Backend API → LoRaWAN/Messaging Gateway → Central Controller → Hardware Actuators) and strictly prevent duplicate, conflicting, or concurrent command dispatches while a command is in-flight.

#### Scenario: Preventing duplicate or contradictory commands during dispatch
- **WHEN** a command is in-flight or pending controller acknowledgment
- **THEN** the system disables control action triggers and rejects conflicting command requests until the active command completes or times out.

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

