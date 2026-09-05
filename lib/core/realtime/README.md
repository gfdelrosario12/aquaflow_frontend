# AquaSense Realtime Boundary

The Flutter app connects only to the backend-mediated realtime endpoint configured with `--dart-define=AQUASENSE_REALTIME_URL=<wss-url>`. LoRaWAN and MQTT ingestion remain backend responsibilities.

Events use a versioned envelope with `eventId`, `eventType`, `occurredAt`, `sequence`, `scope`, and `payload`. Monitoring measurements and sensor status may use `Q1` through `Q4`; irrigation state, irrigation events, and controller events require `ENTIRE FIELD`.

`RealtimeCoordinator` owns authentication-aware transport startup, lifecycle pause/resume, reconnect backoff, event validation, duplicate and out-of-order suppression, adapter fan-out, latest-event cache, and fallback polling state. Invalid events are discarded without mutating feature state. Event diagnostics expose metadata and payload keys only; tokens and command payload values are not logged.

The coordinator is transport-neutral and accepts `FakeRealtimeTransport` for tests. Existing REST repositories remain the bootstrap and fallback source when the channel is unavailable or stale.
