## Context

AquaSense frontend currently records audit logs exclusively for irrigation execution actions via `IrrigationExecutionAuditLog`. While the irrigation audit trail is robust—capturing automated/manual triggers, actor attribution, safety interlocks, and execution outcomes—other security-sensitive and system-relevant events lack a persistent, server-side audit trail. These include authentication events (login/logout, token refresh), authorization decisions, field configuration changes, sensor-node lifecycle operations (registration, provisioning, assignment, replacement, decommissioning), and settings modifications. As the system matures toward production deployment, operators, auditors, and regulators require a single, tamper-resistant audit history that attributes every important account or system action to an explicit actor (authenticated human account or explicit system/automation actor), identifies the target/resource, captures result/status, and retains contextual metadata.

## Goals / Non-Goals

**Goals:**
- Implement a domain-agnostic, append-only audit service (`AccountAuditEvent`) that covers authentication, authorization, configuration, node lifecycle, irrigation, and security-sensitive operations.
- Standardize the audit event schema: unique ID, server-side timestamp, actor identity (human: `user/<userId>` or system: `system/<automationId>`), action category, target/resource identifier, result/status, and contextual metadata.
- Ensure audit events are generated server-side for all significant operations (including failures) and persisted in an append-only, tamper-resistant log (no update/delete; practical immutability via sequencing or hash-chaining).
- Provide role-based access control (RBAC) for viewing audit history (`admin`, `fieldAdmin`, `auditor` roles; `operator` and `viewer` have limited or no access by default).
- Offer real-time audit event streaming via the existing real-time transport for live dashboards.
- Expose a REST API for paginated querying, filtering, and export of audit events.
- Authorize a dedicated `AuditHistoryScreen` in the Settings/Admin section for reviewing audit trails.
- Extend or refactor the existing irrigation audit log to reuse the unified schema, preserving backward compatibility where possible.

**Non-Goals:**
- Implement cryptographic signing or hardware-backed immutability (out of scope for frontend; recommend backend adoption).
- Modify non-audit domain models (e.g., user session, field topology) except to emit audit events on state changes.
- Provide direct edit or deletion capabilities for audit records (append-only by design).
- Build advanced analytics or correlation engines on audit data (focus on immutable record and basic querying).
- Introduce new third-party dependencies; reuse `ApiClient`, `RealtimeCoordinator`, and secure storage patterns.

## Decisions

### 1. Unified Audit Event Schema Over Irrigation-Specific Model
- **Approach**: Define a new `AccountAuditEvent` model with generic fields (`id`, `timestamp`, `actor`, `category`, `target`, `action`, `result`, `metadata`, `outcome`) that subsumes the irrigation-specific `IrrigationExecutionAuditLog`. Refactor irrigation audit to map to the unified schema.
- **Rationale**: Prevents duplication of audit logic across domains, ensures consistent querying/UI, and satisfies the requirement for a single audit history covering authentication, node lifecycle, config changes, etc.
- **Alternatives Considered**:
  - Keep irrigation audit separate and create a parallel audit service: leads to fragmented querying and UI, violates single audit history goal.
  - Extend `IrrigationExecutionAuditLog` with optional fields for other domains: complicates schema and retains irrigation-centric bias.

### 2. Actor Model: Explicit Human/System Attribution with Emergency Override Distinction
- **Approach**: Define `AuditActor` with `type` (human, system, emergencyOverride) and `id` (human: authenticated user ID; system: automation identifier like `auto-awd`, `node-provisioner`, `config-sync`). Emergency/override actions (e.g., manual irrigation stop during auto cycle) use `emergencyOverride` type to distinguish from standard human/system actions.
- **Rationale**: Clear attribution satisfies compliance needs; emergencyOverride captures critical interventions without misrepresenting them as routine human actions.
- **Alternatives Considered**:
  - Reuse `IrrigationActorType` (system/user/emergencyStop): irrigation-centric naming less appropriate for auth/node events.
  - Use only human/system types: loses nuance for override/emergency scenarios.

