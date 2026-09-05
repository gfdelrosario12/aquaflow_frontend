## Why

AquaSense needs a dedicated settings experience so operators can manage account, presentation, notification, measurement, language, and application preferences without mixing those concerns into field monitoring or irrigation control workflows. Establishing a modular settings contract now also gives future backend synchronization a stable boundary while preserving field-level irrigation ownership in the control and backend features.

## What Changes

- Add a modular Settings feature with separate sections for user/account information, notification preferences, measurement units, appearance, language, application information, and system preferences.
- Support System, Light, and Dark appearance modes through the existing AquaSense design system and persisted preference state.
- Define persistence behavior for local settings and asynchronous loading, saving, and error states where storage is involved.
- Prepare repository and state abstractions for future backend synchronization without adding unrelated backend functionality.
- Keep settings independent from monitoring-zone and irrigation business logic; do not add Q1-Q4 irrigation settings or controls for individual zones.
- Keep centralized irrigation configuration field-level and delegated to the existing control/backend feature boundary.

## Capabilities

### New Capabilities
- `settings`: Provides modular account, notification, units, appearance, language, application information, and system preference management with persistence and future synchronization boundaries.

### Modified Capabilities

## Impact

- **Presentation**: Settings screens, section widgets, preference controls, loading/error feedback, and navigation integration under `lib/features/settings/`.
- **Domain and data**: Settings models, repository abstraction, local/mock persistence, and notifier/state management prepared for a future synchronized backend.
- **Application state**: Theme mode and other persisted preferences must remain consistent across app startup and settings updates.
- **Navigation**: Settings entry points and existing settings screen composition may be expanded without changing monitoring or irrigation workflows.
- **Tests**: Unit and widget coverage for persistence, appearance modes, preference updates, loading/error states, and scope isolation.
