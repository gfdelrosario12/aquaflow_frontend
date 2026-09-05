import 'control_enums.dart';
import 'control_command_result.dart';

/// Aggregated telemetry state for the centralized field controller and hardware actuators
class CentralControlTelemetry {
  final String controllerId;
  final CentralControllerState controllerState;
  final PumpStatus pumpStatus;
  final MainValveStatus valveStatus;
  final IrrigationState irrigationState;
  final DateTime? startTime;
  final int? durationMinutes;
  final double flowRateLitersPerMin;
  final double linePressureBar;
  final DateTime lastUpdated;
  final ControlCommandResult? lastCommandResult;
  final String target;
  final bool isStale;

  static const String fixedTarget = 'ENTIRE FIELD';

  const CentralControlTelemetry({
    required this.controllerId,
    required this.controllerState,
    required this.pumpStatus,
    required this.valveStatus,
    required this.irrigationState,
    this.startTime,
    this.durationMinutes,
    required this.flowRateLitersPerMin,
    required this.linePressureBar,
    required this.lastUpdated,
    this.lastCommandResult,
    this.target = fixedTarget,
    this.isStale = false,
  });

  CentralControlTelemetry copyWith({
    String? controllerId,
    CentralControllerState? controllerState,
    PumpStatus? pumpStatus,
    MainValveStatus? valveStatus,
    IrrigationState? irrigationState,
    DateTime? startTime,
    int? durationMinutes,
    double? flowRateLitersPerMin,
    double? linePressureBar,
    DateTime? lastUpdated,
    ControlCommandResult? lastCommandResult,
    String? target,
    bool? isStale,
  }) {
    return CentralControlTelemetry(
      controllerId: controllerId ?? this.controllerId,
      controllerState: controllerState ?? this.controllerState,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      valveStatus: valveStatus ?? this.valveStatus,
      irrigationState: irrigationState ?? this.irrigationState,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      flowRateLitersPerMin: flowRateLitersPerMin ?? this.flowRateLitersPerMin,
      linePressureBar: linePressureBar ?? this.linePressureBar,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastCommandResult: lastCommandResult ?? this.lastCommandResult,
      target: target ?? this.target,
      isStale: isStale ?? this.isStale,
    );
  }
}

