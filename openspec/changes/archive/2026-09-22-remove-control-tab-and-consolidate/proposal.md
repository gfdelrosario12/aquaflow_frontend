## Why

The `Control` tab and `Manual Control` tab present overlapping control interfaces for the central irrigation system. Removing the standalone `Control` tab simplifies primary application navigation while distributing its essential hardware telemetry, automation supervisor, and field dispatch components logically across `HomeScreen`, `FieldScreen`, and `ManualControlScreen`.

## What Changes

- **BREAKING**: Remove `ControlScreen` and the `Control` tab from `AppShell`, reducing bottom navigation tabs from 5 to 4:
  - Tab 0: Home (`HomeScreen`)
  - Tab 1: Field (`FieldScreen`)
  - Tab 2: Manual Control (`ManualControlScreen`)
  - Tab 3: Settings (`SettingsScreen`)
- **Field Dashboard (`HomeScreen`)**: Direct quick control navigation actions to Tab 2 (`ManualControlScreen`).
- **Field Telemetry (`FieldScreen`)**: Integrate real-time central controller & actuator hardware status (Main Pump, Main Valve, Line Flow Rate, Line Pressure).
- **Manual Control (`ManualControlScreen`)**: Consolidate the Automation Supervisor (state, cooldown, lockout clearing, configuration dialog), Central Field Control dispatch actions (Start/Stop with confirmation dialogs), and execution audit logs into a unified irrigation control center.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `mobile-app-shell`: Remove `Control` tab and reduce primary navigation to 4 tabs (Home, Field, Manual Control, Settings).
- `centralized-irrigation`: Move hardware actuator telemetry and field control dispatch components into `FieldScreen` and `ManualControlScreen`.
- `manual-irrigation-control`: Expand Manual Control screen to incorporate the Automation Supervisor, field command controls, and complete execution audit logging.

## Impact

- **App Shell**: `lib/features/shell/presentation/app_shell.dart` updated to 4 tabs.
- **Home Screen**: `lib/features/home/presentation/home_screen.dart` tab callbacks route to tab 2 (Manual Control).
- **Field Screen**: `lib/features/field/presentation/field_screen.dart` expanded with central controller & actuator hardware status card.
- **Manual Control Screen**: `lib/features/irrigation/presentation/manual_control_screen.dart` expanded to incorporate `CentralControlNotifier`, Automation Supervisor, and central irrigation dispatch controls.
- **Tests**: Shell, field, and manual control unit/widget tests updated to reflect 4 tabs and consolidated controls.

