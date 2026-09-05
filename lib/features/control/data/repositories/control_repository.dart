import 'dart:async';
import '../../domain/models/models.dart';

abstract class ControlRepository {
  /// Fetch current real-time telemetry from the central irrigation controller
  Future<CentralControlTelemetry> getCentralTelemetry();

  /// Dispatch a control command (Start/Stop Field Irrigation) through the backend API / LoRaWAN pipeline
  Future<ControlCommandResult> dispatchCommand(ControlCommand command);

  /// Stream continuous central controller telemetry updates
  Stream<CentralControlTelemetry> watchCentralTelemetry();
}

class MockControlRepository implements ControlRepository {
  CentralControlTelemetry _currentTelemetry;
  final _controller = StreamController<CentralControlTelemetry>.broadcast();

  MockControlRepository({CentralControlTelemetry? initialTelemetry})
      : _currentTelemetry = initialTelemetry ??
            CentralControlTelemetry(
              controllerId: 'CTRL-FIELD-01',
              controllerState: CentralControllerState.online,
              pumpStatus: PumpStatus.off,
              valveStatus: MainValveStatus.closed,
              irrigationState: IrrigationState.idle,
              flowRateLitersPerMin: 0.0,
              linePressureBar: 1.2,
              lastUpdated: DateTime.now(),
              target: CentralControlTelemetry.fixedTarget,
              lastCommandResult: ControlCommandResult(
                commandId: 'CMD-INIT',
                type: CommandType.stopIrrigation,
                outcome: CommandOutcome.completed,
                message: 'System initialized in idle state.',
                timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              ),
            );

  @override
  Future<CentralControlTelemetry> getCentralTelemetry() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentTelemetry;
  }

  @override
  Stream<CentralControlTelemetry> watchCentralTelemetry() {
    return _controller.stream;
  }

  @override
  Future<ControlCommandResult> dispatchCommand(ControlCommand command) async {
    // Validate target scope
    if (command.target != CentralControlTelemetry.fixedTarget) {
      final result = ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.rejected,
        message: 'Invalid target "${command.target}". Irrigation control applies only to the ENTIRE FIELD.',
        timestamp: DateTime.now(),
      );
      return result;
    }

    // Validate authorization
    if (command.userRole == ControlUserRole.viewer) {
      return ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.rejected,
        message: 'Unauthorized: Viewer role cannot initiate field irrigation controls.',
        timestamp: DateTime.now(),
      );
    }

    // Simulate messaging gateway & hardware propagation delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Handle controller fault state simulation
    if (_currentTelemetry.controllerState == CentralControllerState.offline) {
      final result = ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.failed,
        message: 'Central controller is OFFLINE. LoRaWAN link unreachable.',
        timestamp: DateTime.now(),
      );
      _updateTelemetry(_currentTelemetry.copyWith(
        lastCommandResult: result,
        irrigationState: IrrigationState.error,
      ));
      return result;
    }

    if (_currentTelemetry.controllerState == CentralControllerState.emergencyStop) {
      final result = ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.rejected,
        message: 'Remote control locked out: Emergency physical stop engaged at central controller site.',
        timestamp: DateTime.now(),
      );
      _updateTelemetry(_currentTelemetry.copyWith(lastCommandResult: result));
      return result;
    }

    // Execute state transitions
    if (command.type == CommandType.startIrrigation) {
      final result = ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.acknowledged,
        message: 'Central controller acknowledged command. Main pump active, valve opened for ${command.durationMinutes}m.',
        timestamp: DateTime.now(),
      );
      _updateTelemetry(_currentTelemetry.copyWith(
        pumpStatus: PumpStatus.pumping,
        valveStatus: MainValveStatus.open,
        irrigationState: IrrigationState.irrigating,
        startTime: DateTime.now(),
        durationMinutes: command.durationMinutes,
        flowRateLitersPerMin: 185.5,
        linePressureBar: 3.4,
        lastUpdated: DateTime.now(),
        lastCommandResult: result,
      ));
      return result;
    } else {
      final result = ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.completed,
        message: 'Central controller acknowledged command. Main pump stopped, main valve closed.',
        timestamp: DateTime.now(),
      );
      _updateTelemetry(_currentTelemetry.copyWith(
        pumpStatus: PumpStatus.off,
        valveStatus: MainValveStatus.closed,
        irrigationState: IrrigationState.idle,
        startTime: null,
        durationMinutes: null,
        flowRateLitersPerMin: 0.0,
        linePressureBar: 1.1,
        lastUpdated: DateTime.now(),
        lastCommandResult: result,
      ));
      return result;
    }
  }

  void _updateTelemetry(CentralControlTelemetry updated) {
    _currentTelemetry = updated;
    _controller.add(_currentTelemetry);
  }

  void updateStateForTesting(CentralControlTelemetry testState) {
    _updateTelemetry(testState);
  }
}

