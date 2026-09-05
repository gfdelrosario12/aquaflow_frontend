# AquaSense Mobile Validation Map

**Version**: 1.0  
**Thesis module**: AquaSense Mobile Application (Flutter)  
**Acceptance command**:

```bash
flutter test
```

No physical LoRaWAN, gateway, or pump hardware is required for any test in this
suite. All pipeline stages are exercised via deterministic mocks and fixtures.

---

## 1. Validation Architecture

The test suite is organised into a layered triangle:

```
┌──────────────────────────────────────────────────┐
│            Integration / Workflow                │  ← fewest, broadest scope
├──────────────────────────────────────────────────┤
│                 Widget tests                     │  ← per-screen UI coverage
├──────────────────────────────────────────────────┤
│                  Unit tests                      │  ← domain, repos, logic
└──────────────────────────────────────────────────┘
```

Cross-cutting concerns (responsive widths, async UI states, architectural
invariants, irrigation pipeline) are addressed by dedicated test files that
draw on shared helpers in `test/support/`.

---

## 2. Category Map

| # | Category | Purpose | Test file(s) |
|---|----------|---------|--------------|
| U | **Unit – Domain models & repos** | MonitoringZone, ZoneTrendAnalysis, AlertModel, DeviceDiagnostic, SettingsSnapshot, repo contracts | `test/unit/domain_and_mappers_test.dart`, `test/awd_analytics_test.dart`, `test/central_control_test.dart`, `test/alerts_test.dart`, `test/device_diagnostics_test.dart`, `test/settings_test.dart`, `test/auth_repository_test.dart` |
| U | **Unit – AWD analysis & mappers** | AwdRuleEngine, ZoneDryingRate, ApiMappers (zone, auth, telemetry) | `test/unit/domain_and_mappers_test.dart`, `test/awd_analytics_test.dart` |
| U | **Unit – Auth state & API errors** | AuthNotifier state machine, ApiException kinds (401/403/5xx/decode) | `test/unit/auth_and_irrigation_test.dart`, `test/auth_repository_test.dart`, `test/api_integration_test.dart` |
| U | **Unit – Irrigation command handling** | DTO rejection for Q1–Q4, MockControlRepository accept/reject, CommandOutcome | `test/unit/auth_and_irrigation_test.dart`, `test/central_control_test.dart` |
| W | **Widget – Dashboard & field screens** | HomeScreen states, FieldScreen Q1–Q4 grid, ZoneAnalysisScreen per-quadrant | `test/home_dashboard_test.dart`, `test/field_monitoring_test.dart`, `test/zone_analysis_test.dart` |
| W | **Widget – AWD, control, alerts, diagnostics** | AwdAnalyticsScreen, ControlScreen, AlertsScreen, DeviceDiagnosticsScreen | `test/awd_analytics_test.dart`, `test/central_control_test.dart`, `test/alerts_test.dart`, `test/device_diagnostics_test.dart` |
| W | **Widget – Auth & settings** | LoginScreen validation + error banner, SettingsScreen sections + guardrails | `test/login_screen_test.dart`, `test/settings_test.dart` |
| A | **Async UI states** | Loading → content, stale warning, empty state, offline banner, error, retry/recovery | `test/responsive_validation_test.dart` (async group), `test/home_dashboard_test.dart`, `test/zone_analysis_test.dart`, `test/awd_analytics_test.dart`, `test/device_diagnostics_test.dart`, `test/settings_test.dart` |
| R | **Responsive widths** | ~360px and ~430px Android viewports – no overflow, CTAs visible | `test/responsive_validation_test.dart` |
| I | **Architectural invariants** | Q1–Q4 monitoring-only; single ENTIRE FIELD pump/valve; DTO + widget + repo proofs | `test/architectural_invariant_test.dart` |
| P | **Irrigation pipeline** | Mobile → Backend API → gateway → controller → pump/valve (success/timeout/fail) | `test/irrigation_pipeline_test.dart` |
| F | **Integration / workflow** | Shell, auth flow, API fakes, realtime, offline/degraded irrigation gating | `test/integration/workflow_test.dart` |
| S | **Security** | HTTPS enforcement, token redaction, storage encryption, authorization | `test/mobile_security_test.dart` |

Legend: **U** = unit, **W** = widget, **A** = async-state, **R** = responsive,
**I** = invariant, **P** = pipeline, **F** = full-workflow, **S** = security.

---

## 3. Architectural Invariants (must remain true)

These invariants are automatically verified by `test/architectural_invariant_test.dart`
and cannot be broken without a test failure.

