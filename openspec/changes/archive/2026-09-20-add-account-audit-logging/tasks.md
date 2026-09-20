## 1. Domain Models and Schemas

- [x] 1.1 Define `AuditActor` model with `type` (user/system/emergencyOverride), `id`, and `displayName`
- [x] 1.2 Define `AuditCategory` enum with values: authentication, authorization, field-config, node-management, sensor-config, irrigation, security, system
- [x] 1.3 Define `AuditResult` enum with values: success, failed, denied, partial
- [x] 1.4 Define `AuditTarget` model with `type`, `id`, and optional `displayName`
- [x] 1.5 Define `AuditMetadata` model with `correlationId`, `requestId`, `clientIp`, `priorState`, `newState`, `rationale`, `failureReason`, and extensible JSON map
- [x] 1.6 Define `AccountAuditEvent` model with all required fields: `eventId`, `timestamp`, `actor`, `category`, `action`, `target`, `result`, `metadata`
- [x] 1.7 Add `toJson` and `fromJson` for all audit models
- [x] 1.8 Add equality and hashCode for all audit models

## 2. DTO and Mapper Layer

- [x] 2.1 Add `AuditActorDto`, `AuditCategoryDto`, `AuditResultDto`, `AuditTargetDto`, `AuditMetadataDto`, and `AccountAuditEventDto` to `lib/core/api/api_dtos.dart`
- [x] 2.2 Add `toJson` and `fromJson` for all audit DTOs
- [x] 2.3 Add `ApiMappers.auditActor`, `ApiMappers.auditCategory`, `ApiMappers.auditResult`, `ApiMappers.auditTarget`, `ApiMappers.auditMetadata`, and `ApiMappers.accountAuditEvent` to `lib/core/api/api_mappers.dart`
- [x] 2.4 Add `ApiMappers.accountAuditEventDto` for reverse mapping

## 3. API Service Layer

- [x] 3.1 Add `AccountAuditApiService` class to `lib/core/api/api_services.dart`
- [x] 3.2 Implement `getAuditEvents({String? category, String? actorId, String? targetType, String? targetId, DateTime? from, DateTime? to, int limit = 50, int offset = 0})` method
- [x] 3.3 Implement `getAuditEvent(String eventId)` method
- [x] 3.4 Note in code comments that `POST /api/audit/events` is backend-only and not exposed to frontend clients

## 4. Repository Layer

- [x] 4.1 Create `AccountAuditRepository` abstract class
- [x] 4.2 Implement `AccountAuditRepositoryImpl` with REST backend support
- [x] 4.3 Implement `MockAccountAuditRepository` for testing and offline development
- [x] 4.4 Wire `AccountAuditRepository` into `ApiRepositoryFactory`

## 5. State Management

- [x] 5.1 Create `AuditNotifier` with paginated loading, filtering, and real-time subscription
- [x] 5.2 Implement `loadAuditEvents()` method with filters
- [x] 5.3 Implement `loadAuditEventDetail(String eventId)` method
- [x] 5.4 Implement `subscribeToRealtime()` method to receive new audit events
- [x] 5.5 Implement `applyFilters()` method for category, actor, target, time range, and result filtering
- [x] 5.6 Implement `exportAuditEvents()` method for CSV/JSON export

## 6. UI Components

- [x] 6.1 Create `AuditHistoryScreen` under Settings → Admin → Audit History
- [x] 6.2 Implement filter UI: category multi-select, actor search, target search, time range picker, result filter
- [x] 6.3 Implement paginated audit event list with summary items
- [x] 6.4 Implement audit event detail view showing full metadata
- [x] 6.5 Implement export button (CSV/JSON)
- [x] 6.6 Implement real-time live feed toggle
- [x] 6.7 Restrict `AuditHistoryScreen` access to `fieldAdmin` and `admin` roles

## 7. Integration with Existing Domains

- [x] 7.1 Add audit emission to `AuthRepository` for login, logout, token refresh, and session expiration
- [x] 7.2 Add audit emission to `NodeRepository` for registration, reassignment, replacement, decommissioning, and interval configuration
- [x] 7.3 Add audit emission to `IrrigationNotifier` for manual and automatic irrigation events
- [x] 7.4 Add audit emission to `SettingsRepository` for configuration changes
- [x] 7.5 Add audit emission to security checkpoints for transport rejections and authorization denials
- [x] 7.6 Refactor `IrrigationExecutionAuditLog` to map to `AccountAuditEvent` in `IrrigationRepository`
- [x] 7.7 Update `IrrigationApiService` to use unified audit DTOs or maintain backward-compatible mapping

## 8. Real-Time Transport

- [x] 8.1 Add `auditEvent` to `RealtimeEventType` enum
- [x] 8.2 Implement validation for `auditEvent` payloads in `RealtimeCoordinator`
- [x] 8.3 Register adapter in `AuditNotifier` to ingest `auditEvent` real-time events
- [x] 8.4 Add deduplication and out-of-order handling for audit events

## 9. Testing

- [x] 9.1 Write unit tests for `AuditActor`, `AuditCategory`, `AuditResult`, `AuditTarget`, `AuditMetadata`, and `AccountAuditEvent` models
- [x] 9.2 Write unit tests for `AccountAuditEventDto` serialization/deserialization
- [x] 9.3 Write unit tests for `ApiMappers.accountAuditEvent` and `ApiMappers.accountAuditEventDto`
- [x] 9.4 Write unit tests for `AccountAuditRepositoryImpl` with mock API client
- [x] 9.5 Write unit tests for `AuditNotifier` filtering and pagination logic
- [x] 9.6 Write widget tests for `AuditHistoryScreen` filter UI and event list
- [x] 9.7 Write widget tests for `AuditHistoryScreen` access restriction based on role
- [x] 9.8 Write integration tests for audit emission in auth, node, irrigation, and settings flows

## 10. Documentation and Validation

- [x] 10.1 Update `lib/core/api/README.md` with audit API endpoint documentation
- [x] 10.2 Add inline comments to audit models and services
- [x] 10.3 Validate proposal, design, and spec artifacts with `openspec validate`
- [x] 10.4 Run `flutter analyze` and `flutter test` to ensure code quality