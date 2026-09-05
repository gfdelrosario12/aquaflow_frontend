import 'dart:convert';
import '../../../../core/services/secure_storage_service.dart';
import '../datasources/auth_service.dart';
import '../../domain/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> login(String identifier, String password);
  Future<UserSession?> restoreSession();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  static const String _sessionKey = 'aquaflow_user_session';

  final AuthService _authService;
  final SecureStorageService _storageService;

  AuthRepositoryImpl({
    AuthService? authService,
    SecureStorageService? storageService,
  })  : _authService = authService ?? MockAuthService(),
        _storageService = storageService ?? SecureStorageServiceImpl();

  @override
  Future<UserSession> login(String identifier, String password) async {
    final session = await _authService.login(identifier, password);
    final jsonStr = jsonEncode(session.toJson());
    await _storageService.write(key: _sessionKey, value: jsonStr);
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
      final session = UserSession.fromJson(jsonMap);

      if (session.token.isExpired) {
        try {
          final newToken = await _authService.refreshToken(session.token.refreshToken);
          final updatedSession = UserSession(
            userId: session.userId,
            username: session.username,
            email: session.email,
            role: session.role,
            token: newToken,
          );
          await _storageService.write(
            key: _sessionKey,
            value: jsonEncode(updatedSession.toJson()),
          );
          return updatedSession;
        } catch (_) {
          await _storageService.delete(key: _sessionKey);
          return null;
        }
      }

      final isValid = await _authService.validateToken(session.token.accessToken);
      if (!isValid) {
        await _storageService.delete(key: _sessionKey);
        return null;
      }

      return session;
    } catch (_) {
      await _storageService.delete(key: _sessionKey);
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
    await _storageService.delete(key: _sessionKey);
  }
}
