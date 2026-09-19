import 'api_client.dart';
import 'api_dtos.dart';

class AuthApiService {
  final ApiClient client;

  const AuthApiService(this.client);

  Future<AuthResponseDto> login({required String identifier, required String password}) async {
    final response = await client.post(
      '/api/auth/login',
      authorized: false,
      body: {'identifier': identifier, 'password': password},
    );
    return AuthResponseDto.fromJson(response);
  }

  Future<void> logout() async {
    await client.post('/api/auth/logout');
  }
}

class FieldApiService {
  final ApiClient client;

  const FieldApiService(this.client);

  Future<ResourceListDto> listFields() async =>
      ResourceListDto.fromJson(await client.get('/api/fields'));

  Future<ResourceDto> getField(String id) async =>
      ResourceDto.fromJson(await client.get('/api/fields/$id'));

  Future<ResourceListDto> listQuarters() async =>
      ResourceListDto.fromJson(await client.get('/api/quarters'));

  Future<ResourceDto> getQuarter(String id) async =>
      ResourceDto.fromJson(await client.get('/api/quarters/$id'));

  Future<ResourceListDto> measurements({String? quarterId}) async =>
      ResourceListDto.fromJson(
        await client.get(
          '/api/measurements',
          query: quarterId == null ? null : {'quarterId': quarterId},
        ),
      );

  Future<FieldTopologyDto> getTopology(String fieldId) async {
    final response = await client.get('/api/fields/$fieldId/topology');
    return FieldTopologyDto.fromJson(response as JsonMap);
  }

  Future<List<MonitoringPointDto>> listMonitoringPoints(String fieldId) async {
    final response = await client.get('/api/fields/$fieldId/monitoring-points');
    if (response is Map && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => MonitoringPointDto.fromJson(e as JsonMap))
          .toList();
    }
    return [];
  }

  Future<MonitoringPointDto> assignNodeToPoint(
    String pointId,
    String nodeId,
  ) async {
    final response = await client.put(
      '/api/monitoring-points/$pointId/assign-node',
      body: {'nodeId': nodeId},
    );
    return MonitoringPointDto.fromJson(response as JsonMap);
  }
}

class AnalyticsApiService {
  final ApiClient client;

  const AnalyticsApiService(this.client);

  Future<ResourceDto> analytics() async =>
      ResourceDto.fromJson(await client.get('/api/analytics'));

  Future<ResourceDto> waterLevelAnalytics() async =>
      ResourceDto.fromJson(await client.get('/api/analytics/water-level'));
}

class AlertApiService {
  final ApiClient client;

  const AlertApiService(this.client);

  Future<ResourceListDto> listAlerts() async =>
      ResourceListDto.fromJson(await client.get('/api/alerts'));
}

class DeviceApiService {
  final ApiClient client;

  const DeviceApiService(this.client);

  Future<ResourceListDto> listDevices() async =>
      ResourceListDto.fromJson(await client.get('/api/devices'));

  Future<ResourceDto> gateway() async =>
      ResourceDto.fromJson(await client.get('/api/gateway'));
}

class NodeApiService {
  final ApiClient client;

  const NodeApiService(this.client);

  Future<ResourceListDto> listNodes({String? fieldId, String? zoneId}) async {
    final query = <String, String>{};
    if (fieldId != null) query['fieldId'] = fieldId;
    if (zoneId != null) query['zoneId'] = zoneId;
    return ResourceListDto.fromJson(
      await client.get('/api/nodes', query: query.isEmpty ? null : query),
    );
  }

  Future<ResourceDto> getNode(String id) async =>
      ResourceDto.fromJson(await client.get('/api/nodes/$id'));

  Future<ResourceListDto> listDiscoveredNodes() async =>
      ResourceListDto.fromJson(await client.get('/api/nodes/unassigned'));

  Future<ResourceDto> registerNode(NodeRegistrationRequestDto request) async =>
      ResourceDto.fromJson(
        await client.post('/api/nodes/register', body: request.toJson()),
      );

