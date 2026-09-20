import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/core/realtime/realtime_events.dart';

void main() {
  group('RealtimeEvent Envelope & Scope Validation', () {
    test('parses valid dynamic node telemetry event', () {
      final json = {
        'version': 1,
        'eventId': 'evt-001',
        'eventType': 'lorawan_telemetry',
        'occurredAt': '2026-09-21T01:00:00Z',
        'sequence': 101,
        'scope': 'NODE-LORA-8F3A',
        'payload': {
          'soilMoisture': 42.5,
          'waterLevel': 12.0,
          'rssi': -75,
        },
      };

      final event = RealtimeEvent.fromJson(json);
      expect(event.version, equals(1));
      expect(event.eventId, equals('evt-001'));
      expect(event.type, equals(RealtimeEventType.lorawanTelemetry));
      expect(event.sequence, equals(101));
      expect(event.scope, equals('NODE-LORA-8F3A'));
      expect(event.isMonitoringScope, isTrue);
      expect(event.isEntireField, isFalse);

      final reencoded = event.toJson();
      expect(reencoded['eventId'], equals('evt-001'));
      expect(reencoded['eventType'], equals('lorawan_telemetry'));
      expect(reencoded['scope'], equals('NODE-LORA-8F3A'));
    });

    test('validates ENTIRE FIELD scope for manual control and irrigation events', () {
      final validJson = {
        'version': 1,
        'eventId': 'evt-002',
        'eventType': 'manual_control_executed',
        'occurredAt': '2026-09-21T01:00:00Z',
        'sequence': 102,
        'scope': 'ENTIRE FIELD',
        'payload': {
          'action': 'start',
          'durationMinutes': 20,
          'operatorId': 'op-123',
        },
      };

      final event = RealtimeEvent.fromJson(validJson);
      expect(event.isEntireField, isTrue);
      expect(event.type, equals(RealtimeEventType.manualControlExecuted));

      final invalidScopeJson = {
        'version': 1,
        'eventId': 'evt-003',
        'eventType': 'manual_control_executed',
        'occurredAt': '2026-09-21T01:00:00Z',
        'sequence': 103,
        'scope': 'Q1',
        'payload': {'action': 'start'},
      };

      expect(
        () => RealtimeEvent.fromJson(invalidScopeJson),
        throwsA(isA<RealtimeValidationException>()),
      );
    });

    test('validates dynamic node discovery and AWD analysis events', () {
      final discoveryJson = {
        'version': 1,
        'eventId': 'evt-disc-1',
        'eventType': 'node_discovered',
        'occurredAt': '2026-09-21T01:00:00Z',
        'sequence': 200,
        'scope': 'NODE-LORA-9999',
        'payload': {
          'id': 'NODE-LORA-9999',
          'macAddress': 'AA:BB:CC:DD:EE:FF',
          'hardwareModel': 'ESP32 LoRaWAN',
        },
      };

      final discEvent = RealtimeEvent.fromJson(discoveryJson);
      expect(discEvent.type, equals(RealtimeEventType.nodeDiscovered));

      final awdJson = {
        'version': 1,
        'eventId': 'evt-awd-1',
        'eventType': 'awd_analysis_completed',
        'occurredAt': '2026-09-21T01:00:00Z',
        'sequence': 201,
        'scope': 'ENTIRE FIELD',
        'payload': {
          'fieldStatus': 'safeDry',
          'averageWaterDepthCm': -4.5,
        },
      };

      final awdEvent = RealtimeEvent.fromJson(awdJson);
      expect(awdEvent.type, equals(RealtimeEventType.awdAnalysisCompleted));
    });

    test('rejects unsupported event version or missing required fields', () {
      final badVersion = {
        'version': 99,
        'eventId': 'evt-bad',
        'eventType': 'measurement',
        'occurredAt': '2026-09-21T01:00:00Z',
        'sequence': 1,
        'scope': 'Q1',
        'payload': {},
      };
      expect(() => RealtimeEvent.fromJson(badVersion), throwsA(isA<RealtimeValidationException>()));

      final missingPayload = {
        'version': 1,
        'eventId': 'evt-bad2',
        'eventType': 'measurement',
        'occurredAt': '2026-09-21T01:00:00Z',
        'sequence': 1,
        'scope': 'Q1',
      };
      expect(() => RealtimeEvent.fromJson(missingPayload), throwsA(isA<RealtimeValidationException>()));
    });
  });
}

