import 'api_client.dart';
import 'api_config.dart';
import 'api_repositories.dart';
import 'api_services.dart';

class ApiRepositoryFactory {
  final ApiClient client;
  late final AuthApiService auth;
  late final FieldApiService fields;
  late final AnalyticsApiService analytics;
  late final AlertApiService alerts;
  late final DeviceApiService devices;
  late final IrrigationApiService irrigation;

  ApiRepositoryFactory({
    ApiConfig? config,
    ApiClient? client,
  }) : client = client ?? ApiClient(config: config) {
    auth = AuthApiService(this.client);
    fields = FieldApiService(this.client);
    analytics = AnalyticsApiService(this.client);
    alerts = AlertApiService(this.client);
    devices = DeviceApiService(this.client);
    irrigation = IrrigationApiService(this.client);
  }

  ApiResourceRepositories get resources => ApiResourceRepositories(
        fields: fields,
        analytics: analytics,
        alerts: alerts,
        devices: devices,
        irrigation: irrigation,
      );

  void close() => client.close();
}