  Future<ResourceDto> assignSpatial(
    String id,
    NodeSpatialAssignmentDto assignment,
  ) async =>
      ResourceDto.fromJson(
        await client.put('/api/nodes/$id/spatial', body: assignment.toJson()),
      );

  Future<ResourceDto> configureTransmissionInterval(
    String id,
    TransmissionConfigDto config,
  ) async =>
      ResourceDto.fromJson(
        await client.put(
          '/api/nodes/$id/transmission-interval',
          body: config.toJson(),
        ),
      );

  Future<ResourceDto> provisionNode(
    String id,
    NodeProvisioningRequestDto request,
  ) async =>
      ResourceDto.fromJson(
        await client.post('/api/nodes/$id/provision', body: request.toJson()),
      );

  Future<ResourceDto> updateLifecycle(
    String id,
    NodeLifecycleUpdateDto update,
  ) async =>
      ResourceDto.fromJson(
        await client.post('/api/nodes/$id/lifecycle', body: update.toJson()),
      );

  Future<NodeReplacementResultDto> replaceNode(
    String id,
    NodeReplacementRequestDto request,
  ) async {
    final response = await client.post(
      '/api/nodes/$id/replace',
      body: request.toJson(),
    );
    return NodeReplacementResultDto.fromJson(
      response is Map<String, dynamic>
          ? response
          : (response as Map).cast<String, dynamic>(),
    );
  }

  Future<ResourceDto> updateNode(
    String id,
    Map<String, dynamic> patch,
  ) async =>
      ResourceDto.fromJson(
        await client.patch('/api/nodes/$id', body: patch),
      );

  Future<bool> decommissionNode(String id) async {
    await client.delete('/api/nodes/$id');
    return true;
  }
}

class IrrigationApiService {
  final ApiClient client;

  const IrrigationApiService(this.client);

  Future<IrrigationResultDto> status() async =>
      IrrigationResultDto.fromJson(await client.get('/api/irrigation/status'));

  Future<IrrigationResultDto> start({required int durationMinutes}) async =>
      IrrigationResultDto.fromJson(
        await client.post(
          '/api/irrigation/start',
          body: IrrigationCommandDto(
            durationMinutes: durationMinutes,
          ).toJson(),
        ),
      );

  Future<IrrigationResultDto> stop() async =>
      IrrigationResultDto.fromJson(
        await client.post(
          '/api/irrigation/stop',
          body: const IrrigationCommandDto().toJson(),
        ),
      );

  Future<AutoIrrigationConfigDto> getAutoConfig({
    String systemId = 'default',
  }) async {
    final response = await client.get(
      '/api/irrigation/auto-config',
      query: {'systemId': systemId},
    );
    return AutoIrrigationConfigDto.fromJson(response as JsonMap);
  }

  Future<AutoIrrigationConfigDto> updateAutoConfig(
    AutoIrrigationConfigDto config,
  ) async {
    final response = await client.put(
      '/api/irrigation/auto-config',
      body: config.toJson(),
    );
    return AutoIrrigationConfigDto.fromJson(response as JsonMap);
  }

  Future<AutoIrrigationStatusDto> getAutoState({
    String systemId = 'default',
  }) async {
    final response = await client.get(
      '/api/irrigation/auto-state',
      query: {'systemId': systemId},
    );
    return AutoIrrigationStatusDto.fromJson(response as JsonMap);
  }

  Future<AutoIrrigationStatusDto> clearLockout(
    ClearLockoutRequestDto request,
  ) async {
    final response = await client.post(
      '/api/irrigation/auto-lockout/clear',
      body: request.toJson(),
    );
    return AutoIrrigationStatusDto.fromJson(response as JsonMap);
  }

  Future<IrrigationAuditLogListDto> getAuditLogs({
    String systemId = 'default',
    int limit = 50,
  }) async {
    final response = await client.get(
      '/api/irrigation/audit-log',
      query: {
        'systemId': systemId,
        'limit': limit.toString(),
      },
    );
    return IrrigationAuditLogListDto.fromJson(response);
  }
}
