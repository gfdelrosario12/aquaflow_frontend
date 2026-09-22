# manual-irrigation-control Specification

## Purpose
Provides a dedicated, secure, and isolated Manual Control interface for field-wide AquaSense irrigation, separate from automatic sensor-driven execution.
## Requirements
### Requirement: Dedicated Manual Control Interface
The application SHALL provide a consolidated Manual Control tab and screen serving as the primary control center for central field irrigation dispatch, combining manual overrides, automatic supervision state, lockout resolution, and execution audit logging in one interface.

#### Scenario: Navigating to manual control interface
- **WHEN** an authorized user accesses the Manual Control section of the application
- **THEN** the system displays the manual irrigation controls, automation supervisor status, field command actions, active field pump/valve status, manual duration selectors, emergency stop interlock, and irrigation execution audit log.

### Requirement: Strict Field-Wide Actuation Target
All manual irrigation start, stop, duration adjustment, and manual override commands SHALL target the centralized irrigation system of the field (`ENTIRE FIELD`). Manual commands SHALL NOT target or accept individual monitoring zones or quadrants.

#### Scenario: Dispatching manual start command
- **WHEN** an operator dispatches a manual start command for 30 minutes
- **THEN** the application verifies that the target scope is `ENTIRE FIELD` and sends the manual command to the central field controller.

#### Scenario: Rejecting zone-scoped manual commands
- **WHEN** a client payload attempts to invoke a manual start command for an individual monitoring zone (e.g. `Q1` or `NODE-01`)
- **THEN** the application and API reject the command with a validation error indicating that manual irrigation is strictly field-wide.

### Requirement: Confirmation and Rationale UX
The application SHALL require explicit multi-step confirmation before executing any manual irrigation start or override action, capturing target runtime limit and optional override rationale.

#### Scenario: Manual start confirmation modal
- **WHEN** an operator selects a 45-minute manual pulse and clicks "Start Central Irrigation"
- **THEN** a modal dialog is displayed requiring explicit confirmation, displaying target runtime and safety ceiling limits, and providing a rationale input field.

### Requirement: Emergency Stop Interlock
The Manual Control interface SHALL provide an uninhibited, high-priority Emergency Stop button that immediately halts central pump execution and closes distribution valves regardless of automatic or manual mode state.

#### Scenario: Emergency stop execution
- **WHEN** an authorized user taps "Emergency Stop Pump"
- **THEN** the application immediately sends an uninhibited stop command for `ENTIRE FIELD` to the central controller, transitions hardware status to `stopping`/`idle`, and enters safety cooldown.

