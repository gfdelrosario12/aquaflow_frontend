import '../../domain/models/auth_token.dart';
import '../../domain/models/user_session.dart';

abstract class AuthService {
  Future<UserSession> login(String identifier, String password);
  Future<AuthToken> refreshToken(String refreshToken);
  Future<bool> validateToken(String accessToken);
  Future<void> logout(String accessToken);
}

class MockAuthService implements AuthService {
  @override
  Future<UserSession> login(String identifier, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (identifier.trim().isEmpty || password.isEmpty) {
      throw Exception('Username/email and password cannot be empty.');
    }

    if (password == 'wrongpassword') {
      throw Exception('Invalid username or password.');
    }

    final token = AuthToken(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
    );

    return UserSession(
      userId: 'usr_001',
      username: identifier.contains('@')
          ? identifier.split('@').first
          : identifier,
      email: identifier.contains('@') ? identifier : '$identifier@aquaflow.io',
      role: 'Field Operator',
      token: token,
    );
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token is invalid or expired.');
    }

    return AuthToken(
      accessToken: 'mock_access_token_refreshed_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
    );
  }

  @override
  Future<bool> validateToken(String accessToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return accessToken.isNotEmpty && !accessToken.contains('invalid');
  }

  @override
  Future<void> logout(String accessToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
