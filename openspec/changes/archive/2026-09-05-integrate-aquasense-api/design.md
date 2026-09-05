## Context

AquaSense currently exposes feature-specific repository abstractions backed by mock data. The production API must serve authentication, field and quarter monitoring, measurements, analytics, alerts, device diagnostics, gateway status, and centralized irrigation while preserving those domain boundaries. The mobile client is an HTTP consumer only; LoRaWAN communication remains behind the backend and gateway services.

## Goals / Non-Goals

**Goals:**
- Add one shared HTTP transport boundary with base URL configuration, request headers, timeouts, bounded retries, response decoding, and consistent error mapping.
- Separate API request/response DTOs and serializers from existing domain models through explicit mapper functions.
- Integrate access-token attachment and refresh into the existing authentication lifecycle without feature screens managing tokens.
- Provide REST service/repository implementations for every required endpoint while retaining mock implementations for tests and offline development.
- Enforce centralized irrigation command targeting (`ENTIRE FIELD`) and prevent Q1-Q4 monitoring resources from becoming actuator resources.

**Non-Goals:**
- Direct mobile-to-LoRaWAN, BLE, radio, or gateway hardware communication.
- Replacing existing domain models or redesigning feature UI contracts.
- Implementing backend services, database migrations, or undocumented endpoints.
- Retrying non-idempotent irrigation commands automatically.

## Decisions

### 1. Shared transport client with injectable configuration

- **Decision**: Add a single configured HTTP client with an injectable base URL, JSON headers, connect/receive timeouts, request correlation metadata, and an interceptor/middleware pipeline.
- **Rationale**: Centralizing transport policy prevents each repository from implementing different timeout, authentication, and error behavior.
- **Alternative considered**: Direct `http` calls in every repository were rejected because they duplicate policy and make testing transport behavior inconsistent.

### 2. DTO -> mapper -> domain pipeline

- **Decision**: API services decode JSON into endpoint-specific request/response DTOs; mappers convert DTOs into domain models consumed by existing repositories and notifiers.
- **Rationale**: Backend naming, nullability, envelope formats, and pagination can evolve without forcing UI/domain models to mirror the wire format.
- **Alternative considered**: Passing JSON maps into feature code was rejected because it removes compile-time contracts and spreads serialization logic.

### 3. Auth lifecycle owned by the auth data boundary

- **Decision**: Store access/refresh credentials behind an auth token provider. The transport attaches access tokens, handles one coordinated refresh after an unauthorized response, retries the original request once when safe, and clears session state when refresh fails. Login/logout use `/api/auth/login` and `/api/auth/logout` through the same service boundary.
- **Rationale**: Token behavior belongs to authentication infrastructure, not individual feature repositories, and coordinated refresh avoids concurrent refresh storms.
- **Alternative considered**: Each repository refreshing independently was rejected because it creates races and inconsistent logout behavior.

### 4. Explicit retry policy by request semantics

- **Decision**: Retry bounded transient failures for idempotent GET requests and selected transport failures with backoff. Do not automatically retry irrigation start/stop commands or other non-idempotent mutations unless the request carries an explicit idempotency contract.
- **Rationale**: Read resilience is useful, while duplicate actuator commands can be unsafe.
- **Alternative considered**: Retrying every request was rejected because it can duplicate centralized field commands.

### 5. Feature service grouping by backend resource

- **Decision**: Group API services around auth, fields/quarters, measurements/analytics, alerts, devices/gateway, and centralized irrigation. Repository implementations depend on these services and map results to existing feature contracts.
- **Rationale**: Resource grouping matches the endpoint surface while keeping repository ownership aligned with current feature abstractions.
- **Alternative considered**: One massive API service was rejected because it would become a cross-feature dependency hotspot.

### 6. Centralized irrigation safety boundary

- **Decision**: Monitoring calls accept Q1-Q4 identifiers for read/query operations. Irrigation command DTOs require `ENTIRE FIELD`; the repository rejects any zone-specific target before transport, and only `/api/irrigation/status`, `/api/irrigation/start`, and `/api/irrigation/stop` may mutate irrigation state.
- **Rationale**: The backend contract and mobile architecture must preserve one centralized actuator system.
- **Alternative considered**: Reusing quarter identifiers for commands was rejected because it implies independent zone controllers.

## Risks / Trade-offs

- **[Risk: API envelope or field names differ from assumptions]** -> **Mitigation**: Keep endpoint DTOs isolated, validate required fields, and map decoding failures to a typed API error with logging context.
- **[Risk: Expired tokens during concurrent requests]** -> **Mitigation**: Serialize refresh operations and replay at most one eligible request after refresh.
- **[Risk: Retrying a command duplicates irrigation activity]** -> **Mitigation**: Exclude non-idempotent commands from automatic retries and require explicit backend idempotency support before adding them.
- **[Risk: Slow or unavailable backend degrades existing screens]** -> **Mitigation**: Preserve mock repositories, expose loading/error states through existing notifiers, and make API repository selection injectable.
- **[Risk: Sensitive tokens or payloads appear in logs]** -> **Mitigation**: Redact authorization headers and command payload secrets from diagnostics and test logs.

## Migration Plan

1. Add the HTTP client, configuration, error types, token provider integration, DTOs, serializers, and mappers without changing existing feature consumers.
2. Implement API services and repository adapters alongside current mock repositories.
3. Add repository contract tests and transport tests using a mock HTTP adapter, including auth refresh and retry cases.
4. Introduce environment/configuration-based API repository selection for production while keeping mocks as the default for tests.
5. Roll back by selecting existing mock repositories; no domain or UI rollback is required because contracts remain stable.

## Open Questions

- What production base URLs and environment injection mechanism will be supplied for development, staging, and production?
- What exact authentication response and refresh endpoint does the backend expose beyond the required login/logout paths?
- Which GET endpoints support pagination, cursoring, or server-side filtering?
- Does the backend provide idempotency keys for centralized irrigation commands?