### 3. Server-Side Generation and Append-Only Persistence Contract
- **Approach**: Backend MUST generate audit events for all significant operations (success and failure) and persist them in an append-only table with columns matching `AccountAuditEvent`. Frontend SHALL not generate audit events locally; all audit records originate from backend API calls or real-time events.
- **Rationale**: Guarantees tamper resistance (frontend cannot forge or suppress events) and ensures a single source of truth. Append-only design supports immutability and simple retention policies.
- **Alternatives Considered**:
  - Allow frontend to emit audit events for offline operations: introduces risk of spoofing and gaps when offline.
  - Use local secure storage as primary audit trail: violates requirement to not depend solely on Flutter local storage.

### 4. API Endpoints: Query-First Design with Real-Time Subscription
- **Approach**: Provide REST endpoints:
  - `GET /api/audit/events`: paginated list with filters (category, actorId, targetType/targetId, time range, result).
  - `GET /api/audit/events/{id}`: single event detail.
  - `POST /api/audit/events`: internal/backend-only endpoint for emitting audit events (not exposed to frontend clients).
  - Real-time event type `auditEvent` fanned via `RealtimeCoordinator` for live UI updates.
- **Rationale**: Matches existing API patterns (e.g., `/api/irrigation/audit-log`) and leverages real-time transport for timely updates. Keeping emission backend-only preserves integrity.
- **Alternatives Considered**:
  - Expose POST endpoint to frontend: insecure; could allow false audit entries.
  - Use only REST polling: increases latency and battery drain.

### 5. Role-Based Access Control (RBAC) for Audit History
- **Approach**: Restrict access to audit history endpoints and UI to roles with `UserRole.fieldAdmin` or higher (`fieldAdmin`, plus a potential future `auditor` role). `operator` and `viewer` roles receive `403 Forbidden` when attempting to access audit logs. This decision can be refined later if operators need limited visibility (e.g., their own actions).
- **Rationale**: Audit logs often contain sensitive information (failed auth attempts, security events, configuration changes). Limiting access to administrators and auditors aligns with least privilege and data minimization principles.
- **Alternatives Considered**:
  - Grant `operator` read-only access: increases exposure of sensitive security events.
  - No RBAC (open to all authenticated users): excessive privilege for audit data.

### 6. Metadata Design for Context and Causality
- **Approach**: `AuditMetadata` is a free-form JSON map capturing domain-specific context: correlation IDs (to link related events), IP address/client IP, user agent, prior state, new state, rationale, failure reason, batch ID (for hash-chaining), etc.
- **Rationale**: Provides extensibility without schema changes; enables forensic analysis (e.g., linking a config change to a subsequent irrigation failure).
- **Alternatives Considered**:
  - Fixed metadata fields per category: inflexible and verbose schema.
  - Omit metadata: loses valuable contextual detail.

### 7. Migration: Refactor Irrigation Audit to Unified Schema
- **Approach**:
  1. Introduce `AccountAuditEvent` and `AuditActor` models alongside existing `IrrigationExecutionAuditLog`.
  2. Modify `IrrigationRepository` to map `IrrigationExecutionAuditLog` to/from `AccountAuditEvent` for backend communication.
  3. Update `IrrigationApiService` to use the unified DTOs (or maintain backward-compatible mapping).
  4. Deprecate irrigation-specific audit endpoints in favor of the unified `/api/audit/events` (with irrigation events filtered by category).
  5. Ensure UI components (`IrrigationAuditLogSection`) consume the unified audit service.
- **Rationale**: Preserves existing irrigation audit functionality while converging to the single audit history goal. Allows gradual cutover.
- **Alternatives Considered**:
  - Big-bang replacement: high risk, extensive testing required.
  - Leave irrigation audit separate: fails to unify audit history.

### 8. UI: Centralized Audit History Screen with Filtering
- **Approach**: Implement `AuditHistoryScreen` under Settings → Admin → Audit History. Features:
  - Timestamp range picker (relative: last hour/day/week/month; absolute).
  - Category filter (multi-select: auth, node, config, irrigation, security, etc.).
  - Actor filter (text search on actor ID or type).
  - Target filter (type/ID).
  - Result filter (success/failure).
  - Paginated list view showing condensed event summary.
  - Detail view showing full JSON metadata and raw payload.
  - Export button (CSV/JSON) for authorized roles.
  - Real-time subscription to new events (opt-in live feed).
