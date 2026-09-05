# AquaSense API Boundary

The API layer is configured with `--dart-define=AQUASENSE_API_BASE_URL=<url>`. When no value is provided, the client uses the development placeholder `https://api.aquasense.local`.

`ApiClient` owns JSON headers, access-token attachment, timeout/error mapping, bounded GET retries, and one-shot refresh replay. API services decode endpoint responses into DTOs; repository adapters map DTOs into existing feature domain models.

Use `ApiRepositoryFactory` to share one configured client across resource services. Existing mock repositories remain valid for tests and offline development.

Irrigation commands are intentionally non-retryable and require `ENTIRE FIELD`. Q1-Q4 identifiers are valid only for monitoring queries. The mobile app has no LoRaWAN, radio, BLE, or direct gateway hardware transport.
