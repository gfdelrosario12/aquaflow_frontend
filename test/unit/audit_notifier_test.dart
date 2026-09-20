import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/audit/data/repositories/account_audit_repository.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_category.dart';
import 'package:aquaflow_frontend/features/audit/domain/models/audit_result.dart';
import 'package:aquaflow_frontend/features/audit/presentation/providers/audit_notifier.dart';

void main() {
  group('AuditNotifier Tests', () {
    late MockAccountAuditRepository repository;
    late AuditNotifier notifier;

    setUp(() {
      repository = MockAccountAuditRepository();
      notifier = AuditNotifier(repository: repository);
    });

    tearDown(() {
      notifier.dispose();
    });

    test('Initializes and loads mock events', () async {
      await Future.delayed(Duration.zero);
      expect(notifier.value.events.isNotEmpty, isTrue);
      expect(notifier.value.isLoading, isFalse);
    });

    test('Applies category and result filters', () async {
      await Future.delayed(Duration.zero);

      notifier.applyFilters(
        notifier.value.filters.copyWith(category: AuditCategory.authentication),
      );
      await Future.delayed(Duration.zero);

      for (final event in notifier.value.events) {
        expect(event.category, AuditCategory.authentication);
      }

      notifier.applyFilters(
        notifier.value.filters.copyWith(result: AuditResult.denied),
      );
      await Future.delayed(Duration.zero);

      for (final event in notifier.value.events) {
        expect(event.result, AuditResult.denied);
      }
    });

    test('Exports audit events to CSV and JSON formats', () async {
      await Future.delayed(Duration.zero);

      final csv = notifier.exportAuditEvents(isJson: false);
      expect(csv.contains('eventId,timestamp,actorType'), isTrue);

      final json = notifier.exportAuditEvents(isJson: true);
      expect(json.contains('"eventId":'), isTrue);
    });
  });
}

