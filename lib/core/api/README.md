# AquaSense API Boundary

Configure the API layer with build-time defines — never commit production secrets:

```bash
flutter run \
  --dart-define=AQUASENSE_API_BASE_URL=https://api.example.com
```

| Define | Purpose |
|--------|---------|
| `AQUASENSE_API_BASE_URL` | Backend base URL. Default: `https://api.aquasense.local`. Production/staging **must** use `https:`. |
| `AQUASENSE_ALLOW_INSECURE_HTTP` | Set `true` only for local/test HTTP. Default `false`; insecure URLs are rejected. |

`ApiClient` owns JSON headers, access-token attachment, timeout/error mapping, bounded GET retries, one-shot refresh replay, HTTPS enforcement, and redacted request diagnostics. TLS uses the **platform trust store** — there is no trust-all or certificate-bypass path.

API services decode endpoint responses into DTOs; repository adapters map DTOs into existing feature domain models.

Use `ApiRepositoryFactory` to share one configured client across resource services. Existing mock repositories remain valid for tests and offline development.

Irrigation commands are intentionally non-retryable and require `ENTIRE FIELD`. Q1-Q4 identifiers are valid only for monitoring queries. The mobile app has no LoRaWAN, radio, BLE, or direct gateway hardware transport.
