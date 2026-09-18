import 'dart:async';
import '../../../../core/api/api_dtos.dart';
import '../../../../core/api/api_mappers.dart';
import '../../../../core/api/api_services.dart';
import '../../domain/models/models.dart';
import 'node_repository.dart';

class ApiNodeRepository implements NodeRepository {
  final NodeApiService api;

  ApiNodeRepository(this.api);

  @override
  Future<List<Esp32Node>> fetchNodes({String? fieldId, String? zoneId, String? pointId}) async {
    final response = await api.listNodes(fieldId: fieldId, zoneId: zoneId);
    var nodes = response.items.map(ApiMappers.esp32Node);
    if (pointId != null) {
      nodes = nodes.where((n) => n.assignedPointId == pointId);
    }
    return nodes.toList(growable: false);
  }

  @override
  Future<Esp32Node> replaceNode({
    required String oldNodeId,
    required String newNodeId,
  }) async {
    // In API mode, assign newNode to oldNode's point
    final oldNode = await fetchNodeById(oldNodeId);
    final response = await api.assignSpatial(
      newNodeId,
      NodeSpatialAssignmentDto(
        fieldId: oldNode?.assignedFieldId ?? '',
        zoneId: oldNode?.assignedZoneId ?? '',
        latitude: oldNode?.coordinates?.latitude,
        longitude: oldNode?.coordinates?.longitude,
        localX: oldNode?.coordinates?.localX,
        localY: oldNode?.coordinates?.localY,
      ),
    );
    return ApiMappers.esp32Node(response);
  }

  @override
  Future<List<NodeDiscoveryInfo>> fetchDiscoveredNodes() async {
    final response = await api.listDiscoveredNodes();
    return response.items
        .map(ApiMappers.nodeDiscoveryInfo)
        .toList(growable: false);
  }

  @override
  Future<Esp32Node?> fetchNodeById(String id) async {
    final response = await api.getNode(id);
    return ApiMappers.esp32Node(response);
  }

  @override
  Future<Esp32Node> registerNode(NodeRegistrationRequestDto request) async {
    final response = await api.registerNode(request);
    return ApiMappers.esp32Node(response);
  }

  @override
  Future<Esp32Node> assignSpatialCoordinates(
    String nodeId,
    NodeSpatialAssignmentDto assignment,
  ) async {
    final response = await api.assignSpatial(nodeId, assignment);
    return ApiMappers.esp32Node(response);
  }

  @override
  Future<TransmissionConfig> configureTransmissionInterval(
    String nodeId,
    TransmissionConfigDto config,
  ) async {
    final response = await api.configureTransmissionInterval(nodeId, config);
    return ApiMappers.transmissionConfig(response.data);
  }

  @override
  Stream<List<Esp32Node>> watchNodes() => const Stream.empty();
}

