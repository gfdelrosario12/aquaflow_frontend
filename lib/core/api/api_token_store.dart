import '../services/secure_storage_service.dart';

abstract class ApiTokenStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> writeTokens({required String accessToken, String? refreshToken});
  Future<void> clearTokens();
}

/// Persists only access/refresh tokens in secure platform storage.
/// Passwords and Authorization headers MUST never be written here.
class SecureApiTokenStore implements ApiTokenStore {
  static const accessTokenKey = 'aquasense_access_token';
  static const refreshTokenKey = 'aquasense_refresh_token';

  static const allowedKeys = {accessTokenKey, refreshTokenKey};

  final SecureStorageService storage;

  SecureApiTokenStore({SecureStorageService? storage})
      : storage = storage ?? SecureStorageServiceImpl();

  @override
  Future<String?> readAccessToken() => storage.read(key: accessTokenKey);

  @override
  Future<String?> readRefreshToken() => storage.read(key: refreshTokenKey);

  @override
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await storage.write(key: accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await storage.write(key: refreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<void> clearTokens() async {
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: refreshTokenKey);
  }
}
