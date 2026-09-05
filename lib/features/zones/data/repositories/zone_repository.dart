import '../../domain/models/monitoring_zone.dart';
import '../datasources/zone_data_source.dart';

abstract class ZoneRepository {
  Future<List<MonitoringZone>> fetchMonitoringZones({
    ZoneMockState mockState = ZoneMockState.normal,
  });
  Future<MonitoringZone?> fetchZoneDetails(
    String code, {
    ZoneMockState mockState = ZoneMockState.normal,
  });
}

class ZoneRepositoryImpl implements ZoneRepository {
  final ZoneDataSource _dataSource;

  ZoneRepositoryImpl({ZoneDataSource? dataSource})
      : _dataSource = dataSource ?? MockZoneDataSource();

  @override
  Future<List<MonitoringZone>> fetchMonitoringZones({
    ZoneMockState mockState = ZoneMockState.normal,
  }) {
    return _dataSource.getMonitoringZones(mockState: mockState);
  }

  @override
  Future<MonitoringZone?> fetchZoneDetails(
    String code, {
    ZoneMockState mockState = ZoneMockState.normal,
  }) {
    return _dataSource.getZoneByCode(code, mockState: mockState);
  }
}
