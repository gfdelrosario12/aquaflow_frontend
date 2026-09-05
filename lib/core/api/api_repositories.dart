import 'api_dtos.dart';
import 'api_services.dart';

class ApiResourceRepositories {
  final FieldApiService fields;
  final AnalyticsApiService analytics;
  final AlertApiService alerts;
  final DeviceApiService devices;
  final IrrigationApiService irrigation;

  const ApiResourceRepositories({
    required this.fields,
    required this.analytics,
    required this.alerts,
    required this.devices,
    required this.irrigation,
  });

  Future<ResourceListDto> listFields() => fields.listFields();
  Future<ResourceDto> getField(String id) => fields.getField(id);
  Future<ResourceListDto> listQuarters() => fields.listQuarters();
  Future<ResourceDto> getQuarter(String id) => fields.getQuarter(id);
  Future<ResourceListDto> listMeasurements({String? quarterId}) =>
      fields.measurements(quarterId: quarterId);
  Future<ResourceDto> getAnalytics() => analytics.analytics();
  Future<ResourceDto> getWaterLevelAnalytics() => analytics.waterLevelAnalytics();
  Future<ResourceListDto> listAlerts() => alerts.listAlerts();
  Future<ResourceListDto> listDevices() => devices.listDevices();
  Future<ResourceDto> getGateway() => devices.gateway();
  Future<IrrigationResultDto> getIrrigationStatus() => irrigation.status();
}