- **Rationale**: Reuses existing settings UI patterns and provides administrators/auditors a dedicated workspace for compliance review.
- **Alternatives Considered**:
  - Embed audit log in existing screens (e.g., Control, Settings): insufficient filtering and context for audit review.
  - Build a separate admin-only app: overkill for current scope.

## Risks / Trade-offs

- **[Risk: Backend does not implement append-only audit table or emits inconsistent events]**  
  → *Mitigation*: Define strict API contract in spec; client-side validation of required fields; log malformed server events but do not crash; rely on backend team to fulfill contract.

- **[Risk: Audit log growth impacts storage and query performance over time]**  
  → *Mitigation*: Recommend backend implement partitioned tables by date, automated pruning/archival per retention policy, and indexed columns (timestamp, actorId, targetType). Frontend SHOULD support time-range filtering to limit payloads.

- **[Risk: Exposing audit history to operators risks leaking sensitive security information (e.g., failed auth attempts, internal error details)]**  
  → *Mitigation*: Start with restrictive RBAC (fieldAdmin+ only); if operator access is required, redact sensitive metadata fields (failure reasons, stack traces, internal IDs) in the UI for lower roles.

- **[Risk: Real-time audit event flood overwhelms UI or battery]**  
  → *Mitigation*: Debounce real-time updates; allow users to pause live feed; backend SHOULD not emit excessive granular events (e.g., per-telemetry packet).

- **[Risk: Incomplete audit coverage during offline mode or intermittent connectivity]**  
  → *Mitigation*: Audit events require successful backend roundtrip; offline actions will not be audited until reconnected (acceptable per server-side requirement). Document this limitation.

- **[Risk: Schema evolution breaks existing irrigation audit consumers]**  
  → *Mitigation*: Maintain backward-compatible mapping layer during transition; version audit DTOs if needed; provide clear deprecation timeline.

## Migration Plan

1. **Contract Definition**: Finalize `AccountAuditEvent` DTO, models, and API spec (this change).
2. **Backend Preparation**: Ensure audit table exists with append-only semantics; implement emission hooks for auth, node, config, irrigation, and security events.
3. **Frontend Models**: Add `account-audit/` feature with `AccountAuditEvent`, `AuditActor`, `AuditCategory`, `AuditResult`, `AuditMetadata`; refactor irrigation audit to use unified models.
4. **API Layer**: Extend `ApiServices` with `AccountAuditApiService` (GET endpoints) and note that emission is backend-only (POST not exposed).
5. **State Management**: Create `AuditNotifier` for paging, filtering, and real-time subscription; wire into `AppShell` or settings provider.
6. **UI Components**: Build `AuditHistoryScreen` with filters, list, detail, export; integrate into Settings/Admin.
7. **Irrigation Audit Cutover**: Modify irrigation repository/notifier to push/pull via unified audit service; retire irrigation-specific audit endpoints after validation.
8. **Event Coverage**: Add audit emission calls in auth repository, node repository, settings repository, irrigation notifier, and security checkpoints.
9. **Testing**: Write unit tests for models/mappers, widget tests for filters and UI, integration tests for API/mock repository.
10. **Documentation**: Update spec files for modified capabilities (user-authentication, node-management, etc.) to reflect new audit event requirements.

## Open Questions

- Should `operator` role have read-only access to their own audit events (e.g., login/logout, node actions they performed)? If so, need actor-id-based filtering in addition to role-based gating.
- Is there a need for a separate `auditor` role (distinct from `fieldAdmin`) focused purely on compliance review? If yes, define its permissions.
- What retention period should be mandated for audit logs (e.g., 1 year, 2 years, indefinite) and what pruning strategy (hard delete, archive to cold storage)?
- Should audit events include a hash-chain or signature field for cryptographic tamper evidence, or rely on procedural controls and append-only design?
- How should the frontend handle scenarios where backend audit emission fails (e.g., 5xx response)? Currently, the action proceeds but audit gap occurs; consider retry with dead-letter queue or local buffering with secure storage (with clear UI indication of pending audit).