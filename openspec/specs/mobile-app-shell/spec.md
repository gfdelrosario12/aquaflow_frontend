# mobile-app-shell Specification

## Purpose
Provides the primary application shell and bottom navigation router for switching between Home, Field, Analytics, Control, and Settings screens.
## Requirements
### Requirement: Application bottom navigation shell
The application MUST display a primary navigation shell titled "Aqua Flow" providing access to Home, Field, Analytics, Control, and Settings screens with "Aqua Flow Dashboard" branding headers, guarded by user authentication state.

#### Scenario: Switching primary navigation tabs
- **WHEN** an authenticated user taps a navigation item in the bottom bar
- **THEN** the active view transitions seamlessly to the selected screen while maintaining navigation state and displaying "Aqua Flow" header identity.

#### Scenario: Unauthenticated access attempt
- **WHEN** an unauthenticated user attempts to access the application shell
- **THEN** the application redirects the user to the Login screen before granting access to navigation tabs.

### Requirement: Mobile viewport optimization
The application shell MUST render without clipping, overflow, or layout degradation on target Android viewports between 360px and 430px width.

#### Scenario: Rendering on standard mobile viewport widths
- **WHEN** the app runs on devices with screen widths from 360px to 430px
- **THEN** navigation items, headers, cards, and interactive targets adhere to touch guidelines (at least 48dp) and fit within screen boundaries.

