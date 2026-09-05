## ADDED Requirements

### Requirement: Modular settings sections
The system SHALL provide independent settings sections for user/account information, notification preferences, measurement units, appearance, language, application information, and system preferences.

#### Scenario: Operator opens settings
- **WHEN** an authenticated operator opens the Settings screen
- **THEN** the screen presents distinct sections for account, notifications, measurement units, appearance, language, application information, and system preferences.

### Requirement: Appearance mode selection
The system SHALL support `System`, `Light`, and `Dark` appearance modes using the AquaSense design system and SHALL apply the selected mode consistently across the application.

#### Scenario: Operator changes appearance mode
- **WHEN** the operator selects System, Light, or Dark appearance
- **THEN** the application applies the corresponding `ThemeMode` and presents the selected value as the active preference.

### Requirement: Persisted settings state
The system SHALL load persisted settings asynchronously and SHALL expose loading, saving, success, and error states while retaining the last successfully loaded settings when a load or save operation fails.

#### Scenario: Settings load succeeds
- **WHEN** the Settings screen requests stored preferences
- **THEN** controls render the persisted values after loading completes and no error state is shown.

#### Scenario: Settings persistence fails
- **WHEN** a settings load or save operation fails
- **THEN** the system presents actionable error feedback, preserves the last known valid settings, and does not report the failed value as persisted.

### Requirement: Future synchronization boundary
The system SHALL access stored settings through a repository abstraction that can support future backend synchronization without requiring settings widgets to know storage or transport details.

#### Scenario: Settings repository is replaced
- **WHEN** a future synchronized repository is provided to the settings state layer
- **THEN** the settings sections continue to consume the same typed state and persistence actions without direct backend-specific code.

### Requirement: Account and notification preference management
The system SHALL display available user/account information and SHALL allow supported notification preferences to be viewed and updated without changing authentication or alert-delivery business logic.

#### Scenario: Operator updates a notification preference
- **WHEN** the operator changes a supported notification preference
- **THEN** the preference state updates, persistence is attempted, and the result is represented by the settings save state.

### Requirement: Measurement units and language preferences
The system SHALL provide typed measurement-unit and language preferences and SHALL apply accepted values consistently to settings-owned presentation without altering stored field telemetry semantics.

#### Scenario: Operator changes units or language
- **WHEN** the operator selects a supported measurement unit or language
- **THEN** the selected preference is displayed as active and persisted through the settings repository.

### Requirement: Application and system information
The system SHALL provide application information and system preferences as read-only or explicitly supported settings content, including the current application version and relevant local system behavior.

#### Scenario: Operator views application information
- **WHEN** the operator opens the application information section
- **THEN** the application displays version and environment information without exposing unrelated operational controls.

### Requirement: Irrigation and monitoring scope isolation
The settings feature MUST NOT provide controls that change individual monitoring-zone behavior, create Q1-Q4 irrigation settings, activate pumps, or operate valves. Centralized irrigation configuration SHALL remain field-level and owned by the appropriate control/backend features.

#### Scenario: Operator reviews settings for Q1-Q4
- **WHEN** the operator opens or searches the Settings screen
- **THEN** no Q1, Q2, Q3, or Q4 irrigation control, zone-specific actuator setting, pump action, or valve action is presented.

#### Scenario: Operator needs centralized irrigation configuration
- **WHEN** the operator needs to change centralized irrigation behavior
- **THEN** Settings does not mutate that configuration and directs responsibility to the field-level control/backend feature boundary.
