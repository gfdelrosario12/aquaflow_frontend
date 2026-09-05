import 'api_client.dart';
import 'api_dtos.dart';

class AuthApiService {
  final ApiClient client;

  const AuthApiService(this.client);

  Future<AuthResponseDto> login({required String identifier, required String password}) async {
    final response = await client.post(
      '/api/auth/login',
      authorized: false,
      body: {'identifier': identifier, 'password': password},
    );
    return AuthResponseDto.fromJson(response);
  }

  Future<void> logout() async {
    await client.post('/api/auth/logout');
  }
}

class FieldApiService {
  final ApiClient client;

  const FieldApiService(this.client);

  Future<ResourceListDto> listFields() async =>
      ResourceListDto.fromJson(await client.get('/api/fields'));

  Future<ResourceDto> getField(String id) async =>
      ResourceDto.fromJson(await client.get('/api/fields/$id'));

  Future<ResourceListDto> listQuarters() async =>
      ResourceListDto.fromJson(await client.get('/api/quarters'));

  Future<ResourceDto> getQuarter(String id) async =>
      ResourceDto.fromJson(await client.get('/api/quarters/$id'));

  Future<ResourceListDto> measurements({String? quarterId}) async =>
      ResourceListDto.fromJson(
        await client.get(
          '/api/measurements',
          query: quarterId == null ? null : {'quarterId': quarterId},
        ),
      );
}

class AnalyticsApiService {
  final ApiClient client;

  const AnalyticsApiService(this.client);

  Future<ResourceDto> analytics() async =>
      ResourceDto.fromJson(await client.get('/api/analytics'));

  Future<ResourceDto> waterLevelAnalytics() async =>
      ResourceDto.fromJson(await client.get('/api/analytics/water-level'));
}

class AlertApiService {
  final ApiClient client;

  const AlertApiService(this.client);

  Future<ResourceListDto> listAlerts() async =>
      ResourceListDto.fromJson(await client.get('/api/alerts'));
}

class DeviceApiService {
  final ApiClient client;

  const DeviceApiService(this.client);

  Future<ResourceListDto> listDevices() async =>
      ResourceListDto.fromJson(await client.get('/api/devices'));

  Future<ResourceDto> gateway() async =>
      ResourceDto.fromJson(await client.get('/api/gateway'));
}

class IrrigationApiService {
  final ApiClient client;

  const IrrigationApiService(this.client);

  Future<IrrigationResultDto> status() async =>
      IrrigationResultDto.fromJson(await client.get('/api/irrigation/status'));

  Future<IrrigationResultDto> start({required int durationMinutes}) async =>
      IrrigationResultDto.fromJson(
        await client.post(
          '/api/irrigation/start',
          body: IrrigationCommandDto(
            durationMinutes: durationMinutes,
          ).toJson(),
        ),
      );

  Future<IrrigationResultDto> stop() async =>
      IrrigationResultDto.fromJson(
        await client.post(
          '/api/irrigation/stop',
          body: const IrrigationCommandDto().toJson(),
        ),
      );
}
