import 'package:aquaflow_frontend/features/auth/domain/models/auth_token.dart';
import 'package:aquaflow_frontend/features/auth/domain/models/user_role.dart';
import 'package:aquaflow_frontend/features/auth/domain/models/user_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole.fromString', () {
    test('parses field_admin', () {
      expect(UserRole.fromString('field_admin'), UserRole.fieldAdmin);
    });

    test('parses fieldadmin (no underscore)', () {
      expect(UserRole.fromString('fieldadmin'), UserRole.fieldAdmin);
    });

    test('parses operator', () {
      expect(UserRole.fromString('operator'), UserRole.operator);
    });

    test('parses viewer', () {
      expect(UserRole.fromString('viewer'), UserRole.viewer);
    });

    test('is case-insensitive', () {
      expect(UserRole.fromString('OPERATOR'), UserRole.operator);
      expect(UserRole.fromString('Viewer'), UserRole.viewer);
      expect(UserRole.fromString('Field_Admin'), UserRole.fieldAdmin);
    });

    test('returns null for unrecognized value', () {
      expect(UserRole.fromString('superuser'), isNull);
      expect(UserRole.fromString('admin'), isNull);
      expect(UserRole.fromString('root'), isNull);
    });

    test('returns null for empty string', () {
      expect(UserRole.fromString(''), isNull);
    });

    test('returns null for null input', () {
      expect(UserRole.fromString(null), isNull);
    });

    test('round-trips through claimValue', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromString(role.claimValue), equals(role));
      }
    });
  });

  group('UserRole.satisfies — permission ordering', () {
    test('fieldAdmin satisfies all roles', () {
      expect(UserRole.fieldAdmin.satisfies(UserRole.fieldAdmin), isTrue);
      expect(UserRole.fieldAdmin.satisfies(UserRole.operator), isTrue);
      expect(UserRole.fieldAdmin.satisfies(UserRole.viewer), isTrue);
    });

    test('operator satisfies operator and viewer but not fieldAdmin', () {
      expect(UserRole.operator.satisfies(UserRole.fieldAdmin), isFalse);
      expect(UserRole.operator.satisfies(UserRole.operator), isTrue);
      expect(UserRole.operator.satisfies(UserRole.viewer), isTrue);
    });

    test('viewer satisfies only viewer', () {
      expect(UserRole.viewer.satisfies(UserRole.fieldAdmin), isFalse);
      expect(UserRole.viewer.satisfies(UserRole.operator), isFalse);
      expect(UserRole.viewer.satisfies(UserRole.viewer), isTrue);
    });
  });

  group('UserSession.canPerform', () {
    AuthToken _token(UserRole? role) => AuthToken(
          accessToken: 'tok',
          refreshToken: 'ref',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          fieldId: role != null ? 'field_001' : null,
          role: role,
        );

    UserSession _session(UserRole? role) => UserSession(
          userId: 'usr_test',
          username: 'tester',
          email: 'tester@aquaflow.io',
          role: role?.displayLabel ?? 'unknown',
          token: _token(role),
        );

    test('null role — cannot perform any action', () {
      final session = _session(null);
      expect(session.canPerform(UserRole.viewer), isFalse);
      expect(session.canPerform(UserRole.operator), isFalse);
      expect(session.canPerform(UserRole.fieldAdmin), isFalse);
    });

    test('viewer — only viewer-level permitted', () {
      final session = _session(UserRole.viewer);
      expect(session.canPerform(UserRole.viewer), isTrue);
      expect(session.canPerform(UserRole.operator), isFalse);
      expect(session.canPerform(UserRole.fieldAdmin), isFalse);
    });

    test('operator — viewer and operator permitted; fieldAdmin denied', () {
      final session = _session(UserRole.operator);
      expect(session.canPerform(UserRole.viewer), isTrue);
      expect(session.canPerform(UserRole.operator), isTrue);
      expect(session.canPerform(UserRole.fieldAdmin), isFalse);
    });

    test('fieldAdmin — all levels permitted', () {
      final session = _session(UserRole.fieldAdmin);
      expect(session.canPerform(UserRole.viewer), isTrue);
      expect(session.canPerform(UserRole.operator), isTrue);
      expect(session.canPerform(UserRole.fieldAdmin), isTrue);
    });

    test('hasValidFieldClaims false when role is null', () {
      expect(_session(null).hasValidFieldClaims, isFalse);
    });

    test('hasValidFieldClaims true when role and fieldId present', () {
      expect(_session(UserRole.operator).hasValidFieldClaims, isTrue);
    });
  });
}
