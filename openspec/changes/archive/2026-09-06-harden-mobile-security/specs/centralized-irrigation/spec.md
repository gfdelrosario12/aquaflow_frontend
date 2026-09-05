## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Security-clear irrigation command error handling
The system SHALL present distinct user-safe outcomes for authentication failure, authorization denial, timeout, connectivity loss, and controller rejection of irrigation commands, without revealing secrets or offering Q1–Q4 zone irrigation remediation.

#### Scenario: Irrigation command times out
- **WHEN** the backend or controller does not acknowledge a dispatched field irrigation command within the timeout window
- **THEN** the Control UI enters a fault/unconfirmed state with remediation guidance and does not mark the command as successfully applied.
