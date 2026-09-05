## Context

The AquaSense foundation mobile app needs to be updated to match the official **Aqua Flow** brand name across all application text constants, presentation components, titles, and unit test assertions.

## Goals / Non-Goals

**Goals:**
- Centralize all branding string constants in `lib/core/constants/app_strings.dart`.
- Update application title in `lib/main.dart` and `web/index.html`.
- Update dashboard headers in `HomeScreen` and settings details in `SettingsScreen`.
- Update tests in `test/widget_test.dart` to assert "Aqua Flow" branding strings.

**Non-Goals:**
- Changing underlying domain models or API repository contracts.
- Altering the dark theme color palette or UI layout structures.

## Decisions

### Decision 1: Single Source of Truth for Branding Strings
- **Decision**: Update `AppStrings` string constants (`appTitle`, `dashboardTitle`, etc.) to "Aqua Flow Mobile" and "Aqua Flow Dashboard".
- **Rationale**: Prevents hardcoded string fragmentation and ensures future branding adjustments can be done in one central file.

## Risks / Trade-offs

- **[Risk] Broken unit test assertions** → **Mitigation**: Update `test/widget_test.dart` to expect "Aqua Flow Dashboard" and run `flutter test` to verify.
