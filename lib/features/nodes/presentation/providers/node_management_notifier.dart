import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_dtos.dart';
import '../../../../core/realtime/realtime_coordinator.dart';
import '../../../../core/realtime/realtime_events.dart';
import '../../data/repositories/node_repository.dart';
import '../../domain/models/models.dart';

class NodeManagementStateData {
  final List<Esp32Node> nodes;
  final List<NodeDiscoveryInfo> discoveredNodes;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final Esp32Node? selectedNode;
  final String? selectedZoneFilter;

  const NodeManagementStateData({
    this.nodes = const [],
    this.discoveredNodes = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.selectedNode,
    this.selectedZoneFilter,
  });

  int get totalNodes => nodes.length;
  int get onlineCount => nodes.where((n) => n.isOnline).length;
  int get offlineCount => nodes.where((n) => !n.isOnline).length;
  int get adaptiveCount =>
      nodes.where((n) => n.transmissionConfig.isAdaptive).length;

  List<Esp32Node> get filteredNodes {
    if (selectedZoneFilter == null) return nodes;
    return nodes.where((n) => n.assignedZoneId == selectedZoneFilter).toList();
  }

  List<Esp32Node> nodesForZone(String zoneId) =>
      nodes.where((n) => n.assignedZoneId == zoneId).toList();

  NodeManagementStateData copyWith({
    List<Esp32Node>? nodes,
    List<NodeDiscoveryInfo>? discoveredNodes,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Esp32Node? selectedNode,
    bool clearSelectedNode = false,
    String? selectedZoneFilter,
    bool clearZoneFilter = false,
  }) {
    return NodeManagementStateData(
      nodes: nodes ?? this.nodes,
      discoveredNodes: discoveredNodes ?? this.discoveredNodes,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedNode:
          clearSelectedNode ? null : (selectedNode ?? this.selectedNode),
      selectedZoneFilter:
          clearZoneFilter ? null : (selectedZoneFilter ?? this.selectedZoneFilter),
    );
  }
}

class NodeManagementNotifier extends ChangeNotifier {
  final NodeRepository _repository;
  final RealtimeCoordinator? _realtimeCoordinator;
  NodeManagementStateData _state = const NodeManagementStateData();
  StreamSubscription<List<Esp32Node>>? _nodeSubscription;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  bool _isDisposed = false;

  NodeManagementNotifier({
    NodeRepository? repository,
    RealtimeCoordinator? realtimeCoordinator,
  })  : _repository = repository ?? MockNodeRepository(),
        _realtimeCoordinator = realtimeCoordinator {
    _init();
  }

  NodeManagementStateData get state => _state;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void _init() {
    fetchNodes();
    fetchDiscoveredNodes();
    _nodeSubscription = _repository.watchNodes().listen((nodes) {
      _state = _state.copyWith(nodes: nodes);
      notifyListeners();
    });

    if (_realtimeCoordinator != null) {
      _realtimeSubscription =
          _realtimeCoordinator.events.listen(handleRealtimeEvent);
    }
  }

