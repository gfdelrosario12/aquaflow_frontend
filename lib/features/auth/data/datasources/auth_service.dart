import '../../domain/models/auth_token.dart';
import '../../domain/models/user_role.dart';
import '../../domain/models/user_session.dart';

abstract class AuthService {
  Future<UserSession> login(String identifier, String password);
  Future<AuthToken> refreshToken(String refreshToken);
  Future<bool> validateToken(String accessToken);
  Future<void> logout(String accessToken);
}

/// Mock implementation used during development and tests.
///
/// Returns tokens with stub field-scoped claims so [UserSession.canPerform]
/// and [AuthorizationGate] work without a real backend.
///
/// By default, users are logged in as [UserRole.operator]. Pass a role-coded
/// password to override:
///   - `viewer_pass`   → UserRole.viewer
///   - `admin_pass`    → UserRole.fieldAdmin
///   - any other value → UserRole.operator
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

    final role = _roleFromPassword(password);
    final token = _stubToken(role: role);

    return UserSession(
      userId: 'usr_001',
      username: identifier.contains('@')
          ? identifier.split('@').first
          : identifier,
      email: identifier.contains('@') ? identifier : '$identifier@aquaflow.io',
      role: role.displayLabel,
      token: token,
    );
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token is invalid or expired.');
    }

    // Preserve the role encoded in the stub refresh token if possible.
    final role = _roleFromRefreshToken(refreshToken);
    return _stubToken(
      prefix: 'mock_access_token_refreshed',
      refreshToken: refreshToken,
      role: role,
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  UserRole _roleFromPassword(String password) {
    if (password == 'viewer_pass') return UserRole.viewer;
    if (password == 'admin_pass') return UserRole.fieldAdmin;
    return UserRole.operator;
  }

  UserRole _roleFromRefreshToken(String refreshToken) {
    if (refreshToken.contains('viewer')) return UserRole.viewer;
    if (refreshToken.contains('admin')) return UserRole.fieldAdmin;
    return UserRole.operator;
  }

  /// Returns a stub [AuthToken] with field-scoped claims embedded directly
  /// in the model fields (no real JWT encoding needed for mocks).
  AuthToken _stubToken({
    String prefix = 'mock_access_token',
    String? refreshToken,
    UserRole role = UserRole.operator,
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return AuthToken(
      accessToken: '${prefix}_${role.claimValue}_$ts',
      refreshToken: refreshToken ??
          'mock_refresh_token_${role.claimValue}_$ts',
      expiresAt: DateTime.now().add(const Duration(hours: 8)),
      fieldId: 'field_mock_001',
      role: role,
    );
  }
}
