import 'package:flutter/foundation.dart';
import '../../../../core/api/api_errors.dart';
import '../../../../core/security/sensitive_data_redactor.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_session.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserSession? session;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.authenticating() =>
      const AuthState(status: AuthStatus.authenticating);
  factory AuthState.authenticated(UserSession session) =>
      AuthState(status: AuthStatus.authenticated, session: session);
  factory AuthState.unauthenticated([String? message]) =>
      AuthState(status: AuthStatus.unauthenticated, errorMessage: message);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;
  bool get isAuthenticating => status == AuthStatus.authenticating;
}

class AuthNotifier extends ValueNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl(),
        super(AuthState.initial());

  Future<void> checkAuthStatus() async {
    state = AuthState.authenticating();
    try {
      final session = await _authRepository.restoreSession();
      if (session != null) {
        state = AuthState.authenticated(session);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (_) {
      await _authRepository.clearSession();
      state = AuthState.unauthenticated(
        'Your session could not be restored. Please sign in again.',
      );
    }
  }

  Future<bool> login(String identifier, String password) async {
    final trimmedId = identifier.trim();
    if (trimmedId.isEmpty || password.isEmpty) {
      state = AuthState.error('Username/email and password cannot be empty.');
      return false;
    }

    state = AuthState.authenticating();
    try {
      final session = await _authRepository.login(trimmedId, password);
      state = AuthState.authenticated(session);
      return true;
    } catch (e) {
      state = AuthState.error(_safeErrorMessage(e));
      return false;
    }
  }

  Future<void> logout() async {
    state = AuthState.authenticating();
    try {
      await _authRepository.logout();
    } catch (_) {}
    state = AuthState.unauthenticated();
  }

  /// Clears local session after refresh failure, 401, or other auth security events.
  Future<void> handleAuthenticationFailure([String? message]) async {
    await _authRepository.clearSession();
    state = AuthState.unauthenticated(
      message ?? 'Your session has expired. Please sign in again.',
    );
  }

  Future<void> handleApiSecurityFailure(ApiException error) async {
    if (error.kind == ApiErrorKind.authentication) {
      await handleAuthenticationFailure(
        'Your session has expired. Please sign in again.',
      );
      return;
    }
    if (error.kind == ApiErrorKind.authorization) {
      state = AuthState.error(
        'You are not authorized to perform this operation.',
      );
    }
  }

  String _safeErrorMessage(Object error) {
    if (error is ApiException) {
      return SensitiveDataRedactor.redactString(error.message);
    }
    final raw = error.toString().replaceAll('Exception: ', '');
    return SensitiveDataRedactor.redactString(raw);
  }

  AuthState get state => value;
  set state(AuthState newState) => value = newState;
}

final AuthNotifier globalAuthNotifier = AuthNotifier();
