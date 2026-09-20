import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/core/api/api_mappers.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/account_audit_event.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_actor.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_category.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_metadata.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_result.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_target.dart';

void main() {
  group('ApiMappers AccountAudit Tests', () {
    test('accountAuditEvent and accountAuditEventDto roundtrip', () {
      final domain = AccountAuditEvent(
        eventId: 'aud-777',
        timestamp: DateTime.parse('2026-09-20T10:00:00Z'),
        actor: AuditActor.user('usr-10', 'Operator Maria'),
        category: AuditCategory.nodeManagement,
        action: 'node.reassign',
        target: const AuditTarget(type: 'node', id: 'N-101', displayName: 'Node 101'),
        result: AuditResult.success,
        metadata: const AuditMetadata(rationale: 'Zone change'),
      );

      final dto = ApiMappers.accountAuditEventDto(domain);
      expect(dto.eventId, 'aud-777');
      expect(dto.category, 'nodeManagement');
      expect(dto.result, 'success');

      final rehydratedDomain = ApiMappers.accountAuditEvent(dto);
      expect(rehydratedDomain.eventId, domain.eventId);
      expect(rehydratedDomain.category, AuditCategory.nodeManagement);
      expect(rehydratedDomain.actor, equals(domain.actor));
    });
  });
}

