## 1. Validation scaffolding and thesis map

- [x] 1.1 Create shared test helpers/fakes under `test/support/` (HTTP, storage, connectivity, auth/control repositories, pipeline stage recorder as needed).
- [x] 1.2 Add thesis-oriented validation structure doc (`docs/validation/` or `test/VALIDATION.md`) mapping categories to test locations.
- [x] 1.3 Inventory existing `test/*.dart` coverage vs required screens/states and note gaps in the validation map.

## 2. Unit test expansion

- [x] 2.1 Strengthen/add unit tests for domain models and repository contracts across monitoring, alerts, diagnostics, and settings.
- [x] 2.2 Strengthen/add unit tests for AWD analysis logic and measurement/analytics data transformations/mappers.
- [x] 2.3 Strengthen/add unit tests for authentication state transitions and typed API/error handling (timeout, failure, unauthorized).
- [x] 2.4 Strengthen/add unit tests for irrigation command handling including rejection of Q1–Q4 / non-`ENTIRE FIELD` targets.

## 3. Widget test expansion

- [x] 3.1 Ensure widget coverage for dashboard, field monitoring, and Q1–Q4 zone detail/analysis screens.
- [x] 3.2 Ensure widget coverage for AWD analytics, centralized irrigation control, alerts, and device diagnostics screens.
- [x] 3.3 Ensure widget coverage for authentication and settings screens, including validation and primary actions.

## 4. Async-state and responsive validation

- [x] 4.1 Add or extend tests for loading, empty, stale, offline, timeout, failure, and recovery presentations on screens that implement those states.
- [x] 4.2 Add responsive widget checks at approximately 360px and 430px widths for key screens (no overflow; primary actions reachable).

## 5. Architectural invariant and irrigation pipeline

- [x] 5.1 Add invariant tests proving zone/monitoring UIs expose no independent irrigation actuators for Q1–Q4.
- [x] 5.2 Add invariant/API tests proving irrigation DTOs/repos/control path accept only `ENTIRE FIELD` and reflect one centralized pump/valve system.
- [x] 5.3 Add mocked pipeline workflow tests for Mobile → Backend API → gateway/messaging → controller → pump/valve success, timeout, and failure/unconfirmed outcomes.

## 6. Integration/workflow tests and suite verification

- [x] 6.1 Add integration/workflow tests for navigation shell, authentication flow, API fakes, realtime updates, and offline/degraded irrigation gating.
- [x] 6.2 Update the validation map with final file references for all categories.
- [x] 6.3 Run `flutter test` (and any new workflow suite paths) and fix regressions or flaky timing.
