import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/account_audit_event.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_actor.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_category.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_metadata.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_result.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_target.dart';

void main() {
  group('Audit Models Tests', () {
    test('AuditActor factories and JSON serialization', () {
      final userActor = AuditActor.user('usr-1', 'Alice Operator');
      expect(userActor.type, AuditActorType.user);
      expect(userActor.id, 'usr-1');
      expect(userActor.displayName, 'Alice Operator');

      final json = userActor.toJson();
      final rehydrated = AuditActor.fromJson(json);
      expect(rehydrated, equals(userActor));

      final systemActor = AuditActor.system();
      expect(systemActor.type, AuditActorType.system);
    });

    test('AuditCategory and AuditResult serialization', () {
      expect(AuditCategory.authentication.toJson(), 'authentication');
      expect(AuditCategory.fromJson('nodeManagement'), AuditCategory.nodeManagement);
      expect(AuditCategory.fromJson('unknown'), AuditCategory.system);

      expect(AuditResult.success.toJson(), 'success');
      expect(AuditResult.fromJson('denied'), AuditResult.denied);
      expect(AuditResult.fromJson('invalid'), AuditResult.failed);
    });

    test('AuditTarget and AuditMetadata serialization', () {
      const target = AuditTarget(type: 'node', id: 'SN-001', displayName: 'Sensor 1');
      final targetJson = target.toJson();
      expect(AuditTarget.fromJson(targetJson), equals(target));

      const metadata = AuditMetadata(
        clientIp: '127.0.0.1',
        rationale: 'Test rationale',
        failureReason: null,
      );
      final metaJson = metadata.toJson();
      expect(AuditMetadata.fromJson(metaJson), equals(metadata));
    });

    test('AccountAuditEvent full lifecycle serialization', () {
      final now = DateTime.now();
      final event = AccountAuditEvent(
        eventId: 'evt-999',
        timestamp: now,
        actor: AuditActor.user('usr-2', 'Bob Admin'),
        category: AuditCategory.irrigation,
        action: 'irrigation.manual.start',
        target: const AuditTarget(type: 'pump', id: 'P-1'),
        result: AuditResult.success,
        metadata: const AuditMetadata(rationale: 'Manual override'),
      );

      final json = event.toJson();
      final rehydrated = AccountAuditEvent.fromJson(json);

      expect(rehydrated.eventId, event.eventId);
      expect(rehydrated.actor, equals(event.actor));
      expect(rehydrated.category, AuditCategory.irrigation);
      expect(rehydrated.result, AuditResult.success);
      expect(rehydrated.metadata.rationale, 'Manual override');
    });
  });
}

