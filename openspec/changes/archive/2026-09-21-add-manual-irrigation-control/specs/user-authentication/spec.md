## Purpose

Defines added user authentication and authorization requirements for manual field irrigation controls.

## ADDED Requirements

### Requirement: Role-based authorization
The application SHALL enforce role-based access control, requiring explicit `operator` or `fieldAdmin` roles to dispatch manual irrigation start, stop, pulse, or override commands.

#### Scenario: Permitting operator manual control access
- **WHEN** an authenticated user with `operator` or `fieldAdmin` role accesses manual irrigation controls
- **THEN** manual action buttons are enabled and command dispatches are permitted.

#### Scenario: Denying viewer manual control access
- **WHEN** an authenticated user with `viewer` role attempts to execute a manual irrigation command
- **THEN** the action is blocked with an explicit permission error message indicating insufficient privileges.
