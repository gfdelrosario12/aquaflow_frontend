import '../../../../core/api/api_mappers.dart';
import '../../../../core/api/api_services.dart';
import '../datasources/zone_data_source.dart';
import '../../domain/models/monitoring_zone.dart';
import 'zone_repository.dart';

class ApiZoneRepository implements ZoneRepository {
  final FieldApiService api;

  ApiZoneRepository(this.api);

  @override
  Future<List<MonitoringZone>> fetchMonitoringZones({
    ZoneMockState mockState = ZoneMockState.normal,
  }) async {
    final response = await api.listQuarters();
    return response.items.map(ApiMappers.monitoringZone).toList(growable: false);
  }

  @override
  Future<MonitoringZone?> fetchZoneDetails(
    String code, {
    ZoneMockState mockState = ZoneMockState.normal,
  }) async {
    final response = await api.getQuarter(code);
    return ApiMappers.monitoringZone(response);
  }
}
