import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_mappers.dart';
import '../../../../core/api/api_dtos.dart';
import '../../../../core/api/api_services.dart';
import '../../domain/models/auth_token.dart';
import '../../domain/models/user_session.dart';
import 'auth_service.dart';

class ApiAuthService implements AuthService {
  final AuthApiService api;
  final ApiClient client;

  ApiAuthService(this.client)
      : api = AuthApiService(client);

  @override
  Future<UserSession> login(String identifier, String password) async {
    final response = await api.login(identifier: identifier, password: password);
    return ApiMappers.userSession(response);
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    final response = await client.post(
      '/api/auth/refresh',
      authorized: false,
      body: {'refreshToken': refreshToken},
    );
    return ApiMappers.token(
      AuthResponseDto.fromJson(response),
    );
  }

  @override
  Future<bool> validateToken(String accessToken) async {
    return accessToken.isNotEmpty;
  }

  @override
  Future<void> logout(String accessToken) async {
    await api.logout();
  }
}
