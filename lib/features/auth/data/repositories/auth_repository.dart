import 'dart:convert';
import '../../../../core/api/api_token_store.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../datasources/auth_service.dart';
import '../../domain/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login(String identifier, String password);
  Future<UserSession?> restoreSession();
  Future<void> logout();
  Future<void> clearSession();
}

class AuthRepositoryImpl implements AuthRepository {
  static const String _sessionKey = 'aquaflow_user_session';

  final AuthService _authService;
  final SecureStorageService _storageService;
  final ApiTokenStore? _tokenStore;

  AuthRepositoryImpl({
    AuthService? authService,
    SecureStorageService? storageService,
    ApiTokenStore? tokenStore,
  })  : _authService = authService ?? MockAuthService(),
        _storageService = storageService ?? SecureStorageServiceImpl(),
        _tokenStore = tokenStore;

  @override
  Future<UserSession> login(String identifier, String password) async {
    final trimmedId = identifier.trim();
    if (trimmedId.isEmpty || password.isEmpty) {
      throw Exception('Username/email and password cannot be empty.');
    }

    final session = await _authService.login(trimmedId, password);
    await _persistSession(session);
    return session;
  }

  @override
  Future<UserSession?> restoreSession() async {
    final jsonStr = await _storageService.read(key: _sessionKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }

    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (jsonMap.containsKey('password')) {
        await clearSession();
        return null;
      }
      final session = UserSession.fromJson(jsonMap);

      if (session.token.isExpired) {
        try {
          final newToken =
              await _authService.refreshToken(session.token.refreshToken);
          final updatedSession = UserSession(
            userId: session.userId,
            username: session.username,
            email: session.email,
            role: session.role,
            token: newToken,
          );
          await _persistSession(updatedSession);
          return updatedSession;
        } catch (_) {
          await clearSession();
          return null;
        }
      }

      final isValid =
          await _authService.validateToken(session.token.accessToken);
      if (!isValid) {
        await clearSession();
        return null;
      }

      await _tokenStore?.writeTokens(
        accessToken: session.token.accessToken,
        refreshToken: session.token.refreshToken,
      );
      return session;
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final jsonStr = await _storageService.read(key: _sessionKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        final session = UserSession.fromJson(jsonMap);
        await _authService.logout(session.token.accessToken);
      } catch (_) {}
    }
    await clearSession();
  }

  @override
  Future<void> clearSession() async {
    await _storageService.delete(key: _sessionKey);
    await _tokenStore?.clearTokens();
  }

  Future<void> _persistSession(UserSession session) async {
    final payload = session.toJson();
    // Never persist passwords — session JSON is profile + tokens only.
    payload.remove('password');
    await _storageService.write(
      key: _sessionKey,
      value: jsonEncode(payload),
    );
    await _tokenStore?.writeTokens(
      accessToken: session.token.accessToken,
      refreshToken: session.token.refreshToken,
    );
  }
}
