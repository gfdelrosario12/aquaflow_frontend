## Context

See proposal.md - Why.

## Goals / Non-Goals

**Goals:**
- Remove the Analytics tab from `AppShell`, updating bottom navigation navigation items and active view index state from 6 tabs down to 5 tabs (Home, Field, Control, Manual Control, Settings).
- Add a dedicated Hardware Node Pairing & Discovery card/section in `SettingsScreen` to discover nodes in hardware pairing mode and launch the pairing and zone assignment dialog.
- Ensure all quick navigation actions (e.g., home tab dynamic zone/quadrant taps) route directly to tab 1 (Field tab).
- Update unit and widget tests to pass seamlessly with 5 navigation tabs.

**Non-Goals:**
- Modifying backend REST APIs or ESP32 physical firmware code.

## Decisions

1. **Tab Structure Update**:
   - Tab 0: Home (`HomeScreen`)
   - Tab 1: Field (`FieldScreen`)
   - Tab 2: Control (`ControlScreen`)
   - Tab 3: Manual Control (`ManualControlScreen`)
   - Tab 4: Settings (`SettingsScreen`)
2. **Node Pairing in Settings**:
   - Add a `Node Pairing & Hardware Discovery` tile in `SettingsScreen`.
   - Provide a button "Pair New Node (Press Hardware Button First)" that initiates scanning / opens `NodeRegistrationDialog`.
3. **Quadrant / Dynamic Zone Routing**:
   - Tapping dynamic monitoring zones or quick cards on `HomeScreen` routes directly to tab 1 (`FieldScreen`).

## Risks / Trade-offs

- [Risk] Existing widget tests that expect 6 navigation destinations or specific tab indices will break. → Mitigation: Refactor shell navigation tests and home screen navigation tests to assert 5 tabs and correct screen indexing.
