import 'package:flutter/foundation.dart';
import '../../../../core/api/api_errors.dart';
import '../../../../core/security/sensitive_data_redactor.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/auth_token.dart';
import '../../domain/models/user_session.dart';
import '../../domain/models/user_role.dart';

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
  final String? fieldId;
  final UserRole? role;

  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
    this.fieldId,
    this.role,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.authenticating() =>
      const AuthState(status: AuthStatus.authenticating);
  factory AuthState.authenticated(UserSession session) {
    return AuthState(
      status: AuthStatus.authenticated,
      session: session,
      fieldId: session.fieldId,
      role: session.userRole,
    );
  }
  factory AuthState.unauthenticated([String? message]) =>
      AuthState(status: AuthStatus.unauthenticated, errorMessage: message);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;
  bool get isAuthenticating => status == AuthStatus.authenticating;

  bool get hasValidFieldClaims => session?.hasValidFieldClaims ?? false;

  bool canPerform(UserRole required) {
    final r = role;
    if (r == null) return false;
    return r.satisfies(required);
  }
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
        // Validate field-scoped claims; treat missing/unrecognized role as unauthorized
        if (!session.hasValidFieldClaims) {
          await _authRepository.clearSession();
          state = AuthState.unauthenticated(
            'Your session lacks required field authorization. Please sign in again.',
          );
          return;
        }
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
      // Ensure token has field-scoped claims parsed (from JWT if backend provides)
      final enrichedToken = AuthToken.withClaimsFromJwt(session.token);
      final enrichedSession = UserSession(
        userId: session.userId,
        username: session.username,
        email: session.email,
        role: session.role,
        token: enrichedToken,
      );
      state = AuthState.authenticated(enrichedSession);
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
    if (error.kind == ApiErrorKind.insufficientRole) {
      // Preserve session; surface role-insufficient warning without exposing claims
      state = AuthState.error(
        'You do not have permission to perform this action.',
      );
      return;
    }
    if (error.kind == ApiErrorKind.authorization) {
      // Legacy path - treat same as insufficientRole for backward compatibility
      state = AuthState.error(
        'You do not have permission to perform this action.',
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
