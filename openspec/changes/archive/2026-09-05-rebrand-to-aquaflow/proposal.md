## Why

The product branding is officially changing to **Aqua Flow**. Updating string constants, application titles, dashboard headers, and settings details to reflect "Aqua Flow" ensures consistency across all user touchpoints.

## What Changes

- **Application Title & Strings**: Update `AppStrings` constants from "AquaSense Mobile" to "Aqua Flow Mobile" and "Aqua Flow".
- **Dashboard & Navigation Branding**: Update headers in `HomeScreen`, `AppShell`, `SettingsScreen`, and HTML/Flutter app titles to display "Aqua Flow".
- **Tests & Specifications**: Update unit tests and main specification documents to enforce "Aqua Flow" branding requirements.

## Capabilities

### New Capabilities
<!-- No new capabilities -->

### Modified Capabilities
- `core-architecture`: Update application title and branding string requirements to "Aqua Flow".
- `mobile-app-shell`: Update dashboard and application shell header branding requirements to "Aqua Flow".

## Impact

- **Frontend Codebase**: Changes `AppStrings` constants and presentation layer text in `lib/core/constants/app_strings.dart`, `lib/main.dart`, and feature views.
- **Tests**: Updates test assertions in `test/widget_test.dart` to expect "Aqua Flow".
- **No Breaking Changes**: Core architecture, monitoring logic, and domain data remain intact.
