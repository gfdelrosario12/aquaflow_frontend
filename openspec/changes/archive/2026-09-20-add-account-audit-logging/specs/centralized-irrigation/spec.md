## MODIFIED Requirements

### Requirement: Explicit automation actor attribution and audit trail
The system SHALL record all irrigation events in an immutable audit trail, explicitly distinguishing automated triggers (`actor.type: system`, `actor.id: auto-awd`) from manual human operations (`actor.type: user`, `actor.id: <userId>`), and storing triggering rationales, sensor telemetry snapshots, target duration, and execution outcome.

#### Scenario: Logging an automated irrigation trigger
- **WHEN** an automated irrigation cycle is initiated by the AWD supervisor
- **THEN** the audit log SHALL record an entry with `actor.type: system`, `actor.id: auto-awd`, `category: irrigation`, `action: irrigation.start`, and metadata containing the triggering AWD depth, confidence rating, active crop stage, and target duration

#### Scenario: Logging a manual operator override
- **WHEN** an authenticated operator manually aborts an in-progress automated irrigation cycle
- **THEN** the audit log SHALL record an entry with `actor.type: emergencyOverride`, `actor.id: <userId>`, `category: irrigation`, `action: irrigation.manual_override`, and metadata containing the override reason and remaining duration

#### Scenario: Logging an automatic irrigation stop
- **WHEN** an automated irrigation cycle reaches target fill volume or maximum duration
- **THEN** the audit log SHALL record an entry with `actor.type: system`, `actor.id: auto-awd`, `category: irrigation`, `action: irrigation.stop`, `result: success`, and metadata containing the actual duration and stopping rationale

#### Scenario: Logging a failed automatic irrigation trigger
- **WHEN** an automated irrigation trigger is inhibited or fails pre-flight checks
- **THEN** the audit log SHALL record an entry with `actor.type: system`, `actor.id: auto-awd`, `category: irrigation`, `action: irrigation.start`, `result: denied`, and metadata containing the inhibition reason
