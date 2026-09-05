enum RealtimeEventType {
  measurement,
  sensorStatus,
  gatewayStatus,
  irrigationState,
  irrigationEvent,
  controllerEvent,
  alert,
}

class RealtimeValidationException implements Exception {
  final String message;

  const RealtimeValidationException(this.message);

  @override
  String toString() => 'RealtimeValidationException: $message';
}

class RealtimeEvent {
  static const supportedVersion = 1;

  final int version;
  final String eventId;
  final RealtimeEventType type;
  final DateTime occurredAt;
  final int sequence;
  final String scope;
  final Map<String, dynamic> payload;

  const RealtimeEvent({
    required this.version,
    required this.eventId,
    required this.type,
    required this.occurredAt,
    required this.sequence,
    required this.scope,
    required this.payload,
  });

  String get aggregateKey => scope;

  bool get isMonitoringScope => const {'Q1', 'Q2', 'Q3', 'Q4'}.contains(scope);
  bool get isEntireField => scope == 'ENTIRE FIELD';

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    final version = _requiredInt(json, 'version');
    if (version != supportedVersion) {
      throw RealtimeValidationException('Unsupported event version: $version.');
    }
    final eventId = _requiredString(json, 'eventId');
    final eventType = _eventType(_requiredString(json, 'eventType'));
    final occurredAt = DateTime.tryParse(_requiredString(json, 'occurredAt'));
    if (occurredAt == null) {
      throw const RealtimeValidationException('Event occurredAt is invalid.');
    }
    final sequence = _requiredInt(json, 'sequence');
    final scope = _requiredString(json, 'scope');
    final rawPayload = json['payload'];
    if (rawPayload is! Map) {
      throw const RealtimeValidationException('Event payload must be an object.');
    }
    final payload = Map<String, dynamic>.from(rawPayload);
    final event = RealtimeEvent(
      version: version,
      eventId: eventId,
      type: eventType,
      occurredAt: occurredAt,
      sequence: sequence,
      scope: scope,
      payload: payload,
    );
    event._validateScope();
    return event;
  }

  void _validateScope() {
    final irrigationEvent = type == RealtimeEventType.irrigationState ||
        type == RealtimeEventType.irrigationEvent ||
        type == RealtimeEventType.controllerEvent;
    if (irrigationEvent && !isEntireField) {
      throw RealtimeValidationException(
        '${type.name} events require ENTIRE FIELD scope.',
      );
    }
    if (type == RealtimeEventType.measurement ||
        type == RealtimeEventType.sensorStatus) {
      if (!isMonitoringScope) {
        throw RealtimeValidationException(
          '${type.name} events require Q1-Q4 monitoring scope.',
        );
      }
    }
  }

  Map<String, Object?> toSafeLogMap() => {
        'version': version,
        'eventId': eventId,
        'eventType': type.name,
        'occurredAt': occurredAt.toIso8601String(),
        'sequence': sequence,
        'scope': scope,
        'payloadKeys': payload.keys.toList(growable: false),
      };

  static RealtimeEventType _eventType(String value) {
    switch (value) {
      case 'measurement':
      case 'water_measurement':
        return RealtimeEventType.measurement;
      case 'sensor_status':
        return RealtimeEventType.sensorStatus;
      case 'gateway_status':
        return RealtimeEventType.gatewayStatus;
      case 'irrigation_state':
        return RealtimeEventType.irrigationState;
      case 'irrigation_event':
        return RealtimeEventType.irrigationEvent;
      case 'controller_event':
        return RealtimeEventType.controllerEvent;
      case 'alert':
        return RealtimeEventType.alert;
      default:
        throw RealtimeValidationException('Unsupported event type: $value.');
    }
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw RealtimeValidationException('Event $key is required.');
    }
    return value;
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw RealtimeValidationException('Event $key must be an integer.');
  }
}
