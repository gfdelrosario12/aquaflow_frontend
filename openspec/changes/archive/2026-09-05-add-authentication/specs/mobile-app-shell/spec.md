## MODIFIED Requirements

### Requirement: Application bottom navigation shell
The application MUST display a primary navigation shell titled "Aqua Flow" providing access to Home, Field, Analytics, Control, and Settings screens with "Aqua Flow Dashboard" branding headers, guarded by user authentication state.

#### Scenario: Switching primary navigation tabs
- **WHEN** an authenticated user taps a navigation item in the bottom bar
- **THEN** the active view transitions seamlessly to the selected screen while maintaining navigation state and displaying "Aqua Flow" header identity.

#### Scenario: Unauthenticated access attempt
- **WHEN** an unauthenticated user attempts to access the application shell
- **THEN** the application redirects the user to the Login screen before granting access to navigation tabs.
