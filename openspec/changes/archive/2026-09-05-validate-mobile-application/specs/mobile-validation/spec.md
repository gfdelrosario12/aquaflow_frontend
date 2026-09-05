## Purpose

Defines comprehensive validation and testing expectations for the AquaSense Flutter mobile application, including unit/widget/integration coverage, responsive and async-state checks, architectural invariant proofs for Q1–Q4 vs centralized irrigation, mocked irrigation pipeline validation, and a thesis-oriented validation structure.

## ADDED Requirements

### Requirement: Layered validation suite
The project SHALL provide an executable layered validation suite covering unit tests, widget tests, and integration/workflow tests that can run without physical LoRaWAN or pump hardware.

#### Scenario: Default validation command succeeds
- **WHEN** a developer runs the project's standard Flutter test command for the validation suite
- **THEN** unit, widget, and in-process integration/workflow tests execute and report pass/fail without requiring physical field hardware.

### Requirement: Unit coverage for core domains
The system SHALL include unit tests for domain models, repositories, AWD analysis logic, authentication state, irrigation command handling, data transformations/mappers, and typed error handling.

#### Scenario: AWD and irrigation unit cases exist
- **WHEN** the unit validation suite runs
- **THEN** tests exercise AWD analysis outcomes and irrigation command accept/reject paths including invalid zone targets.

#### Scenario: Auth and error mapping unit cases exist
- **WHEN** the unit validation suite runs
- **THEN** tests exercise authentication state transitions and API/repository error mapping for timeout, failure, and unauthorized conditions.

### Requirement: Widget coverage for primary screens
The system SHALL include widget tests for the field dashboard, field monitoring, Q1–Q4 monitoring-zone detail/analysis views, AWD analytics, centralized irrigation control, alerts, device diagnostics, authentication, and settings screens.

#### Scenario: Primary screens render under test
- **WHEN** widget tests for each primary screen run with injectable notifiers or repositories
- **THEN** each screen builds successfully and exposes its primary monitoring or control affordances appropriate to that screen's role.

### Requirement: Integration and workflow validation
The system SHALL include integration/workflow tests covering navigation shell behavior, authentication flow, API client integration with fakes, real-time update handling, offline/degraded behavior, and centralized irrigation command workflows.

#### Scenario: Authenticated navigation workflow
- **WHEN** an integration/workflow test drives login success followed by shell navigation
- **THEN** the user reaches the authenticated app shell and can open primary destinations without unhandled exceptions.

#### Scenario: Offline irrigation workflow blocked
- **WHEN** an integration/workflow test attempts a centralized irrigation command while offline or unauthenticated
- **THEN** the command is rejected and no pump/valve actuation is represented as confirmed.

### Requirement: Responsive phone-width validation
The system SHALL validate key screens at approximately 360px and 430px logical widths representative of Android phone viewports.

#### Scenario: Dashboard and control at narrow width
- **WHEN** widget tests set the surface width to approximately 360 logical pixels for dashboard and control screens
- **THEN** the UI renders without overflow errors and primary actions remain visible or reachable.

#### Scenario: Field monitoring at wider phone width
- **WHEN** widget tests set the surface width to approximately 430 logical pixels for field monitoring
- **THEN** the Q1–Q4 monitoring layout renders without overflow errors.

### Requirement: Asynchronous UI state validation
The system SHALL test loading, empty, stale, offline, timeout, failure, and recovery presentations for screens that implement those states.

#### Scenario: Stale and offline monitoring presentation
- **WHEN** monitoring or telemetry data is marked stale or connectivity is offline under test
- **THEN** the UI presents the corresponding stale/offline indication rather than unlabeled live values.

#### Scenario: Failure and recovery presentation
- **WHEN** a repository or API fake returns a failure and then a successful retry under test
- **THEN** the UI shows a failure/error state and subsequently recovers to a successful presentation after retry.

### Requirement: Monitoring vs irrigation architectural invariant
The validation suite MUST prove that Q1, Q2, Q3, and Q4 are independent monitoring zones only, that a single centralized pump/main valve serves the entire field, and that no screen, model, API DTO path, or UI control provides independent irrigation actuation for Q1–Q4.

#### Scenario: Zone views lack irrigation actuators
- **WHEN** widget or invariant tests inspect field monitoring and Q1–Q4 zone analysis screens
- **THEN** no Start Irrigation, Stop Irrigation, zone pump, or zone valve controls are present.

#### Scenario: Irrigation APIs reject zone targets
- **WHEN** unit tests construct irrigation commands or DTOs targeting Q1–Q4 or other non-`ENTIRE FIELD` scopes
- **THEN** the command/DTO is rejected before or without successful backend dispatch as an accepted zone irrigation action.

#### Scenario: Control path is entire-field only
- **WHEN** centralized control tests dispatch a permitted irrigation command
- **THEN** the target is `ENTIRE FIELD` and telemetry reflects a single centralized pump/valve system.

### Requirement: Mocked irrigation command pipeline validation
The system SHALL validate the irrigation command flow Mobile App → Backend API → messaging/LoRaWAN gateway abstraction → central controller → pump/main valve using mocks or fixtures when physical hardware is unavailable.

#### Scenario: Successful mocked pipeline acknowledgment
- **WHEN** an authorized online start/stop command is dispatched through the mocked pipeline
- **THEN** each logical stage is exercised or recorded in order and the final telemetry reflects acknowledged pump/valve state for `ENTIRE FIELD`.

#### Scenario: Pipeline timeout or failure remains unconfirmed
- **WHEN** the mocked controller or API stage times out or fails
- **THEN** the command outcome is timeout/failure/rejected and the UI does not treat irrigation as confirmed success.

### Requirement: Thesis-oriented validation structure
The project SHALL provide a clear validation structure document that maps validation categories and architectural invariants to test locations for thesis documentation.

#### Scenario: Validation map is available
- **WHEN** a reader opens the validation structure document
- **THEN** it lists unit, widget, integration/workflow, responsive, async-state, invariant, and irrigation-pipeline categories with references to corresponding test files or directories.
