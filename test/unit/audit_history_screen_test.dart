import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/audit/data/repositories/account_audit_repository.dart';
import 'package:aquaflow_frontend/features/audit/presentation/audit_history_screen.dart';
import 'package:aquaflow_frontend/features/audit/presentation/providers/audit_notifier.dart';
import 'package:aquaflow_frontend/features/auth/domain/models/user_role.dart';

void main() {
  group('AuditHistoryScreen Widget Tests', () {
    late MockAccountAuditRepository repository;
    late AuditNotifier notifier;

    setUp(() {
      repository = MockAccountAuditRepository();
      notifier = AuditNotifier(repository: repository);
    });

    tearDown(() {
      notifier.dispose();
    });

    testWidgets('Renders audit history screen with list items for Admin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuditHistoryScreen(
            userRole: UserRole.fieldAdmin,
            notifier: notifier,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unified Account Audit History'), findsOneWidget);
      expect(find.text('Maria Santos (Admin)'), findsOneWidget);
      expect(find.text('Auto-AWD Supervisor'), findsOneWidget);
    });

    testWidgets('Shows access restricted view for unauthorized Operator role', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuditHistoryScreen(
            userRole: UserRole.operator,
            notifier: notifier,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Access Restricted'), findsOneWidget);
      expect(find.textContaining('requires Administrator or Field Admin privileges'), findsOneWidget);
    });

    testWidgets('Tapping audit event opens detail bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AuditHistoryScreen(
            userRole: UserRole.fieldAdmin,
            notifier: notifier,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final firstTile = find.text('Maria Santos (Admin)').first;
      await tester.tap(firstTile);
      await tester.pumpAndSettle();

      expect(find.text('Audit Event Detail'), findsOneWidget);
      expect(find.text('aud-101'), findsOneWidget);
    });
  });
}

