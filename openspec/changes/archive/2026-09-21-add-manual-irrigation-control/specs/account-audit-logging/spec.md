## Purpose

Defines modified account audit logging requirements for manual irrigation control events.

## ADDED Requirements

### Requirement: Account audit logging integration
The system SHALL emit immutable `AccountAuditEvent` records for all manual field irrigation command dispatches, explicitly identifying the human actor account, command parameters, target scope (`ENTIRE FIELD`), optional rationale, and execution result.

#### Scenario: Logging manual start command dispatch
- **WHEN** an operator dispatches a manual irrigation start command
- **THEN** the system logs an audit event containing `actor: user/<userId>`, `action: MANUAL_IRRIGATION_START`, `target: ENTIRE FIELD`, `durationMinutes: <minutes>`, `rationale: <rationale>`, and `outcome: SUCCESS|FAILURE`.

