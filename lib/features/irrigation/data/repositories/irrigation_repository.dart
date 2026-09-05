import '../../domain/models/centralized_irrigation.dart';
import '../datasources/irrigation_data_source.dart';

abstract class IrrigationRepository {
  Future<CentralizedIrrigation> fetchSystemStatus();
  Future<CentralizedIrrigation> toggleMainPump(bool active);
  Future<CentralizedIrrigation> updateSystemMode(SystemMode mode);
}

class IrrigationRepositoryImpl implements IrrigationRepository {
  final IrrigationDataSource _dataSource;

  IrrigationRepositoryImpl({IrrigationDataSource? dataSource})
      : _dataSource = dataSource ?? MockIrrigationDataSource();

  @override
  Future<CentralizedIrrigation> fetchSystemStatus() {
    return _dataSource.getSystemStatus();
  }

  @override
  Future<CentralizedIrrigation> toggleMainPump(bool active) {
    return _dataSource.toggleMainPumpSimulated(active);
  }

  @override
  Future<CentralizedIrrigation> updateSystemMode(SystemMode mode) {
    return _dataSource.setSystemModeSimulated(mode);
  }
}
