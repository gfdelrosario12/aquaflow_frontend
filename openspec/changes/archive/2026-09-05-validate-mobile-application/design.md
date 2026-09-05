## Context

AquaSense already has feature-level tests under `test/` (auth, dashboard, field/zone monitoring, AWD, control, alerts, diagnostics, settings, API, realtime, offline, security), but coverage depth, async-state matrices, responsive width checks, end-to-end irrigation pipeline fixtures, and a thesis-oriented validation map are incomplete. There is no `integration_test/` package yet. This change organizes and extends validation without changing product runtime behavior.

## Goals / Non-Goals

**Goals:**
- Define a layered validation architecture: unit → widget → integration (in-process / flutter_test and optional `integration_test`).
- Close gaps for domain/repository/AWD/auth/irrigation/error-path unit tests and screen widget coverage listed in the proposal.
- Prove the architectural invariant: Q1–Q4 are monitoring-only; irrigation is one centralized `ENTIRE FIELD` pump/valve path.
- Cover loading/empty/stale/offline/timeout/failure/recovery presentation where those states exist.
- Validate ~360–430px phone widths via widget surface size / MediaQuery overrides.
- Model the irrigation pipeline with mocks/fixtures (app → API → gateway/messaging → controller → actuators).
- Produce a clear validation document structure suitable for thesis documentation.

**Non-Goals:**
- Changing production feature UX or domain rules (except bugfixes discovered by tests).
- Physical LoRaWAN, gateway, or pump hardware in CI.
- Full device-farm / golden screenshot programs (optional later).
- Backend service implementation or live staging dependency for the default suite.
- Replacing existing passing tests wholesale—extend and organize instead.

## Decisions

### 1. Keep `flutter test` as the primary gate; add focused integration suites

- **Decision**: Expand `test/` for unit and widget coverage. Add either multi-feature “workflow” tests under `test/integration/` (preferred first) or `integration_test/` only if driver/device harness is required.
- **Rationale**: Existing suite already runs under `flutter test`; thesis validation can cite the same command. Full `integration_test` adds tooling cost without hardware.
- **Alternative considered**: Only `integration_test` was rejected as too heavy for default CI and thesis repro.

### 2. Shared test fixtures and fakes

- **Decision**: Centralize reusable fakes (HTTP client, connectivity probe, secure storage, control/auth repositories, realtime transport) under `test/support/` (or `test/helpers/`) to avoid duplication.
- **Rationale**: Integration workflows need consistent mocks for API, offline, and irrigation pipeline stages.
- **Alternative considered**: Copy-paste fakes per file was rejected as drift-prone.

### 3. Architectural invariant as executable tests

- **Decision**: Add dedicated invariant tests that (a) assert irrigation DTOs/repos reject Q1–Q4 targets, (b) assert zone/analysis/field widgets expose no Start/Stop irrigation actions, (c) assert control path uses `ENTIRE FIELD` only, and optionally (d) static/source scans for forbidden UI strings/APIs in monitoring features.
- **Rationale**: Thesis claims need falsifiable proofs, not narrative alone.
- **Alternative considered**: Manual checklist-only was rejected as non-repeatable.

### 4. Irrigation pipeline validation via staged mocks

- **Decision**: Represent pipeline stages as injectable seams or recorded call traces: Mobile command → `IrrigationApiService` → mock gateway acknowledgment → controller state update → pump/valve telemetry. Assert ordering, rejection, timeout, and no zone targeting.
- **Rationale**: Matches architecture without hardware; aligns with existing `MockControlRepository` / API fakes.
- **Alternative considered**: Live ChirpStack/hardware lab tests deferred outside this change.

### 5. Responsive validation via surface size

- **Decision**: Use `tester.view.physicalSize` / `tester.binding.setSurfaceSize` (or MediaQuery) at ~360 and ~430 logical widths for key screens; assert no overflow and primary CTAs remain reachable.
- **Rationale**: Matches stated Android phone band without needing many device profiles.
- **Alternative considered**: Full DevicePreview matrix deferred.

### 6. Thesis-oriented validation map

- **Decision**: Add `docs/validation/` (or `test/VALIDATION.md`) mapping requirements → test files → evidence categories (unit/widget/integration/invariant/pipeline/responsive/async-state) for chapter citation.
- **Rationale**: Separates runnable tests from documentation narrative.
- **Alternative considered**: Embedding long prose only in OpenSpec was rejected; thesis needs a durable doc artifact.

## Risks / Trade-offs

- **[Risk: Suite runtime grows]** → **Mitigation**: Keep integration workflows few and focused; prefer unit/widget for combinatorial async states.
- **[Risk: Flaky async/realtime tests]** → **Mitigation**: Use fake clocks, deterministic streams, and `pump`/`pumpAndSettle` with bounded timeouts.
- **[Risk: Over-asserting UI copy breaks on copy edits]** → **Mitigation**: Prefer keys/semantics and structural absence of controls over brittle full-string matching where possible.
- **[Risk: Static scans produce false positives]** → **Mitigation**: Limit scans to monitoring feature paths; combine with behavioral widget assertions.
- **[Risk: Incomplete product states lack hooks for testing]** → **Mitigation**: Prefer injecting notifiers/repositories; if a state cannot be reached, document gap and add minimal test seam rather than large refactors.

## Migration Plan

1. Add `test/support/` fixtures and validation doc skeleton.
2. Fill unit gaps (models, AWD, auth, irrigation, errors, mappers).
3. Strengthen widget coverage and async/responsive cases per screen.
4. Add invariant + irrigation pipeline workflow tests.
5. Wire documentation map; ensure `flutter test` passes as the acceptance gate.
6. Rollback is deletion of new tests/docs only—no production migration.

## Open Questions

- Prefer `test/integration/` workflows under `flutter test` only, or also introduce `integration_test/` for a thesis “end-to-end on emulator” appendix?
- Should forbidden-control checks include automated ripgrep in CI, or stay as Dart tests only?
- Exact thesis document path preference: `docs/validation/` vs single `test/VALIDATION.md`?
