## Validation Structure Map

Purpose: Maps validation categories and architectural invariants to test locations for thesis documentation and systematic test coverage.

### Unit Tests
| Category | Test Files | Evidence |
|----------|-----------|----------|
| Domain models and mappers | `test/domain_and_mappers_test.dart` | Entity and mapping logic coverage |
| AWD analysis | `test/awd_analytics_test.dart` | AWD decision logic tests |
| Authentication state | `test/auth_repository_test.dart`, `test/auth_and_irrigation_test.dart` | Auth transitions and error handling |
| Irrigation command handling | `test/irrigation_pipeline_test.dart`, `test/central_control_test.dart` | Command dispatch and validation |
| Repository contracts | `test/central_control_test.dart` | Control repository interface tests |
| Data transformations/mappers | `test/domain_and_mappers_test.dart` | Model-to-DTO mapping tests |

### Widget Tests
| Category | Test Files | Screens Covered |
|----------|-----------|----------------|
| Dashboard | `test/home_dashboard_test.dart` | Field dashboard |
| Field monitoring | `test/field_monitoring_test.dart` | Field monitoring view |
| Q1–Q4 zone detail/analysis | `test/zone_analysis_test.dart` | Zone Q1–Q4 analysis |
| AWD analytics | `test/awd_analytics_test.dart` | AWD analytics screen |
| Centralized irrigation control | `test/central_control_test.dart` | Irrigation control screen |
| Alerts | `test/alerts_test.dart` | Alerts screen |
| Device diagnostics | `test/device_diagnostics_test.dart` | Device diagnostics screen |
| Authentication | `test/login_screen_test.dart` | Login/auth screen |
| Settings | `test/settings_test.dart` | Settings screen |

### Integration/Workflow Tests
| Category | Test Files | Workflow Covered |
|----------|-----------|-----------------|
| Navigation shell | `test/realtime_updates_test.dart` | App navigation after auth |
| Authentication flow | `test/login_screen_test.dart` | Login → shell access |
| API integration with fakes | `test/api_integration_test.dart` | API calls with test doubles |
| Realtime updates | `test/realtime_updates_test.dart` | Live data streaming |
| Offline/degraded behavior | `test/offline_support_test.dart` | Offline mode handling |
| Centralized irrigation command workflows | `test/irrigation_pipeline_test.dart` | Mocked pipeline end-to-end |

### Architectural Invariants
| Invariant | Test File | Description |
|-----------|-----------|-------------|
| Q1–Q4 monitoring-only | `test/architectural_invariant_test.dart` | No independent irrigation actuators in zone views |
| Irrigation DTOs/repos accept only `ENTIRE FIELD` | `test/central_control_test.dart` | Target validation in control path |
| Centralized pump/valve system | `test/central_control_test.dart` | Single pump/valve telemetry |

### Async UI States
| State | Test Files | Screens |
|-------|-----------|---------|
| Loading | `test/*_test.dart` | Screens with loading presentations |
| Empty | `test/*_test.dart` | Screens with empty states |
| Stale | `test/*_test.dart` | Screens with stale data indication |
| Offline | `test/offline_support_test.dart` | Offline presentation |
| Timeout | `test/*_test.dart` | Timeout state handling |
| Failure | `test/*_test.dart` | Error/failure presentation |
| Recovery | `test/*_test.dart` | Recovery after failure |

### Responsive Validation
| Width | Screens | Test |
|-------|---------|------|
| ~360px | Dashboard, field monitoring, control | `responsive_validation_test.dart` |
| ~430px | Field monitoring | `responsive_validation_test.dart` |

### Irrigation Pipeline (Mocked)
| Scenario | Test File | Description |
|----------|-----------|-------------|
| Successful pipeline acknowledgment | `test/irrigation_pipeline_test.dart` | Mobile → API → gateway → controller → pump/valve |
| Pipeline timeout | `test/irrigation_pipeline_test.dart` | Timed-out command outcome |
| Pipeline failure | `test/irrigation_pipeline_test.dart` | Failed command outcome |
| Zone target rejection | `test/central_control_test.dart` | Q1–Q4 rejected, ENTIRE FIELD only |

### Thesis Documentation
| Document | Location | References |
|----------|----------|------------|
| Validation structure map | `test/VALIDATION.md` | This file — maps categories → test files → evidence |
| Zone fixtures | `test/support/zone_fixtures.dart` | Sample zone data for tests |
| Pipeline fixture | `test/support/fakes.dart` | IrrigationPipelineFixture for thesis pipeline tests |
| Responsive helpers | `test/support/responsive.dart` | Width override utilities for responsive tests |