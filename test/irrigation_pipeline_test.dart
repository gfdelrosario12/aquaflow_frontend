import 'package:aquaflow_frontend/core/api/api_client.dart';
import 'package:aquaflow_frontend/core/api/api_config.dart';
import 'package:aquaflow_frontend/core/api/api_services.dart';
import 'package:aquaflow_frontend/core/offline/connectivity_service.dart';
import 'package:aquaflow_frontend/core/offline/irrigation_command_gate.dart';
import 'package:aquaflow_frontend/core/offline/offline_models.dart';
import 'package:aquaflow_frontend/features/control/domain/models/models.dart';
import 'package:aquaflow_frontend/features/control/presentation/providers/central_control_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'support/fakes.dart';

void main() {
  group('Mocked irrigation pipeline', () {
    test('success records Mobile → API → gateway → controller → pump/valve',
        () async {
      final pipeline = IrrigationPipelineFixture();
      final notifier = CentralControlNotifier(repository: pipeline);
      addTearDown(notifier.dispose);

      final result = await notifier.startIrrigation(
        durationMinutes: 30,
        requestedBy: 'pipeline-test',
      );

      expect(result.isSuccess, isTrue);
      expect(
        pipeline.stages,
        [
          PipelineStage.mobileApp,
          PipelineStage.backendApi,
          PipelineStage.lorawanGateway,
          PipelineStage.centralController,
          PipelineStage.pumpValve,
        ],
      );

      final telemetry = await pipeline.getCentralTelemetry();
      expect(telemetry.target, CentralControlTelemetry.fixedTarget);
      expect(telemetry.pumpStatus, PumpStatus.pumping);
      expect(telemetry.valveStatus, MainValveStatus.open);
    });

    test('backend timeout leaves command unconfirmed', () async {
      final pipeline = IrrigationPipelineFixture(
        timeoutAt: PipelineStage.backendApi,
      );
      final result = await pipeline.dispatchCommand(
        ControlCommand(
          id: 'pipe-timeout',
          type: CommandType.startIrrigation,
          durationMinutes: 20,
          timestamp: DateTime.now(),
          requestedBy: 'pipeline-test',
          userRole: ControlUserRole.operator,
        ),
      );

      expect(result.outcome, CommandOutcome.timedOut);
      expect(result.isSuccess, isFalse);
      expect(pipeline.stages, isNot(contains(PipelineStage.pumpValve)));
      final telemetry = await pipeline.getCentralTelemetry();
      expect(telemetry.pumpStatus, PumpStatus.off);
    });

    test('gateway failure does not mark pump/valve confirmed', () async {
      final pipeline = IrrigationPipelineFixture(
        failAt: PipelineStage.lorawanGateway,
      );
      final result = await pipeline.dispatchCommand(
        ControlCommand(
          id: 'pipe-fail',
          type: CommandType.stopIrrigation,
          durationMinutes: 0,
          timestamp: DateTime.now(),
          requestedBy: 'pipeline-test',
          userRole: ControlUserRole.operator,
        ),
      );

      expect(result.outcome, CommandOutcome.failed);
      expect(pipeline.stages.contains(PipelineStage.pumpValve), isFalse);
    });

    test('API irrigation service posts only ENTIRE FIELD commands', () async {
      final bodies = <String>[];
      final client = ApiClient(
        config: const ApiConfig(baseUrl: 'https://example.test'),
        httpClient: FakeHttpClient((request) async {
          if (request is http.Request) {
            bodies.add(request.body);
          }
          return fakeJsonResponse(
            request,
            200,
            '{"outcome":"acknowledged","message":"ok"}',
          );
        }),
      );
      final service = IrrigationApiService(client);
      await service.start(durationMinutes: 25);
      await service.stop();

      expect(bodies.every((b) => b.contains('ENTIRE FIELD')), isTrue);
      expect(bodies.any((b) => b.contains('"Q1"')), isFalse);
    });
  });

  group('Offline / unauthenticated pipeline gating', () {
    test('gate blocks offline and unauthenticated commands', () async {
      final probe = FakeConnectivityProbe(reachable: false);
      final connectivity = ConnectivityNotifier(probe: probe);
      final gate = IrrigationCommandGate(connectivity);
      addTearDown(() async {
        connectivity.dispose();
        await probe.dispose();
      });

      expect(
        gate.check(
          authenticated: true,
          irrigationAuthorized: true,
          controllerConfirmed: true,
          target: 'ENTIRE FIELD',
          confirmation: CacheConfirmation.live,
        ).allowed,
        isFalse,
      );

      probe.setReachable(true);
      await connectivity.refresh();
      expect(
        gate.check(
          authenticated: false,
          irrigationAuthorized: true,
          controllerConfirmed: true,
          target: 'ENTIRE FIELD',
          confirmation: CacheConfirmation.live,
        ).allowed,
        isFalse,
      );
    });
  });
}
