## Why

AquaSense feature work is largely in place, but validation coverage is uneven across unit, widget, and integration layers, and there is no thesis-ready structure that systematically proves loading/error/offline behavior, responsive layouts, the irrigation command pipeline, and the core invariant that Q1–Q4 are monitoring-only while one centralized pump/valve serves the entire field. This change establishes that validation suite before final documentation and defense.

## What Changes

- Expand **unit tests** for domain models, repositories, AWD analysis, authentication state, irrigation command handling, data transformations, and error mapping.
- Expand **widget tests** for dashboard, field monitoring, Q1–Q4 zone details, AWD analytics, centralized irrigation control, alerts, device diagnostics, authentication, and settings.
- Add **integration tests** for navigation, auth flow, API integration, real-time updates, offline behavior, and centralized irrigation command workflows (mocked pipeline).
- Validate **responsive behavior** for ~360–430px Android widths.
- Systematically cover **async UI states**: loading, empty, stale, offline, timeout, failure, and recovery.
- Add **architectural invariant tests** proving no Q1–Q4 independent irrigation controls exist in screens, models, APIs, or UI, and that irrigation is entire-field only.
- Validate the **irrigation command chain** Mobile → Backend API → messaging/LoRaWAN → central controller → pump/main valve using mocks/fixtures (no physical hardware required).
- Organize tests and documentation into a **clear validation structure** suitable for thesis chapters (purpose, scope, method, results mapping).

## Capabilities

### New Capabilities
- `mobile-validation`: Cross-cutting validation and test architecture for AquaSense—unit/widget/integration coverage expectations, responsive and async-state validation, Q1–Q4 vs centralized irrigation invariant proofs, mocked irrigation pipeline validation, and thesis-oriented validation documentation structure.

### Modified Capabilities
- *(none)* — Product feature requirements remain unchanged; this change adds validation obligations and test assets without altering runtime feature specs.

## Impact

- **Test suite**: Expands `test/` (and possibly `integration_test/`) with new and strengthened cases; reuses existing mocks/fakes where available.
- **Documentation**: Adds a validation/test map suitable for thesis documentation (e.g., under `docs/` or `test/README.md`).
- **CI readiness**: Tests should be runnable via `flutter test` (and integration harness if introduced) without physical LoRaWAN/hardware.
- **No production API/schema changes** expected; irrigation pipeline validation uses mocks/fixtures only.
- **Domain invariants preserved**: Q1–Q4 monitoring-only; single centralized field irrigation path.
