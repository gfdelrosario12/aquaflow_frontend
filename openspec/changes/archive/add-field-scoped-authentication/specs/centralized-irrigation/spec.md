## MODIFIED Requirements

### Requirement: Safe authorized irrigation command execution
The system SHALL require an authenticated session with an `operator` or `field_admin` role (as resolved from field-scoped JWT claims and enforced by the backend) and a two-step confirmation dialog with safety warnings before dispatching `Start Field Irrigation` or `Stop Field Irrigation` commands through the backend API to the central controller. Commands MUST target only `ENTIRE FIELD` and MUST NOT address Q1–Q4 actuators. Authorization is enforced server-side; the Flutter client MUST NOT rely solely on client-side role checks to prevent unauthorized command dispatch.

#### Scenario: Requesting field irrigation activation with confirmation
- **WHEN** an authenticated user with `operator` or `field_admin` role taps the "Start Field Irrigation" action on the Control screen
- **THEN** the system presents a confirmation modal displaying field impact, safety warnings, and target confirmation before sending the start command to the backend irrigation endpoint.

#### Scenario: Blocking unauthorized control command attempts — insufficient role
- **WHEN** a user with `viewer` role attempts to execute a Start or Stop command
- **THEN** the Flutter client hides or disables the command controls based on the resolved session role, and any attempt to invoke the backend directly is rejected with HTTP 403 and a role-insufficient warning is displayed.

#### Scenario: Unauthenticated control command attempt
- **WHEN** an unauthenticated session attempts to dispatch a Start or Stop command
- **THEN** the system blocks the command, clears or denies the action, and directs the user to re-authenticate without exposing zone-level irrigation controls.

### Requirement: Operator manual override and safety lockout recovery
The system SHALL allow authenticated users with `operator` or `field_admin` role to override automatic irrigation at any time, toggle automation mode (`enabled` / `disabled`), and review or clear `faultLocked` states after performing physical field inspection. `viewer` role MUST NOT be permitted to perform these operations.

#### Scenario: Operator aborts active automated irrigation
- **WHEN** an authenticated user with `operator` or `field_admin` role clicks "Emergency Stop" or "Stop Field Irrigation" on an automated cycle
- **THEN** the system immediately sends a high-priority stop command to the central controller, cancels the automated cycle, transitions to `standby` (or `disabled`), and alerts the backend.

#### Scenario: Operator clears fault lockout
- **WHEN** an authenticated user with `operator` or `field_admin` role acknowledges and clears a resolved fault lockout
- **THEN** the system verifies controller health and transitions from `faultLocked` to `standby`.

#### Scenario: Viewer attempts fault lockout clearance
- **WHEN** an authenticated user with `viewer` role attempts to clear a fault lockout
- **THEN** the system hides or disables the clear action in the UI, and any backend invocation returns HTTP 403.
