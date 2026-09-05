## 1. Settings Domain and Persistence

- [x] 1.1 Create typed settings models for account summary, notification preferences, measurement units, appearance mode, language, application information, and system preferences.
- [x] 1.2 Define a `SettingsRepository` abstraction with asynchronous load/save operations and a local/mock implementation prepared for future backend synchronization.
- [x] 1.3 Add repository-backed settings state management with loading, saving, success, and error states that retain the last valid settings snapshot on failure.

## 2. Preference Behavior and Theme Integration

- [x] 2.1 Map System, Light, and Dark appearance settings to the existing global `ThemeMode` state and persist accepted appearance changes.
- [x] 2.2 Implement typed notification, measurement-unit, language, and system preference updates with validation and persistence feedback.
- [x] 2.3 Preserve existing account/authentication behavior while exposing account information through the settings state and screen.

## 3. Settings Presentation and Navigation

- [x] 3.1 Refactor or extend `SettingsScreen` into modular sections for account, notifications, units, appearance, language, application information, and system preferences using AquaSense design components.
- [x] 3.2 Add asynchronous loading, saving, empty/default, and retryable error states to the settings UI without clearing the last valid values.
- [x] 3.3 Add or preserve Settings navigation entry points without coupling settings widgets to monitoring telemetry or irrigation command state.

## 4. Scope Isolation and Future Integration

- [x] 4.1 Ensure the settings domain and UI contain no Q1-Q4 irrigation controls, zone-specific behavior settings, pump actions, or valve actions.
- [x] 4.2 Keep centralized irrigation configuration field-level and delegate any related navigation or backend responsibility to the existing control/backend boundary.
- [x] 4.3 Document repository seams and defaults needed for replacing local/mock persistence with future backend synchronization.

## 5. Verification

- [x] 5.1 Add unit tests for settings defaults, serialization/persistence behavior, appearance modes, preference updates, and error retention.
- [x] 5.2 Add widget tests for all settings sections, loading/error states, appearance selection, persistence feedback, and irrigation-scope exclusions.
- [x] 5.3 Run `flutter analyze`, the focused settings tests, and the full `flutter test` suite with all checks passing.
