## 1. Domain Models & Configuration

- [x] 1.1 Create `AutoIrrigationConfig` model with safety ceilings, quiet hours, cooldown intervals, and rain delay settings in `lib/features/irrigation/domain/models/auto_irrigation_config.dart`
- [x] 1.2 Create `AutoIrrigationState` enum and `AutoIrrigationStatus` model representing supervisor lifecycle states (`disabled`, `standby`, `evaluating`, `pendingAck`, `irrigating`, `cooldown`, `faultLocked`) in `lib/features/irrigation/domain/models/auto_irrigation_status.dart`
- [x] 1.3 Create `IrrigationExecutionAuditLog` and `IrrigationActor` models distinguishing system-driven triggers from human operations in `lib/features/irrigation/domain/models/irrigation_execution_audit_log.dart`
- [x] 1.4 Extend `AwdRuleEngine` to evaluate `AwdAutomationEligibility` with decision eligibility flag, estimated run duration, and inhibition reasons in `lib/features/awd/domain/models/awd_automation_eligibility.dart`

## 2. API DTOs, Services & Repository Implementation

- [x] 2.1 Add DTOs and mappers for auto-irrigation config, auto-state, lockout clear, and execution audit log in `lib/core/api/api_dtos.dart` and `lib/core/api/api_mappers.dart`
- [x] 2.2 Extend `ApiService` with endpoints for auto-config, auto-state, lockout resolution, and audit history in `lib/core/api/api_services.dart`
- [x] 2.3 Extend `IrrigationRepository` with methods for automation config, live supervisor state, lockout clearance, and audit logging in `lib/features/irrigation/data/repositories/irrigation_repository.dart`
- [x] 2.4 Extend `IrrigationNotifier` to manage automatic supervisor state, cooldown timers, pre-flight safety interlock checks, and fault lockout recovery in `lib/features/irrigation/presentation/providers/irrigation_notifier.dart`

## 3. UI Integration & Operator Controls

- [x] 3.1 Update `ControlScreen` to display automatic irrigation supervisor status badge, cooldown countdown, and active automation state banners in `lib/features/control/presentation/control_screen.dart`
- [x] 3.2 Implement `AutoIrrigationConfigDialog` allowing operators to configure automatic mode toggles, safety duration limits, and quiet hours in `lib/features/control/presentation/widgets/auto_irrigation_config_dialog.dart`
- [x] 3.3 Implement `IrrigationAuditLogSection` displaying execution history with explicit `System (Auto-AWD)` vs `Operator` badges in `lib/features/control/presentation/widgets/irrigation_audit_log_section.dart`
- [x] 3.4 Update `FieldConditionHeaderCard` and `AwdAnalyticsScreen` to render automated eligibility chip and safety inhibition warnings when conditions prevent auto-irrigation

## 4. Verification & Testing Suite

- [x] 4.1 Add unit tests for `AwdAutomationEligibility` evaluation and inhibition rules in `test/unit/awd_automation_eligibility_test.dart`
- [x] 4.2 Add unit tests for `AutoIrrigationStatus` state transitions, pre-flight safety checks, and cooldown enforcement in `test/unit/auto_irrigation_state_machine_test.dart`
- [x] 4.3 Add unit tests for DTO serialization, domain mapping, and audit actor attribution in `test/unit/irrigation_api_and_audit_test.dart`
- [x] 4.4 Add widget tests for `ControlScreen` automatic status banner, config modal, and audit history display in `test/unit/control_screen_auto_irrigation_test.dart`
- [x] 4.5 Execute full static analysis (`dart analyze .`) and test suite (`flutter test`) ensuring 100% pass rate

