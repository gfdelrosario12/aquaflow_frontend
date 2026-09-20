## Context

See proposal.md - Why.

The AquaSense application requires a dedicated, isolated Manual Control interface for field-wide irrigation. The system operates on a single central controller managing main pump and main distribution valve hardware for the whole field. Sensor nodes monitor soil moisture across monitoring zones, but manual irrigation must strictly target the central system (`ENTIRE FIELD`).

## Goals / Non-Goals

**Goals:**
- Provide a dedicated, clean Manual Control interface/tab in the AquaFlow application separate from automatic sensor supervision.
- Enforce strict `ENTIRE FIELD` targeting for all manual actions, rejecting any zone/quadrant control attempts.
- Enforce operator/fieldAdmin role authorization and a two-step confirmation modal capturing target runtime limits and optional override rationale.
- Provide an uninhibited, high-priority Emergency Stop interlock button on the manual control interface.
- Implement a deterministic supervisor state machine governing transitions between `automatic`, `manualOverride`, `cooldown`, and `emergencyStop`.
- Emit unified `AccountAuditEvent` records for all manual actions attributed to the authenticated human actor (`user/<userId>`).

**Non-Goals:**
- Supporting individual node or zone actuator controls (AquaSense central architecture enforces single-field irrigation).
- Modifying underlying MQTT/LoRaWAN radio protocols (commands route via REST backend API `/api/irrigation/*`).
- Dynamic schedule building or automated prescription scripting in the manual interface.

## Decisions

### Decision 1: Dedicated Tab & State Machine Architecture
- **Choice**: Implement `ManualControlScreen` accessible as a dedicated tab in the navigation shell. Use a Riverpod `ManualControlNotifier` managing a strict state machine (`Idle`, `PendingConfirmation`, `Dispatching`, `ActiveOverride`, `Cooldown`, `EmergencyStop`).
- **Rationale**: Keeps manual execution state decoupled from automatic AWD advice widgets and prevents accidental triggers.
- **Alternatives Considered**: 
  - Inline controls inside the field dashboard card: Rejected to prevent accidental activation and maintain strict operational boundary.

### Decision 2: Field-Wide Actuation & Payload Validation
- **Choice**: All manual API requests payload MUST specify `targetScope: "ENTIRE_FIELD"`. Frontend state models and backend endpoints reject any request containing `zoneId` or `quadrantId`.
- **Rationale**: Preserves single field-level hydraulic domain integrity and satisfies strict system safety constraints.
- **Alternatives Considered**: 
  - Permitting zone overrides that trigger field pump: Rejected due to hydraulic risk of closed valves in non-targeted zones causing backpressure.

### Decision 3: Multi-Step Confirmation with Required Rationale & Limits
- **Choice**: Manual start/override triggers a confirmation modal requiring explicit confirmation check, selection of preset or custom duration (10–120 mins, max ceiling 180 mins), and optional rationale string.
- **Rationale**: Prevents accidental taps and ensures accountability for manual overrides.
- **Alternatives Considered**: 
  - Single tap with undo toast: Rejected for safety-critical hardware operations.

### Decision 4: Uninhibited Emergency Stop Interlock
- **Choice**: Emergency Stop bypasses confirmation modals and immediately dispatches `POST /api/irrigation/emergency-stop` targeting `ENTIRE FIELD`, setting system state to `emergencyStop` and halting pump operation immediately.
- **Rationale**: Operational safety requires zero-delay shutdown capability.
- **Alternatives Considered**: 
  - Reusing standard Stop confirmation flow: Rejected because safety stops must be instantaneous.

### Decision 5: Human-Attributed Audit Event Logging
- **Choice**: Upon manual command completion or error response, `AccountAuditRepository` logs an `AccountAuditEvent` containing `actor: user/<userId>`, `action: MANUAL_IRRIGATION_START | MANUAL_IRRIGATION_STOP | EMERGENCY_STOP`, `target: ENTIRE FIELD`, `rationale`, and `timestamp`.
- **Rationale**: Ensures complete regulatory compliance and non-repudiation of field hardware operations.

## Risks / Trade-offs

- **[Risk]** Signal loss or network latency when executing Emergency Stop from mobile app.
  - **Mitigation**: Immediate local UI state update to `stopping`, optimistic command dispatch with automatic retry fallback, and physical emergency stop button on local central controller panel.
- **[Risk]** Concurrent manual interventions from multiple operator accounts.
  - **Mitigation**: Backend API enforces atomic locks on irrigation state; second command attempt receives HTTP 409 Conflict with active operator session details.

## Migration Plan

1. Add domain models and Riverpod state notifiers for manual control in `lib/features/irrigation/`.
2. Add `ManualControlScreen`, confirmation modal, and emergency stop interlock UI.
3. Update `IrrigationRepository` with `/api/irrigation/manual-override` endpoints.
4. Integrate `AccountAuditRepository` emission on all manual control actions.
5. Add unit and widget tests for manual control workflows and safety constraints.

