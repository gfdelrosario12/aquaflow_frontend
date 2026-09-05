# centralized-irrigation Specification

## Purpose
Provides centralized irrigation system models and field-wide operational status abstractions for AquaSense.
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
- **THEN** centralized field-level system status and simulated override abstractions are presented without invoking actual pump/valve hardware hardware drivers.

