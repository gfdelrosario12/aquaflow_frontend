## Why

AquaSense currently relies on mock repositories, which limits the mobile application to simulated field, analytics, alert, device, gateway, and irrigation data. A production-ready REST integration is needed now to connect those existing domain abstractions to the backend without leaking transport details into UI or weakening the distinction between monitoring telemetry and centralized irrigation control.

## What Changes

- Add a shared HTTP client configuration with base URL, timeouts, request headers, structured response handling, authentication headers, token refresh integration, and bounded retry behavior for appropriate transient failures.
- Add API services and request/response DTOs with explicit serialization and mapping into existing domain models.
- Implement repository-backed REST data sources for authentication, fields, monitoring quarters, measurements, AWD analytics, alerts, devices, gateway status, centralized irrigation status, and centralized irrigation commands.
- Support the expected endpoint surface: `/api/auth/login`, `/api/auth/logout`, `/api/fields`, `/api/fields/{id}`, `/api/quarters`, `/api/quarters/{id}`, `/api/measurements`, `/api/analytics`, `/api/analytics/water-level`, `/api/irrigation/status`, `/api/irrigation/start`, `/api/irrigation/stop`, `/api/alerts`, `/api/devices`, and `/api/gateway`.
- Map network, authentication, validation, timeout, server, and decoding failures into repository/domain-facing errors suitable for existing UI state handling.
- Preserve mock implementations and repository contracts where practical so development and tests can switch data sources without changing domain consumers.
- Preserve architectural scope: Q1-Q4 can be queried independently for monitoring, while irrigation commands target only the centralized entire-field system; the mobile app will not communicate directly with LoRaWAN hardware.

## Capabilities

### New Capabilities
- `api-integration`: Provides the shared REST transport layer, API DTOs/services, error mapping, authentication lifecycle integration, and repository implementations for AquaSense backend data.

### Modified Capabilities

## Impact

- **Networking**: New HTTP client configuration, interceptors/middleware, timeout/retry policy, token storage/refresh integration, and API error mapping.
- **Data layer**: DTOs, serializers, mappers, and REST repository implementations for all listed backend resource areas.
- **Existing repositories**: Add production implementations while preserving domain interfaces and mock/test implementations.
- **Authentication**: Login/logout calls and access-token refresh behavior integrate with the existing auth state without duplicating auth policy in feature screens.
- **Irrigation safety**: Command adapters enforce `ENTIRE FIELD` targeting and never expose Q1-Q4 actuator commands or direct LoRaWAN communication.
- **Testing and configuration**: Environment/base-URL configuration, request-mocking tests, serialization tests, error/retry tests, auth lifecycle tests, and repository contract tests.
