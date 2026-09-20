## Why

AquaSense currently records audit entries only for irrigation execution actions, leaving authentication attempts, authorization decisions, sensor-node lifecycle changes, field configuration edits, and other security-sensitive operations without a persistent, auditable trail. As the system moves toward production field deployment, operators and regulators need a single, tamper-resistant audit history that attributes every important account or system action to an explicit actor (authenticated human account or explicit system/automation actor), identifies the target/resource, captures result/status, and retains contextual metadata.

## What Changes

- **Generalize the audit trail beyond irrigation**: Introduce a domain-agnostic `AccountAuditEvent` model and append-only audit service that covers authentication events, authorization-sensitive operations, field configuration changes, sensor-node registration/removal/reassignment, sensor configuration, manual irrigation commands, automatic irrigation events, and other security-sensitive operations.
- **Explicit actor identity for every event**: Human actions must identify the authenticated account (`user/<userId>`). Automatic operations must use an explicit system/automation actor (`system/<automationId>`) rather than impersonating a human account. Emergency/override actions get a distinct actor type.
- **Unified audit event structure**: Every audit record must include a unique event ID, precise server-side timestamp, actor identity, action category, target/resource identifier, result/status, and contextual metadata (correlation IDs, IP/client info, prior state, rationale).
- **Server-side persistence with append-only, tamper-resistant design**: Audit records must be generated and persisted server-side and must not depend solely on Flutter local storage. The append-only log must be immutable in practice (no update/delete paths, sequential ordering, hash-chained or signed batches where practical).
- **Retention and access control**: Define retention windows, pruning policy for expired records, and role-based access restrictions so only authorized roles (`admin`, `auditor`, and where appropriate `operator`) can view audit history.
- **Failed operation handling**: Audit events must be emitted for both successful and failed/authorized-denied operations, including the failure reason and the authorization decision that led to the outcome.
- **Backend, database, API, security, and UI requirements**: Produce implementation-ready contracts for the audit database schema, REST endpoints, real-time events, authorization checks, and an authorized audit-history viewer UI.

## Capabilities

### New Capabilities
- `account-audit-logging`: Centralized, append-only, tamper-resistant audit trail covering authentication, authorization, configuration, node lifecycle, and irrigation actions with explicit human/system actor attribution, retention, access restrictions, and an authorized UI viewer.

### Modified Capabilities
- `user-authentication`: Emit audit events for login success/failure, logout, token refresh, session expiration, and unauthorized access attempts.
- `node-management`: Emit audit events for node discovery, registration, provisioning, assignment/reassignment, interval configuration, lifecycle transitions, replacement, and decommissioning.
- `centralized-irrigation`: Extend the existing irrigation audit log to use the unified `AccountAuditEvent` schema and ensure manual and automated cycles are attributed correctly.
- `api-integration`: Add REST endpoints for querying and (where authorized) exporting the unified audit log, plus real-time events for new audit entries.
- `settings`: Emit audit events for field configuration changes, safety parameter edits, and account/profile modifications performed through the settings surface.
- `mobile-security`: Emit audit events for security-relevant outcomes such as insecure transport rejection, certificate validation failures, and redaction-related diagnostics.

## Impact

- **Domain Models**: New `AccountAuditEvent`, `AuditActor`, `AuditCategory`, `AuditResult`, and `AuditMetadata` models under `lib/features/account-audit/` (or `lib/core/audit/`); generalize existing `IrrigationExecutionAuditLog` to reuse the unified schema.
- **API & Repositories**: New `AccountAuditApiService` endpoints (`GET /api/audit/events`, `GET /api/audit/events/{id}`, `POST /api/audit/events` for server-side emission contract) and `AccountAuditRepository` with mock and REST implementations.
- **State Management**: New `AuditNotifier` / `AuditHistoryProvider` for paging, filtering, and real-time ingestion of audit events.
- **UI**: New authorized `AuditHistoryScreen` with filters (category, actor, time range, target), paginated list, event detail view, and export capability; integration into Settings/Admin section.
- **Real-Time Transport**: New `auditEvent` real-time event type validated and fanned into the audit history UI.
- **Backend Contract**: Define audit table schema (append-only, indexed by timestamp/actor/target), retention/pruning policy, hash-chaining or signing guidance, and authorization checks for read access.
- **Dependencies**: No new third-party dependencies required; reuse existing `ApiClient`, `RealtimeCoordinator`, and secure storage patterns.