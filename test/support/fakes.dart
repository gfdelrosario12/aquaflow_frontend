import 'dart:async';
import 'dart:convert';

import 'package:aquaflow_frontend/core/api/api_token_store.dart';
import 'package:aquaflow_frontend/core/services/secure_storage_service.dart';
import 'package:aquaflow_frontend/features/control/data/repositories/control_repository.dart';
import 'package:aquaflow_frontend/features/control/domain/models/models.dart';
import 'package:http/http.dart' as http;

/// Shared fake HTTP client for API / integration tests.
class FakeHttpClient extends http.BaseClient {
  FakeHttpClient(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => handler(request);
}

http.StreamedResponse fakeJsonResponse(
  http.BaseRequest request,
  int status,
  String body,
) {
  return http.StreamedResponse(
    Stream<List<int>>.value(utf8.encode(body)),
    status,
    request: request,
    headers: const {'content-type': 'application/json'},
  );
}

class MemorySecureStorage implements SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<void> clearAll() async => values.clear();
}

class FakeTokenStore implements ApiTokenStore {
  String? access;
  String? refresh;

  FakeTokenStore({this.access, this.refresh});

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken ?? refresh;
  }

  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }
}

/// Records Mobile → API → gateway → controller → pump/valve stages for thesis pipeline tests.
enum PipelineStage {
  mobileApp,
  backendApi,
  lorawanGateway,
  centralController,
  pumpValve,
}

class IrrigationPipelineFixture implements ControlRepository {
  IrrigationPipelineFixture({
    this.failAt,
    this.timeoutAt,
    MockControlRepository? inner,
  }) : inner = inner ?? MockControlRepository();

  final MockControlRepository inner;
  final PipelineStage? failAt;
  final PipelineStage? timeoutAt;
  final List<PipelineStage> stages = [];

  @override
  Future<CentralControlTelemetry> getCentralTelemetry() =>
      inner.getCentralTelemetry();

  @override
  Stream<CentralControlTelemetry> watchCentralTelemetry() =>
      inner.watchCentralTelemetry();

  @override
  Future<ControlCommandResult> dispatchCommand(ControlCommand command) async {
    stages
      ..clear()
      ..add(PipelineStage.mobileApp);

    if (command.target != CentralControlTelemetry.fixedTarget) {
      return ControlCommandResult(
        commandId: command.id,
        type: command.type,
        outcome: CommandOutcome.rejected,
        message: 'Invalid target "${command.target}". Irrigation control applies only to the ENTIRE FIELD.',
        timestamp: DateTime.now(),
      );
    }

    stages.add(PipelineStage.backendApi);
    if (_halt(PipelineStage.backendApi, command)) {
      return _failure(command, 'Backend API rejected or timed out the command.');
    }

    stages.add(PipelineStage.lorawanGateway);
    if (_halt(PipelineStage.lorawanGateway, command)) {
      return _failure(command, 'LoRaWAN/messaging gateway failed to forward the command.');
    }

    stages.add(PipelineStage.centralController);
    if (_halt(PipelineStage.centralController, command)) {
      return _failure(command, 'Central controller did not acknowledge the command.');
    }

    final result = await inner.dispatchCommand(command);
    stages.add(PipelineStage.pumpValve);
    return result;
  }

  bool _halt(PipelineStage stage, ControlCommand command) {
    return failAt == stage || timeoutAt == stage;
  }

  ControlCommandResult _failure(ControlCommand command, String message) {
    final timedOut = timeoutAt != null && stages.contains(timeoutAt);
    return ControlCommandResult(
      commandId: command.id,
      type: command.type,
      outcome: timedOut ? CommandOutcome.timedOut : CommandOutcome.failed,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}
