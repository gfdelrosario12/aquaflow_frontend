import 'dart:async';

import '../../../../core/api/api_dtos.dart';
import '../../../../core/api/api_mappers.dart';
import '../../../../core/api/api_services.dart';
import '../../domain/models/models.dart';
import 'control_repository.dart';

class ApiControlRepository implements ControlRepository {
  final IrrigationApiService api;

  ApiControlRepository(this.api);

  @override
  Future<CentralControlTelemetry> getCentralTelemetry() async {
    final response = await api.status();
    return ApiMappers.centralTelemetry(
      ResourceDto(data: response.data),
    );
  }

  @override
  Stream<CentralControlTelemetry> watchCentralTelemetry() => const Stream.empty();

  @override
  Future<ControlCommandResult> dispatchCommand(ControlCommand command) async {
    if (command.target != CentralControlTelemetry.fixedTarget) {
      return ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.rejected,
        message: 'Irrigation control applies only to ENTIRE FIELD.',
        timestamp: DateTime.now(),
      );
    }

    final response = command.type == CommandType.startIrrigation
        ? await api.start(durationMinutes: command.durationMinutes)
        : await api.stop();
    return ApiMappers.commandResult(
      ResourceDto(data: response.data),
      command.type,
    );
  }
}
