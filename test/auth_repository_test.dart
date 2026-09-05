import 'dart:convert';
import 'package:aquaflow_frontend/core/services/secure_storage_service.dart';
import 'package:aquaflow_frontend/features/auth/data/datasources/auth_service.dart';
import 'package:aquaflow_frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:aquaflow_frontend/features/auth/domain/models/auth_token.dart';
import 'package:aquaflow_frontend/features/auth/domain/models/user_session.dart';
import 'package:flutter_test/flutter_test.dart';

class MemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
  }
}

void main() {
  group('AuthRepositoryImpl tests', () {
    late MockAuthService mockAuthService;
    late MemorySecureStorageService storageService;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockAuthService = MockAuthService();
      storageService = MemorySecureStorageService();
      repository = AuthRepositoryImpl(
        authService: mockAuthService,
        storageService: storageService,
      );
    });

    test('login succeeds and writes session to secure storage', () async {
      final session = await repository.login('operator@aquaflow.io', 'securepass');

      expect(session.userId, equals('usr_001'));
      expect(session.username, equals('operator'));
      expect(session.email, equals('operator@aquaflow.io'));

      final storedJson = await storageService.read(key: 'aquaflow_user_session');
      expect(storedJson, isNotNull);
    });

    test('restoreSession restores session when token is valid', () async {
      final session = await repository.login('operator@aquaflow.io', 'securepass');
      final restored = await repository.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.userId, equals(session.userId));
      expect(restored.token.accessToken, equals(session.token.accessToken));
    });

    test('logout purges stored session', () async {
      await repository.login('operator@aquaflow.io', 'securepass');
      await repository.logout();

      final restored = await repository.restoreSession();
      expect(restored, isNull);
    });

    test('restoreSession refreshes expired tokens', () async {
      final expiredToken = AuthToken(
        accessToken: 'expired_access',
        refreshToken: 'valid_refresh',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      final expiredSession = UserSession(
        userId: 'usr_001',
        username: 'operator',
        email: 'operator@aquaflow.io',
        role: 'Field Operator',
        token: expiredToken,
      );
      await storageService.write(
        key: 'aquaflow_user_session',
        value: jsonEncode(expiredSession.toJson()),
      );

      final restored = await repository.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.token.accessToken, contains('refreshed'));
    });
  });
}
