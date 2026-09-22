## Why

The application navigation needs to be streamlined by removing the standalone Analytics tab from the main bottom navigation shell. Additionally, physical sensor node pairing needs to be integrated directly into the Settings screen, allowing operators to discover and pair dynamic sensor nodes that have entered pairing mode via a physical hardware button press.

## What Changes

- **BREAKING**: Remove the Analytics tab from the bottom navigation shell (`AppShell`), reducing the main navigation tabs from 6 to 5 (Home, Field, Control, Manual Control, Settings).
- Add a dedicated Hardware Node Pairing & Discovery section inside the `SettingsScreen` that enables operators to discover nodes in pairing mode (triggered by a physical button press on the node hardware), pair them, and assign them to dynamic monitoring zones.
- Update `NodeManagement` requirements to incorporate physical hardware button pairing activation and discovery workflow within Settings.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `mobile-app-shell`: Remove Analytics tab from bottom navigation shell items and tab routing.
- `settings`: Add requirement and scenarios for hardware-activated node pairing and discovery within the Settings screen.
- `node-management`: Add hardware-activated pairing mode trigger and dynamic node pairing integration.

## Impact

- **Mobile App Shell**: `lib/features/shell/presentation/app_shell.dart` navigation bar items and indexed stack updated from 6 tabs to 5 tabs.
- **Home Screen**: `lib/features/home/presentation/home_screen.dart` tab navigation callbacks updated to match new tab indices.
- **Settings Screen**: `lib/features/settings/presentation/settings_screen.dart` expanded with Node Pairing & Discovery section.
- **Tests**: Shell navigation widget tests and settings widget tests updated to account for 5 tabs and hardware node pairing UI.
