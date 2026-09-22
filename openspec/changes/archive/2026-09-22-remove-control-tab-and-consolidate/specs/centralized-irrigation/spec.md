## MODIFIED Requirements

### Requirement: Foundation-level control abstraction
The application MUST represent centralized control state models while isolating UI actions from production pump/valve hardware execution during the foundation phase.

#### Scenario: Interacting with centralized control screen
- **WHEN** the user navigates to the Field or Manual Control screen
- **THEN** centralized field-level system status, hardware metrics, and supervisor override abstractions are presented without invoking actual pump/valve hardware drivers.

### Requirement: Real-time centralized irrigation status display
The system SHALL present operational status for the centralized irrigation system across the Field and Manual Control screens, including main pump status (Off, Pumping, Fault), main valve status (Closed, Open, Transitioning), controller state (Online, Offline, Local Override), current irrigation state (Idle, Irrigating, Command Pending, Error), start timestamp, elapsed/remaining duration, last command result, and fixed target indicator (`ENTIRE FIELD`).

#### Scenario: Viewing real-time centralized system operational status
- **WHEN** the user opens the Field or Manual Control screen
- **THEN** the system displays real-time telemetry for the main pump, main valve, central controller connectivity, current irrigation state, active duration, last command outcome, and fixed target `ENTIRE FIELD`.

