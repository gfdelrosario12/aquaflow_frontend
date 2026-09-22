## Context

See proposal.md - Why.

## Goals / Non-Goals

**Goals:**
- Remove `ControlScreen` and the `Control` navigation tab, reducing bottom navigation tabs from 5 down to 4:
  - Tab 0: Home (`HomeScreen`)
  - Tab 1: Field (`FieldScreen`)
  - Tab 2: Manual Control (`ManualControlScreen`)
  - Tab 3: Settings (`SettingsScreen`)
- **HomeScreen**: Update all control quick actions and navigation callbacks (`onNavigateToControl`) to route to tab 2 (`ManualControlScreen`).
- **FieldScreen**: Add a `Central Controller & Hardware Actuators` status section displaying main pump state, main valve state, line flow rate, line pressure, and controller connectivity.
- **ManualControlScreen**: Expand into a comprehensive irrigation control hub by incorporating:
  - `AutomationSupervisorCard` (automation state, cooldown timer, fault lockout resolution, configuration dialog).
  - `CentralFieldControlActions` (Start/Stop field irrigation commands with confirmation dialogs and pending state).
  - `IrrigationAuditLogSection` (complete execution audit history).

**Non-Goals:**
- Removing or altering the backend REST API endpoints or LoRaWAN gateway command pipeline.

## Decisions

1. **Tab Structure & Indexing**:
   - Tab 0: Home
   - Tab 1: Field
   - Tab 2: Manual Control
   - Tab 3: Settings
2. **Component Relocation**:
   - Move `Central Controller & Hardware Actuators` hardware status card to `FieldScreen`.
   - Embed `CentralControlNotifier` and `AutomationSupervisorCard` directly into `ManualControlScreen`.
   - Delete `ControlScreen` file once all required sub-widgets are extracted or imported into their target screens.

## Risks / Trade-offs

- [Risk] Existing widget tests referencing `ControlScreen` or expecting 5 tabs will fail. → Mitigation: Refactor shell navigation tests and update tests to verify consolidated `ManualControlScreen` and `FieldScreen` hardware sections.