  Future<void> fetchNodes() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    try {
      final nodes = await _repository.fetchNodes();
      _state = _state.copyWith(nodes: nodes, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch ESP32 nodes: $e',
      );
    }
    notifyListeners();
  }

  Future<void> fetchDiscoveredNodes() async {
    try {
      final discovered = await _repository.fetchDiscoveredNodes();
      _state = _state.copyWith(discoveredNodes: discovered);
      notifyListeners();
    } catch (_) {}
  }

  void selectNode(Esp32Node? node) {
    if (node == null) {
      _state = _state.copyWith(clearSelectedNode: true);
    } else {
      _state = _state.copyWith(selectedNode: node);
    }
    notifyListeners();
  }

  void setZoneFilter(String? zoneId) {
    if (zoneId == null) {
      _state = _state.copyWith(clearZoneFilter: true);
    } else {
      _state = _state.copyWith(selectedZoneFilter: zoneId);
    }
    notifyListeners();
  }

  Future<bool> registerNode(NodeRegistrationRequestDto request) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();
    try {
      final newNode = await _repository.registerNode(request);
      final updatedList = List<Esp32Node>.from(_state.nodes)..add(newNode);
      final updatedDiscovered = _state.discoveredNodes
          .where((d) => d.macAddress != request.macAddress)
          .toList();
      _state = _state.copyWith(
        nodes: updatedList,
        discoveredNodes: updatedDiscovered,
        isSubmitting: false,
        selectedNode: newNode,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: 'Node registration failed: $e',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignSpatial(
    String nodeId,
    NodeSpatialAssignmentDto assignment,
  ) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();
    try {
      final updatedNode =
          await _repository.assignSpatialCoordinates(nodeId, assignment);
      final updatedNodes = _state.nodes.map((n) {
        return n.id == nodeId ? updatedNode : n;
      }).toList();
      _state = _state.copyWith(
        nodes: updatedNodes,
        selectedNode: updatedNode,
        isSubmitting: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: 'Spatial assignment failed: $e',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> configureTransmissionInterval(
    String nodeId,
    int intervalSeconds, {
    bool isAdaptive = false,
    String? reason,
  }) async {
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();
    try {
      final config = await _repository.configureTransmissionInterval(
        nodeId,
        TransmissionConfigDto(
          intervalSeconds: intervalSeconds,
          isAdaptive: isAdaptive,
          reason: reason,
        ),
      );
      final updatedNodes = _state.nodes.map((n) {
        if (n.id == nodeId) {
          return n.copyWith(transmissionConfig: config);
        }
        return n;
      }).toList();
      _state = _state.copyWith(
        nodes: updatedNodes,
        selectedNode: _state.selectedNode?.id == nodeId
            ? _state.selectedNode?.copyWith(transmissionConfig: config)
            : _state.selectedNode,
        isSubmitting: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: 'Interval configuration failed: $e',
      );
      notifyListeners();
      return false;
    }
  }

  void handleRealtimeEvent(RealtimeEvent event) {
    final payload = event.payload;
    final targetId = payload['nodeId']?.toString() ?? event.scope;

    if (event.type == RealtimeEventType.transmissionIntervalUpdated) {
      final interval = int.tryParse(payload['intervalSeconds']?.toString() ??
              payload['interval']?.toString() ??
              '') ??
          300;
      final isAdaptive = payload['isAdaptive'] as bool? ?? true;
      final reason = payload['reason']?.toString() ??
          payload['adaptiveReason']?.toString() ??
          'Adaptive trigger';

      final updatedNodes = _state.nodes.map((node) {
        if (node.id == targetId || node.macAddress == targetId) {
          return node.copyWith(
            transmissionConfig: TransmissionConfig(
              intervalSeconds: interval,
              isAdaptive: isAdaptive,
              adaptiveReason: reason,
              lastConfiguredAt: event.occurredAt,
            ),
          );
        }
        return node;
      }).toList();

      _state = _state.copyWith(nodes: updatedNodes);
      notifyListeners();
    } else if (event.type == RealtimeEventType.measurement) {
      final moisture = double.tryParse(payload['soilMoisture']?.toString() ??
          payload['soilMoisturePercent']?.toString() ??
          '');
      final water = double.tryParse(payload['waterLevel']?.toString() ??
          payload['waterLevelCm']?.toString() ??
          '');
      final temp = double.tryParse(payload['temperature']?.toString() ??
          payload['temperatureCelsius']?.toString() ??
          '');
      final hum = double.tryParse(payload['humidity']?.toString() ??
          payload['humidityPercent']?.toString() ??
          '');

      final updatedNodes = _state.nodes.map((node) {
        if (node.id == targetId || node.assignedZoneId == targetId) {
          return node.copyWith(
            soilMoisturePercent: moisture ?? node.soilMoisturePercent,
            waterLevelCm: water ?? node.waterLevelCm,
            temperatureCelsius: temp ?? node.temperatureCelsius,
            humidityPercent: hum ?? node.humidityPercent,
            lastSeen: event.occurredAt,
          );
        }
        return node;
      }).toList();

      _state = _state.copyWith(nodes: updatedNodes);
      notifyListeners();
    } else if (event.type == RealtimeEventType.nodeStatus ||
        event.type == RealtimeEventType.sensorStatus) {
      final isOnline = payload['isOnline'] as bool? ?? true;
      final battery = int.tryParse(payload['batteryPercent']?.toString() ?? '');
      final rssi = int.tryParse(payload['rssiDbm']?.toString() ?? '');

      final updatedNodes = _state.nodes.map((node) {
        if (node.id == targetId) {
          return node.copyWith(
            isOnline: isOnline,
            batteryPercent: battery ?? node.batteryPercent,
            rssiDbm: rssi ?? node.rssiDbm,
            lastSeen: event.occurredAt,
          );
        }
        return node;
      }).toList();

      _state = _state.copyWith(nodes: updatedNodes);
      notifyListeners();
    } else if (event.type == RealtimeEventType.nodeDiscovered) {
      final newDiscovery = NodeDiscoveryInfo(
        id: payload['id']?.toString() ?? 'DISC-${event.sequence}',
        macAddress: payload['macAddress']?.toString() ?? '',
        hardwareModel: payload['hardwareModel']?.toString() ?? 'ESP32 Node',
        firmwareVersion: payload['firmwareVersion']?.toString() ?? '1.0.0',
        rssiDbm: int.tryParse(payload['rssiDbm']?.toString() ?? '') ?? -85,
        detectedAt: event.occurredAt,
      );

      final exists = _state.discoveredNodes
          .any((d) => d.macAddress == newDiscovery.macAddress);
      if (!exists && newDiscovery.macAddress.isNotEmpty) {
        _state = _state.copyWith(
          discoveredNodes: [..._state.discoveredNodes, newDiscovery],
        );
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nodeSubscription?.cancel();
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}

