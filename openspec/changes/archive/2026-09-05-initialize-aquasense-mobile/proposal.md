## Why

The AquaSense mobile application requires a foundational, scalable Flutter architecture to support smart water and field monitoring. Establishing a clean feature-first structure with centralized irrigation domain models and independent monitoring zone representations ensures high maintainability and smooth iteration for future telemetry and control integrations.

## What Changes

- **Core Application Architecture**: Establish a feature-first Flutter layout (`lib/core` and `lib/features/`), dark-first design theme, routing system, and repository/data-source abstractions ready for future REST API integration.
- **Application Shell & Navigation**: Implement an adaptive shell navigation supporting five primary tabs: Home, Field, Analytics, Control, and Settings, optimized for mobile viewports (360–430px).
- **Independent Monitoring Zones Domain**: Model zones Q1, Q2, Q3, and Q4 strictly as telemetry monitoring zones with independent soil/water status representations, ensuring no zone-level irrigation logic is introduced.
- **Centralized Field Irrigation Model**: Model the physical irrigation system as a single field-wide centralized entity with system-level status abstractions.
- **Shared UI & State Management**: Create reusable UI feedback states (loading, empty, error, responsive container) and state management foundation.

## Capabilities

### New Capabilities
- `core-architecture`: Feature-first project structure, dark-first UI theme, routing, shared state feedback widgets, and repository/data-source abstractions for future REST API integration.
- `mobile-app-shell`: Navigation shell with Home, Field, Analytics, Control, and Settings views suitable for 360–430px wide screens.
- `monitoring-zones`: Domain models and repository abstractions for monitoring zones Q1–Q4 strictly as independent monitoring zones without zone-level controls.
- `centralized-irrigation`: Field-wide physical irrigation system domain model and centralized control interface abstraction.

### Modified Capabilities
<!-- No modified capabilities -->

## Impact

- **Frontend Codebase**: Replaces default boilerplate in `lib/` with scalable feature-first Flutter architecture.
- **Dependencies**: May add core Dart/Flutter packages (e.g., `flutter_bloc` or state management utilities, `google_fonts`, `equatable`, `dio` or standard HTTP abstraction) if needed.
- **Systems & Hardware Abstraction**: Establishes strict domain boundaries isolating monitoring zones from centralized field irrigation controls.