| # | Invariant | How it is proven |
|---|-----------|-----------------|
| I-1 | Q1, Q2, Q3, Q4 are **monitoring zones only** – no zone-level irrigation actuator in any screen | Widget tests assert `findsNothing` for forbidden labels in FieldScreen, ZoneAnalysisScreen, AwdAnalyticsScreen |
| I-2 | `IrrigationCommandDto` rejects any target that is not `ENTIRE FIELD` | Unit test: `toJson()` throws `FormatException` for Q1/Q2/Q3/Q4/ZONE-x |
| I-3 | `MockControlRepository.dispatchCommand` rejects non-`ENTIRE FIELD` commands with `CommandOutcome.rejected` | Repository unit test |
| I-4 | Centralized telemetry `target` always resolves to `CentralControlTelemetry.fixedTarget` | `ApiMappers.centralTelemetry` unit test + successful command dispatch |
| I-5 | Central controller device in diagnostics uses `targetScope = "ENTIRE FIELD"` | Diagnostics repository unit test |

---

## 4. Shared Test Helpers (`test/support/`)

| File | Exports | Used by |
|------|---------|---------|
| `fakes.dart` | `FakeHttpClient`, `fakeJsonResponse`, `MemorySecureStorage`, `FakeTokenStore`, `IrrigationPipelineFixture`, `PipelineStage` | pipeline, API, auth, integration tests |
| `zone_fixtures.dart` | `sampleZone`, `sampleFieldZones` | unit, invariant tests |
| `responsive.dart` | `setPhoneWidth` | responsive validation test |
| `connectivity.dart` | `FakeConnectivityProbe`, `ConnectivityNotifier`, `ConnectivityState` | offline, pipeline, integration tests |
| `index.dart` | Barrel export for all helpers above | convenience |

---

## 5. Test Coverage Inventory

| Area | Test file(s) | States covered |
|------|-------------|----------------|
| Auth – login widget | `login_screen_test.dart` | render, validation errors, error banner |
| Auth – repository | `auth_repository_test.dart` | login, restore, logout, token refresh |
| Auth – notifier state machine | `unit/auth_and_irrigation_test.dart` | initial → authenticated → unauthenticated, empty-credential rejection |
| Dashboard | `home_dashboard_test.dart` | normal, stale, empty, error, retry |
| Field monitoring | `field_monitoring_test.dart` | 2×2 grid, zone detail sheet, gateway error |
| Zone analysis Q1–Q4 | `zone_analysis_test.dart` | metrics, trend, 24h/7d toggle, error, read-only banner |
| AWD analytics | `awd_analytics_test.dart` | normal, insufficient-data, stale, error |
| Centralized control | `central_control_test.dart` | telemetry, start/stop, bad-scope reject, viewer-role reject, offline controller |
| Alerts | `alerts_test.dart` | list, severity/unread/search filters, detail, ENTIRE FIELD scope |
| Diagnostics | `device_diagnostics_test.dart` | 4 nodes + gateway + controller, filter, empty, error, read-only nodes |
| Settings | `settings_test.dart` | defaults, persistence, theme sync, save-fail rollback, screen sections |
| API integration | `api_integration_test.dart` | headers/token, retry, irrigation endpoints, 401 refresh, decode error |
| Realtime | `realtime_updates_test.dart` | event validation, dedup, order, degraded, lifecycle pause/resume |
| Offline / cache | `offline_support_test.dart` | freshness, put/get, connectivity transitions, gate, token scrub |
| Security | `mobile_security_test.dart` | HTTPS, redaction, secure storage, authorization |
| Domain models & mappers | `unit/domain_and_mappers_test.dart` | ZoneTrendAnalysis, AwdRuleEngine, ApiMappers |
| Auth + irrigation unit | `unit/auth_and_irrigation_test.dart` | AuthNotifier states, typed API errors, command rejection |
| Architectural invariants | `architectural_invariant_test.dart` | widget + DTO + repo invariants |
| Irrigation pipeline | `irrigation_pipeline_test.dart` | success (5 stages), timeout, gateway fail, ENTIRE FIELD only |
| Responsive validation | `responsive_validation_test.dart` | 360px + 430px for Home/Control/Field, async states, offline banner |
| Integration / workflow | `integration/workflow_test.dart` | shell, auth flow, API fakes, realtime, offline gating |

---

## 6. Evidence Checklist for Thesis Chapters

- [x] Unit evidence from `test/unit/` and feature unit groups
- [x] Widget evidence for each primary screen
- [x] Async-state evidence (loading, stale, empty, error, retry) per-screen
- [x] Responsive evidence from `responsive_validation_test.dart` at 360px & 430px
- [x] Architectural invariant evidence from `architectural_invariant_test.dart`
- [x] Pipeline evidence from `irrigation_pipeline_test.dart` (5 stages, timeout, fail)
- [x] Integration/workflow evidence from `test/integration/workflow_test.dart`
- [x] Full `flutter test` pass — see task 6.3 run log

---

## 7. Running the Suite

```bash
# Full suite (all layers)
flutter test

# Unit only
flutter test test/unit/

# Architectural invariants only
flutter test test/architectural_invariant_test.dart

# Pipeline only
flutter test test/irrigation_pipeline_test.dart

# Integration / workflow only
flutter test test/integration/

# Responsive + async-state only
flutter test test/responsive_validation_test.dart
```
