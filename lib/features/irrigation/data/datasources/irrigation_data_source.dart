import '../../domain/models/centralized_irrigation.dart';

abstract class IrrigationDataSource {
  Future<CentralizedIrrigation> getSystemStatus();
  Future<CentralizedIrrigation> toggleMainPumpSimulated(bool active);
  Future<CentralizedIrrigation> setSystemModeSimulated(SystemMode mode);
}

class MockIrrigationDataSource implements IrrigationDataSource {
  CentralizedIrrigation _currentStatus = CentralizedIrrigation(
    id: 'sys-field-01',
    systemName: 'Main Field Central Irrigation',
    mainPumpState: PumpState.idle,
    distributionValveState: ValveState.closed,
    flowRateLitersPerMin: 0.0,
    pressureBar: 1.2,
    mode: SystemMode.scheduled,
    activeDurationMinutes: 0,
    lastStateChange: DateTime.now().subtract(const Duration(hours: 2)),
  );

  @override
  Future<CentralizedIrrigation> getSystemStatus() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _currentStatus;
  }

  @override
  Future<CentralizedIrrigation> toggleMainPumpSimulated(bool active) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentStatus = _currentStatus.copyWith(
      mainPumpState: active ? PumpState.active : PumpState.idle,
      distributionValveState: active ? ValveState.open : ValveState.closed,
      flowRateLitersPerMin: active ? 45.8 : 0.0,
      pressureBar: active ? 3.4 : 1.2,
      activeDurationMinutes: active ? 15 : 0,
      lastStateChange: DateTime.now(),
    );
    return _currentStatus;
  }

  @override
  Future<CentralizedIrrigation> setSystemModeSimulated(SystemMode mode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentStatus = _currentStatus.copyWith(
      mode: mode,
      lastStateChange: DateTime.now(),
    );
    return _currentStatus;
  }
}
