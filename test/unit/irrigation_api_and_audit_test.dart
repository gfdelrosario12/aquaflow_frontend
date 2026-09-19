import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/core/api/api_dtos.dart';
import 'package:aquaflow_frontend/core/api/api_mappers.dart';
import 'package:aquaflow_frontend/features/irrigation/domain/models/auto_irrigation_config.dart';
import 'package:aquaflow_frontend/features/irrigation/domain/models/auto_irrigation_status.dart';
import 'package:aquaflow_frontend/features/irrigation/domain/models/irrigation_execution_audit_log.dart';

void main() {
  group('AutoIrrigationConfig DTO serialization', () {
    test('round-trips domain -> DTO -> domain', () {
      final original = AutoIrrigationConfig(
        systemId: 'sys-field-01',
        isEnabled: true,
        maxDurationMinutes: 40,
        minCooldownMinutes: 90,
        allowedHoursStart: 7,
        allowedHoursEnd: 17,
        targetFloodDepthCm: 4.5,
        rainDelayEnabled: true,
        rainDelayHours: 12,
        minConfidenceThreshold: 0.8,
        updatedAt: DateTime.utc(2026, 9, 19, 8),
        updatedBy: 'op-01',
      );

      final dto = ApiMappers.autoIrrigationConfigDto(original);
      final restored = ApiMappers.autoIrrigationConfig(dto);

      expect(restored.systemId, equals(original.systemId));
      expect(restored.isEnabled, isTrue);
      expect(restored.maxDurationMinutes, equals(40));
      expect(restored.minCooldownMinutes, equals(90));
      expect(restored.allowedHoursStart, equals(7));
      expect(restored.allowedHoursEnd, equals(17));
      expect(restored.targetFloodDepthCm, equals(4.5));
      expect(restored.rainDelayHours, equals(12));
      expect(restored.minConfidenceThreshold, equals(0.8));
      expect(restored.updatedBy, equals('op-01'));
    });

    test('parses JSON payload with defaults for missing fields', () {
      final dto = AutoIrrigationConfigDto.fromJson({
        'systemId': 'sys-a',
        'isEnabled': true,
      });
      expect(dto.maxDurationMinutes, equals(45));
      expect(dto.minCooldownMinutes, equals(60));
      expect(dto.minConfidenceThreshold, equals(0.75));
    });
  });

  group('AutoIrrigationStatus DTO serialization', () {
    test('round-trips all supervisor states', () {
      for (final state in AutoIrrigationState.values) {
        final original = AutoIrrigationStatus(
          systemId: 'sys-field-01',
          state: state,
          activeCommandId: 'cmd-1',
          startedAt: DateTime.utc(2026, 9, 19, 10),
          targetDurationMinutes: 30,
          cooldownUntil: DateTime.utc(2026, 9, 19, 12),
          lastEvaluationTime: DateTime.utc(2026, 9, 19, 9, 55),
          lastEvaluationResult: 'ok',
          lockoutReason: state == AutoIrrigationState.faultLocked
              ? 'ACK timeout'
              : null,
          inhibitionReasons: const ['rainDelayActive'],
        );

        final dto = ApiMappers.autoIrrigationStatusDto(original);
        final restored = ApiMappers.autoIrrigationStatus(dto);

        expect(restored.state, equals(state));
        expect(restored.activeCommandId, equals('cmd-1'));
        expect(restored.targetDurationMinutes, equals(30));
        expect(restored.inhibitionReasons, contains('rainDelayActive'));
      }
    });

    test('fromJson tolerates unknown state strings', () {
      final status = AutoIrrigationStatus.fromJson({
        'systemId': 'sys-a',
        'state': 'unknown_future_state',
      });
      expect(status.state, equals(AutoIrrigationState.disabled));
    });
  });

  group('IrrigationActor attribution', () {
    test('system auto-awd actor has expected identity', () {
      const actor = IrrigationActor.systemAutoAwd;
      expect(actor.type, equals(IrrigationActorType.system));
      expect(actor.id, equals('auto-awd'));
      expect(actor.displayName, equals('System (Auto-AWD)'));
    });

    test('operator factory creates user actor', () {
      final actor = IrrigationActor.operator(id: 'u-42', name: 'Maria Santos');
      expect(actor.type, equals(IrrigationActorType.user));
      expect(actor.id, equals('u-42'));
      expect(actor.displayName, equals('Maria Santos'));
    });

    test('round-trips actor via DTO mapper', () {
      final system = IrrigationActor.systemAutoAwd;
      final operator = IrrigationActor.operator(id: 'op-1', name: 'Operator');

      expect(
        ApiMappers.irrigationActor(ApiMappers.irrigationActorDto(system)),
        equals(system),
      );
      expect(
        ApiMappers.irrigationActor(ApiMappers.irrigationActorDto(operator)),
        equals(operator),
      );
    });
  });

  group('IrrigationExecutionAuditLog mapping', () {
    test('round-trips automated start audit entry', () {
      final original = IrrigationExecutionAuditLog(
        id: 'log-100',
        systemId: 'sys-field-01',
        actor: IrrigationActor.systemAutoAwd,
        action: 'start',
        triggerContext: 'AWD Reflood Triggered (-15.2 cm)',
        triggeringDepthCm: -15.2,
        telemetryConfidenceScore: 0.88,
        cropStage: 'vegetative',
        targetDurationMinutes: 35,
        outcome: 'in_progress',
        timestamp: DateTime.utc(2026, 9, 19, 10),
      );

      final dto = ApiMappers.irrigationExecutionAuditLogDto(original);
      final restored = ApiMappers.irrigationExecutionAuditLog(dto);

      expect(restored.id, equals('log-100'));
      expect(restored.isSystemTriggered, isTrue);
      expect(restored.isManualOperator, isFalse);
      expect(restored.actor.displayName, equals('System (Auto-AWD)'));
      expect(restored.triggeringDepthCm, equals(-15.2));
      expect(restored.telemetryConfidenceScore, equals(0.88));
      expect(restored.targetDurationMinutes, equals(35));
    });

    test('round-trips operator abort audit entry', () {
      final original = IrrigationExecutionAuditLog(
        id: 'log-101',
        systemId: 'sys-field-01',
        actor: IrrigationActor.operator(id: 'op-01', name: 'Maria Santos'),
        action: 'stop',
        triggerContext: 'Operator abort',
        actualDurationMinutes: 12,
        outcome: 'aborted',
        timestamp: DateTime.utc(2026, 9, 19, 11),
      );

      final json = original.toJson();
      final restored = IrrigationExecutionAuditLog.fromJson(json);

      expect(restored.isManualOperator, isTrue);
      expect(restored.isSystemTriggered, isFalse);
      expect(restored.outcome, equals('aborted'));
      expect(restored.actor.displayName, equals('Maria Santos'));
    });

    test('DTO fromJson parses nested actor payload', () {
      final dto = IrrigationExecutionAuditLogDto.fromJson({
        'id': 'log-nested',
        'systemId': 'sys-a',
        'actor': {
          'type': 'system',
          'id': 'auto-awd',
          'displayName': 'System (Auto-AWD)',
        },
        'action': 'start',
        'triggerContext': 'auto',
        'outcome': 'completed',
        'timestamp': '2026-09-19T10:00:00.000Z',
      });

      final domain = ApiMappers.irrigationExecutionAuditLog(dto);
      expect(domain.actor, equals(IrrigationActor.systemAutoAwd));
      expect(domain.outcome, equals('completed'));
    });
  });
}
