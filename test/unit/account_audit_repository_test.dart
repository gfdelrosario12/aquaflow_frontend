import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/audit/data/repositories/account_audit_repository.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/account_audit_event.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_actor.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_category.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_result.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_target.dart';

void main() {
  group('MockAccountAuditRepository Tests', () {
    late MockAccountAuditRepository repository;

    setUp(() {
      repository = MockAccountAuditRepository();
    });

    test('fetches seeded audit events', () async {
      final events = await repository.fetchAuditEvents();
      expect(events.isNotEmpty, isTrue);
    });

    test('filters by category', () async {
      final events = await repository.fetchAuditEvents(
        category: AuditCategory.authentication,
      );
      expect(events.every((e) => e.category == AuditCategory.authentication), isTrue);
    });

    test('emits and retrieves new audit event', () async {
      final newEvent = AccountAuditEvent(
        eventId: 'aud-custom-99',
        timestamp: DateTime.now(),
        actor: AuditActor.user('usr-99', 'Test User'),
        category: AuditCategory.system,
        action: 'system.test',
        target: const AuditTarget(type: 'test', id: 't-1'),
        result: AuditResult.success,
      );

      await repository.emitAuditEvent(newEvent);
      final fetched = await repository.fetchAuditEvent('aud-custom-99');
      expect(fetched, isNotNull);
      expect(fetched?.eventId, 'aud-custom-99');
    });
  });
}

