## 1. Transport and Authentication Foundation

- [x] 1.1 Add the HTTP client dependency and environment-aware API configuration for base URL, connect/receive timeouts, and JSON headers.
- [x] 1.2 Implement shared request execution, response decoding, redacted diagnostics, timeout handling, and typed transport/API error mapping.
- [x] 1.3 Implement bounded retry/backoff for eligible idempotent transient requests and explicitly exclude automatic retries for irrigation mutations.
- [x] 1.4 Integrate access-token storage, authorization header injection, coordinated refresh, one-time request replay, logout/session clearing, and auth login/logout service calls.

## 2. DTOs, Serialization, and API Services

- [x] 2.1 Create endpoint request/response DTOs and serializers for auth, fields, quarters, measurements, analytics, alerts, devices, and gateway resources.
- [x] 2.2 Create DTOs and serializers for centralized irrigation status, start, and stop requests/results with explicit `ENTIRE FIELD` scope.
- [x] 2.3 Implement API services for `/api/fields`, `/api/fields/{id}`, `/api/quarters`, `/api/quarters/{id}`, and `/api/measurements`.
- [x] 2.4 Implement API services for `/api/analytics`, `/api/analytics/water-level`, and `/api/alerts`.
- [x] 2.5 Implement API services for `/api/devices` and `/api/gateway`.
- [x] 2.6 Implement API services for `/api/irrigation/status`, `/api/irrigation/start`, and `/api/irrigation/stop` with non-idempotent command handling.

## 3. Domain Mapping and Repository Integration

- [x] 3.1 Add explicit DTO-to-domain mappers for authentication, fields, monitoring zones, measurements, AWD analytics, alerts, devices, gateway status, and irrigation telemetry.
- [x] 3.2 Implement REST-backed repository adapters that preserve existing feature repository interfaces and keep mock repositories injectable for tests/offline development.
- [x] 3.3 Select API-backed versus mock repositories through configuration without requiring feature screens or domain models to import HTTP/DTO types.
- [x] 3.4 Enforce monitoring query scope for independent Q1-Q4 reads and reject any zone-specific irrigation command before sending a request.

## 4. Configuration, Safety, and Documentation

- [x] 4.1 Document API base URL/environment configuration, endpoint contracts, error categories, token lifecycle, and repository replacement seams.
- [x] 4.2 Verify no feature introduces direct mobile-to-LoRaWAN, radio, BLE, or gateway hardware communication.
- [x] 4.3 Verify centralized irrigation commands remain field-level and use only the centralized control/backend boundary.

## 5. Verification

- [x] 5.1 Add serialization and mapper tests for valid, missing-field, malformed, and nullable API payloads.
- [x] 5.2 Add transport tests for headers, timeouts, typed errors, bounded retries, redacted diagnostics, token refresh, replay, and refresh failure.
- [x] 5.3 Add repository contract tests covering every service group and all required endpoint paths.
- [x] 5.4 Add safety tests proving Q1-Q4 monitoring queries remain read-only and irrigation mutations reject non-`ENTIRE FIELD` targets without network calls.
- [x] 5.5 Run `flutter analyze`, focused API integration tests, and the full `flutter test` suite.
