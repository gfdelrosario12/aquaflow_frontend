import 'dart:async';
import 'dart:convert';

import 'package:aquaflow_frontend/core/api/api_client.dart';
import 'package:aquaflow_frontend/core/api/api_config.dart';
import 'package:aquaflow_frontend/core/api/api_errors.dart';
import 'package:aquaflow_frontend/core/api/api_token_store.dart';
import 'package:aquaflow_frontend/core/security/sensitive_data_redactor.dart';
import 'package:aquaflow_frontend/core/services/secure_storage_service.dart';
import 'package:aquaflow_frontend/features/auth/data/datasources/auth_service.dart';
import 'package:aquaflow_frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:aquaflow_frontend/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aquaflow_frontend/features/control/data/repositories/control_repository.dart';
import 'package:aquaflow_frontend/features/control/domain/models/models.dart';
import 'package:aquaflow_frontend/features/control/presentation/providers/central_control_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _MemorySecureStorage implements SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<void> clearAll() async => values.clear();
}

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(this.handler);
  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => handler(request);
}

http.StreamedResponse _response(
  http.BaseRequest request,
  int status,
  String body,
) {
  return http.StreamedResponse(
    Stream.value(utf8.encode(body)),
    status,
    request: request,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  group('HTTPS and transport security', () {
    test('rejects insecure http base URLs without override', () {
      const config = ApiConfig(baseUrl: 'http://api.example.com');
      expect(config.isSecureTransport, isFalse);
      expect(
        () => config.ensureSecureTransport(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.transportSecurity,
          ),
        ),
      );
    });

    test('allows http only with explicit local/test override', () {
      const config = ApiConfig(
        baseUrl: 'http://localhost:8080',
        allowInsecureHttp: true,
      );
      expect(config.isSecureTransport, isTrue);
      expect(() => config.ensureSecureTransport(), returnsNormally);
    });

    test('ApiClient refuses insecure configuration before sending', () async {
      final client = ApiClient(
        config: const ApiConfig(baseUrl: 'http://insecure.example'),
        httpClient: _FakeHttpClient((request) async {
          fail('request should not be sent');
        }),
      );

      await expectLater(
        client.get('/api/fields'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.transportSecurity,
          ),
        ),
      );
    });
  });

  group('Sensitive data redaction', () {
    test('redacts Authorization headers and password fields', () {
      final headers = SensitiveDataRedactor.redactHeaders({
        'Authorization': 'Bearer super-secret',
        'Accept': 'application/json',
      });
      expect(headers['Authorization'], SensitiveDataRedactor.redacted);
      expect(headers['Accept'], 'application/json');

      final body = SensitiveDataRedactor.redactMap({
        'password': 'hunter2',
        'identifier': 'op@aquaflow.io',
      });
      expect(body['password'], SensitiveDataRedactor.redacted);
      expect(body['identifier'], 'op@aquaflow.io');

      expect(
        SensitiveDataRedactor.redactString('Authorization: Bearer abc.def'),
        contains(SensitiveDataRedactor.redacted),
      );
    });
  });

  group('Token-only secure storage', () {
    test('login persists session without password and clears tokens on failure',
        () async {
      final storage = _MemorySecureStorage();
      final tokenStore = SecureApiTokenStore(storage: storage);
      final repository = AuthRepositoryImpl(
        authService: MockAuthService(),
        storageService: storage,
        tokenStore: tokenStore,
      );

      await repository.login('operator@aquaflow.io', 'securepass');
      final sessionJson = storage.values['aquaflow_user_session']!;
      expect(sessionJson.contains('password'), isFalse);
      expect(await tokenStore.readAccessToken(), isNotNull);

      await repository.clearSession();
      expect(await tokenStore.readAccessToken(), isNull);
      expect(storage.values.containsKey('aquaflow_user_session'), isFalse);
    });

    test('AuthNotifier validates empty credentials and clears on auth failure',
        () async {
      final notifier = AuthNotifier(
        authRepository: AuthRepositoryImpl(
          authService: MockAuthService(),
          storageService: _MemorySecureStorage(),
        ),
      );

      expect(await notifier.login('', ''), isFalse);
      expect(notifier.state.status, AuthStatus.error);

      await notifier.login('operator@aquaflow.io', 'securepass');
      expect(notifier.state.isAuthenticated, isTrue);

      await notifier.handleAuthenticationFailure();
      expect(notifier.state.status, AuthStatus.unauthenticated);
      expect(notifier.state.session, isNull);
    });
  });

  group('API authorization and timeout mapping', () {
    test('maps 403 to authorization and does not retry POST', () async {
      var calls = 0;
      final client = ApiClient(
        config: const ApiConfig(baseUrl: 'https://example.test'),
        httpClient: _FakeHttpClient((request) async {
          calls++;
          return _response(request, 403, '{"message":"forbidden"}');
        }),
      );

      await expectLater(
        client.post('/api/irrigation/start', body: {'target': 'ENTIRE FIELD'}),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.authorization,
          ),
        ),
      );
      expect(calls, 1);
    });

    test('maps request timeout to typed timeout failure', () async {
      final client = ApiClient(
        config: const ApiConfig(
          baseUrl: 'https://example.test',
          connectTimeout: Duration(milliseconds: 1),
          receiveTimeout: Duration(milliseconds: 1),
          maxGetRetries: 0,
        ),
        httpClient: _FakeHttpClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return _response(request, 200, '{}');
        }),
      );

      await expectLater(
        client.get('/api/fields', retryable: false),
        throwsA(
          isA<ApiException>().having(
            (e) => e.kind,
            'kind',
            ApiErrorKind.timeout,
          ),
        ),
      );
    });
  });

  group('Irrigation security controls', () {
    test('blocks unauthenticated and unauthorized irrigation commands', () async {
      final repo = MockControlRepository();
      final unauthenticated = CentralControlNotifier(
        repository: repo,
        authenticated: false,
      );
      addTearDown(unauthenticated.dispose);

      final denied = await unauthenticated.startIrrigation(
        durationMinutes: 30,
        requestedBy: 'tester',
      );
      expect(denied.outcome, CommandOutcome.rejected);
      expect(denied.message, contains('Sign in'));

      final viewer = CentralControlNotifier(
        repository: repo,
        initialRole: ControlUserRole.viewer,
      );
      addTearDown(viewer.dispose);

      final unauthorized = await viewer.startIrrigation(
        durationMinutes: 30,
        requestedBy: 'viewer',
      );
      expect(unauthorized.outcome, CommandOutcome.rejected);
      expect(unauthorized.message, contains('Unauthorized'));
      expect(unauthorized.message.toLowerCase(), isNot(contains('q1')));
    });

    test('security rejection messages do not offer zone irrigation', () async {
      final notifier = CentralControlNotifier(
        repository: MockControlRepository(),
        initialRole: ControlUserRole.viewer,
      );
      addTearDown(notifier.dispose);

      final result = await notifier.stopIrrigation(requestedBy: 'viewer');
      expect(result.message.toLowerCase(), isNot(contains('zone')));
      expect(result.message.toLowerCase(), isNot(contains('q2')));
    });
  });
}
