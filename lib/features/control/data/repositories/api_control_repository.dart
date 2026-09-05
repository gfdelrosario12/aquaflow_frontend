import 'dart:async';

import '../../../../core/api/api_dtos.dart';
import '../../../../core/api/api_errors.dart';
import '../../../../core/api/api_mappers.dart';
import '../../../../core/api/api_services.dart';
import '../../../../core/offline/irrigation_command_gate.dart';
import '../../../../core/offline/offline_models.dart';
import '../../domain/models/models.dart';
import 'control_repository.dart';

class ApiControlRepository implements ControlRepository {
  final IrrigationApiService api;
  final IrrigationCommandGate? commandGate;
  final bool authenticated;
  final bool controllerConfirmed;
  final CacheConfirmation confirmation;

  ApiControlRepository(
    this.api, {
    this.commandGate,
    this.authenticated = true,
    this.controllerConfirmed = true,
    this.confirmation = CacheConfirmation.live,
  });

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
    final irrigationAuthorized = command.userRole != ControlUserRole.viewer;
    final gate = commandGate;
    if (gate != null) {
      final decision = gate.check(
        authenticated: authenticated,
        irrigationAuthorized: irrigationAuthorized,
        controllerConfirmed: controllerConfirmed,
        target: command.target,
        confirmation: confirmation,
      );
      if (!decision.allowed) {
        return ControlCommandResult(
          commandId: command.id,
          type: command.type,
          outcome: CommandOutcome.rejected,
          message: decision.message,
          timestamp: DateTime.now(),
        );
      }
    }
    if (command.target != CentralControlTelemetry.fixedTarget) {
      return ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.rejected,
        message: 'Irrigation control applies only to ENTIRE FIELD.',
        timestamp: DateTime.now(),
      );
    }
    if (!irrigationAuthorized) {
      return ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.rejected,
        message: 'Unauthorized: Viewer role cannot initiate field irrigation controls.',
        timestamp: DateTime.now(),
      );
    }

    try {
      // Backend command chain only — never open LoRaWAN/hardware from the mobile app.
      // start/stop are non-idempotent: ApiClient must not auto-replay these POSTs.
      final response = command.type == CommandType.startIrrigation
          ? await api.start(durationMinutes: command.durationMinutes)
          : await api.stop();
      return ApiMappers.commandResult(
        ResourceDto(data: response.data),
        command.type,
      );
    } on ApiException catch (error) {
      return ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: _outcomeFor(error),
        message: _userSafeMessage(error),
        timestamp: DateTime.now(),
      );
    }
  }

  CommandOutcome _outcomeFor(ApiException error) {
    switch (error.kind) {
      case ApiErrorKind.timeout:
        return CommandOutcome.timedOut;
      case ApiErrorKind.authentication:
      case ApiErrorKind.authorization:
        return CommandOutcome.rejected;
      default:
        return CommandOutcome.failed;
    }
  }

  String _userSafeMessage(ApiException error) {
    switch (error.kind) {
      case ApiErrorKind.timeout:
        return 'Irrigation command timed out before controller acknowledgment. Status is unconfirmed.';
      case ApiErrorKind.authentication:
        return 'Sign in is required before irrigation commands.';
      case ApiErrorKind.authorization:
        return 'Unauthorized: you do not have irrigation control permission.';
      case ApiErrorKind.transportSecurity:
        return 'Secure connection to the backend failed. Irrigation was not confirmed.';
      case ApiErrorKind.connectivity:
        return 'Backend connectivity lost. Irrigation command was not confirmed.';
      default:
        return 'Irrigation command failed. Re-check centralized field status before retrying.';
    }
  }
}
