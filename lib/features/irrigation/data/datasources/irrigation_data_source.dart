import '../../domain/models/auto_irrigation_config.dart';
import '../../domain/models/auto_irrigation_status.dart';
import '../../domain/models/centralized_irrigation.dart';
import '../../domain/models/irrigation_execution_audit_log.dart';

abstract class IrrigationDataSource {
  Future<CentralizedIrrigation> getSystemStatus();
  Future<CentralizedIrrigation> toggleMainPumpSimulated(bool active);
  Future<CentralizedIrrigation> setSystemModeSimulated(SystemMode mode);

  Future<AutoIrrigationConfig> getAutoIrrigationConfig({String systemId = 'default'});
  Future<AutoIrrigationConfig> saveAutoIrrigationConfig(AutoIrrigationConfig config);
  Future<AutoIrrigationStatus> getAutoIrrigationStatus({String systemId = 'default'});
  Future<AutoIrrigationStatus> clearFaultLockout({
    String systemId = 'default',
    String? resolutionNote,
    String? clearedBy,
  });
  Future<List<IrrigationExecutionAuditLog>> getAuditLogs({
    String systemId = 'default',
    int limit = 50,
  });
  Future<void> addAuditLog(IrrigationExecutionAuditLog log);
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

  AutoIrrigationConfig _autoConfig = const AutoIrrigationConfig(
    systemId: 'sys-field-01',
    isEnabled: false,
    maxDurationMinutes: 45,
    minCooldownMinutes: 60,
    allowedHoursStart: 6,
    allowedHoursEnd: 18,
    targetFloodDepthCm: 5.0,
    rainDelayEnabled: true,
    rainDelayHours: 24,
    minConfidenceThreshold: 0.75,
  );

  AutoIrrigationStatus _autoStatus = const AutoIrrigationStatus(
    systemId: 'sys-field-01',
    state: AutoIrrigationState.disabled,
  );

  final List<IrrigationExecutionAuditLog> _auditLogs = [
    IrrigationExecutionAuditLog(
      id: 'log-seed-01',
      systemId: 'sys-field-01',
      actor: IrrigationActor.systemAutoAwd,
      action: 'start',
      triggerContext: 'AWD Reflood Triggered (-15.2 cm)',
      triggeringDepthCm: -15.2,
      telemetryConfidenceScore: 0.88,
      cropStage: 'vegetative',
      targetDurationMinutes: 35,
      actualDurationMinutes: 35,
      outcome: 'completed',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    IrrigationExecutionAuditLog(
      id: 'log-seed-02',
      systemId: 'sys-field-01',
      actor: IrrigationActor.operator(
        id: 'op-01',
        name: 'Maria Santos',
      ),
      action: 'stop',
      triggerContext: 'Operator manual field stop after inspection',
      actualDurationMinutes: 10,
      outcome: 'completed',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  @override
  Future<CentralizedIrrigation> getSystemStatus() async {
    return _currentStatus;
  }

  @override
  Future<CentralizedIrrigation> toggleMainPumpSimulated(bool active) async {
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
    _currentStatus = _currentStatus.copyWith(
      mode: mode,
      lastStateChange: DateTime.now(),
    );
    return _currentStatus;
  }

  @override
  Future<AutoIrrigationConfig> getAutoIrrigationConfig({String systemId = 'default'}) async {
    return _autoConfig;
  }

  @override
  Future<AutoIrrigationConfig> saveAutoIrrigationConfig(AutoIrrigationConfig config) async {
    _autoConfig = config.copyWith(updatedAt: DateTime.now());
    if (!config.isEnabled) {
      _autoStatus = _autoStatus.copyWith(state: AutoIrrigationState.disabled);
    } else if (_autoStatus.state == AutoIrrigationState.disabled) {
      _autoStatus = _autoStatus.copyWith(state: AutoIrrigationState.standby);
    }
    return _autoConfig;
  }

  @override
  Future<AutoIrrigationStatus> getAutoIrrigationStatus({String systemId = 'default'}) async {
    return _autoStatus;
  }

  @override
  Future<AutoIrrigationStatus> clearFaultLockout({
    String systemId = 'default',
    String? resolutionNote,
    String? clearedBy,
  }) async {
    _autoStatus = _autoStatus.copyWith(
      state: _autoConfig.isEnabled ? AutoIrrigationState.standby : AutoIrrigationState.disabled,
      lockoutReason: null,
      lockoutTimestamp: null,
    );
    _auditLogs.insert(
      0,
      IrrigationExecutionAuditLog(
        id: 'log-${DateTime.now().millisecondsSinceEpoch}',
        systemId: systemId,
        actor: IrrigationActor.operator(id: clearedBy ?? 'operator', name: 'Operator $clearedBy'),
        action: 'lockout_cleared',
        triggerContext: resolutionNote ?? 'Fault lockout cleared by operator.',
        outcome: 'completed',
        timestamp: DateTime.now(),
      ),
    );
    return _autoStatus;
  }

  @override
  Future<List<IrrigationExecutionAuditLog>> getAuditLogs({
    String systemId = 'default',
    int limit = 50,
  }) async {
    return _auditLogs.take(limit).toList();
  }

  @override
  Future<void> addAuditLog(IrrigationExecutionAuditLog log) async {
    _auditLogs.insert(0, log);
  }
}
