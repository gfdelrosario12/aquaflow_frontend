## Why

AquaSense currently models field telemetry across four independent monitoring zones (Q1–Q4) and provides field-wide AWD analytics, but lacks a complete, interactive, end-to-end control workflow for the single centralized irrigation system. Physical rice field irrigation requires controlling a single central controller, pump, and main valve that service the entire field. Providing safe, authorized, and reliable control actions with real-time status monitoring, safety confirmations, and robust fault handling is essential to prevent erroneous quadrant-level commands, uncoordinated pump operations, and safety hazards.

## What Changes

- **Centralized Control Screen**: Enhance `ControlScreen` to display pump status (Off/Pumping/Fault), main-valve status (Closed/Open/Transitioning), controller status (Online/Offline/Local Override), active irrigation state, start time, duration, last command timestamp & result, and fixed target indicator (`ENTIRE FIELD`).
- **Interactive Control Pipeline**: Implement domain models, state management, and repository abstractions for `Start Field Irrigation` and `Stop Field Irrigation` commands matching the end-to-end architecture (Mobile App → Backend API → LoRaWAN/Messaging Gateway → Central Controller → Hardware Actuators).
- **Safety & Authorization Enforcement**: Require explicit user confirmation dialogs with clear safety warnings before executing start/stop commands. Enforce role-based authorization checks and prevent duplicate or contradictory command dispatches while a command is pending.
- **Fault & Edge Case Resilience**: Handle command timeouts, controller offline states, stale status telemetry, command failures, local/emergency stop overrides, and communication link failures gracefully in the UI.
- **Strict Single-System Isolation**: Enforce architectural boundaries ensuring Q1, Q2, Q3, and Q4 monitoring points are strictly read-only telemetry nodes with zero pump/valve controls, and distinguish automated irrigation recommendations from confirmed active irrigation.

## Capabilities

### Modified Capabilities
- `centralized-irrigation`: Define interactive control command execution, safety confirmation dialogs, authorization rules, command pipeline state handling, and error/fault resilience for the single field-wide irrigation system.

## Impact

- **UI Components**: `lib/features/control/presentation/control_screen.dart`, command confirmation dialogs, status indicator cards.
- **Domain Layer**: `lib/features/control/domain/models/`, `lib/features/control/domain/services/`, command request/result models, controller state enums.
- **Data Layer**: `lib/features/control/data/repositories/` abstraction and mock implementation representing the LoRaWAN/messaging pipeline.
- **Dependencies**: Uses existing Riverpod state management and standard Flutter design system components.

