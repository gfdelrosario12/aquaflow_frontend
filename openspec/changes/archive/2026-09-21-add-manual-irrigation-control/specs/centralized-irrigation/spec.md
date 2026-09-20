## Purpose

Defines modified centralized field irrigation requirements for manual override state lifecycle, priority over automatic rules, auto-resumption rules, and manual execution safety.

## MODIFIED Requirements

### Requirement: Centralized field irrigation model
The application MUST model physical field irrigation as a single centralized system serving the entire field, distinct from individual telemetry monitoring zones, and SHALL support deterministic state transitions between automatic and manual override modes.

#### Scenario: Displaying irrigation status
- **WHEN** the user views irrigation information in the Control or Home screen
- **THEN** system operational status (such as Main Pump state, System Mode, and Flow Rate) is presented as a unified field-wide entity.

#### Scenario: Manual override state transition
- **WHEN** an authorized operator executes a manual irrigation start or override command
- **THEN** the centralized irrigation supervisor transitions mode state from `automatic` to `manualOverride`, suspending automatic sensor-driven irrigation triggers while keeping telemetry collection active.

#### Scenario: Automatic mode resumption post manual override
- **WHEN** a manual pulse completes its target duration or an operator manually releases manual override
- **THEN** the supervisor enters a safety cooldown period before transitioning back to `automatic` standby state.
