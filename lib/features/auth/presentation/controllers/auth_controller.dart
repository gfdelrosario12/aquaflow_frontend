import 'package:flutter/foundation.dart';
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
  factory AuthState.authenticating() => const AuthState(status: AuthStatus.authenticating);
  factory AuthState.authenticated(UserSession session) =>
      AuthState(status: AuthStatus.authenticated, session: session);
  factory AuthState.unauthenticated([String? message]) =>
      AuthState(status: AuthStatus.unauthenticated, errorMessage: message);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated && session != null;
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
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = AuthState.authenticating();
    try {
      final session = await _authRepository.login(identifier, password);
      state = AuthState.authenticated(session);
      return true;
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      state = AuthState.error(message);
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

  AuthState get state => value;
  set state(AuthState newState) => value = newState;
}

final AuthNotifier globalAuthNotifier = AuthNotifier();
