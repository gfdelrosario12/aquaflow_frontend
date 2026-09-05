import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:aquaflow_frontend/core/api/api_token_store.dart';
import 'package:aquaflow_frontend/core/realtime/realtime_config.dart';
import 'package:aquaflow_frontend/core/realtime/realtime_coordinator.dart';
import 'package:aquaflow_frontend/core/realtime/realtime_events.dart';
import 'package:aquaflow_frontend/core/realtime/realtime_transport.dart';

void main() {
  test('validates typed event metadata and monitoring scope', () {
    final event = RealtimeEvent.fromJson(_eventJson(
      eventId: 'evt-1',
      eventType: 'water_measurement',
      scope: 'Q2',
      sequence: 4,
    ));

    expect(event.type, RealtimeEventType.measurement);
    expect(event.isMonitoringScope, isTrue);
    expect(event.toSafeLogMap(), isNot(contains('secret')));
  });

  test('rejects malformed, unsupported, and invalid-scope events', () {
    expect(
      () => RealtimeEvent.fromJson(_eventJson(version: 99)),
      throwsA(isA<RealtimeValidationException>()),
    );
    expect(
      () => RealtimeEvent.fromJson(_eventJson(eventType: 'unknown')),
      throwsA(isA<RealtimeValidationException>()),
    );
    expect(
      () => RealtimeEvent.fromJson(
        _eventJson(eventType: 'irrigation_state', scope: 'Q1'),
      ),
      throwsA(isA<RealtimeValidationException>()),
    );
  });

  test('coordinator authenticates, subscribes, deduplicates, and orders events', () async {
    final transport = FakeRealtimeTransport();
    final coordinator = RealtimeCoordinator(
      transport: transport,
      tokenStore: _FakeTokenStore('access-token'),
      config: RealtimeConfig(
        endpoint: Uri.parse('wss://example.test/realtime'),
        reconnectBaseDelay: Duration.zero,
      ),
    );
    addTearDown(() async {
      await coordinator.stop();
      coordinator.dispose();
      await transport.dispose();
    });
    final received = <RealtimeEvent>[];
    coordinator.addAdapter(received.add);

    await coordinator.start();
    transport.emit(_encode(_eventJson(eventId: 'evt-1', sequence: 2)));
    transport.emit(_encode(_eventJson(eventId: 'evt-1', sequence: 2)));
    transport.emit(_encode(_eventJson(eventId: 'evt-old', sequence: 1)));
    transport.emit(_encode(_eventJson(eventId: 'evt-2', sequence: 3)));
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.state.connection, RealtimeConnectionState.connected);
    expect(transport.subscriptions, hasLength(1));
    expect(received.map((event) => event.eventId), ['evt-1', 'evt-2']);
    expect(coordinator.latestEvents['Q1']?.eventId, 'evt-2');
  });

  test('invalid event enters degraded fallback state and retains valid cache', () async {
    var polls = 0;
    final transport = FakeRealtimeTransport();
    final coordinator = RealtimeCoordinator(
      transport: transport,
      tokenStore: _FakeTokenStore('access-token'),
      poll: () async => polls++,
      config: RealtimeConfig(
        endpoint: Uri.parse('wss://example.test/realtime'),
        staleAfter: Duration(milliseconds: 1),
      ),
    );
    addTearDown(() async {
      await coordinator.stop();
      coordinator.dispose();
      await transport.dispose();
    });

    await coordinator.start();
    transport.emit(_encode(_eventJson(eventId: 'evt-valid', sequence: 1)));
    transport.emit(_encode(_eventJson(eventId: 'evt-invalid', scope: 'Q9')));
    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(coordinator.latestEvents['Q1']?.eventId, 'evt-valid');
    expect(coordinator.state.isDegraded, isTrue);
    expect(polls, greaterThanOrEqualTo(0));
  });

  test('lifecycle pauses and resumes the authenticated session', () async {
    final transport = FakeRealtimeTransport();
    final coordinator = RealtimeCoordinator(
      transport: transport,
      tokenStore: _FakeTokenStore('access-token'),
      config: RealtimeConfig(endpoint: Uri.parse('wss://example.test/realtime')),
    );
    addTearDown(() async {
      await coordinator.stop();
      coordinator.dispose();
      await transport.dispose();
    });

    await coordinator.start();
    await coordinator.handleLifecycle(AppLifecycleState.paused);
    expect(coordinator.state.connection, RealtimeConnectionState.disconnected);
    await coordinator.handleLifecycle(AppLifecycleState.resumed);
    expect(coordinator.state.connection, RealtimeConnectionState.connected);
    expect(transport.connectCount, 2);
  });
}

Map<String, dynamic> _eventJson({
  int version = 1,
  String eventId = 'evt-default',
  String eventType = 'measurement',
  String scope = 'Q1',
  int sequence = 1,
}) {
  return {
    'version': version,
    'eventId': eventId,
    'eventType': eventType,
    'occurredAt': DateTime.utc(2026, 1, 1).toIso8601String(),
    'sequence': sequence,
    'scope': scope,
    'payload': {'value': 12.5, 'secret': 'do-not-log'},
  };
}

String _encode(Map<String, dynamic> event) =>
    '{"version":${event['version']},"eventId":"${event['eventId']}","eventType":"${event['eventType']}","occurredAt":"${event['occurredAt']}","sequence":${event['sequence']},"scope":"${event['scope']}","payload":{"value":12.5,"secret":"do-not-log"}}';

class _FakeTokenStore implements ApiTokenStore {
  final String accessToken;

  _FakeTokenStore(this.accessToken);

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => 'refresh-token';

  @override
  Future<void> writeTokens({required String accessToken, String? refreshToken}) async {}

  @override
  Future<void> clearTokens() async {}
}
