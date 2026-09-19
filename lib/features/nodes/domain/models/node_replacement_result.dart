import 'esp32_node.dart';

/// Represents the audit outcome of an atomic physical sensor node replacement.
class NodeReplacementResult {
  final String oldNodeId;
  final String replacementNodeId;
  final String fieldId;
  final String zoneId;
  final String? monitoringPointId;
  final DateTime replacedAt;
  final String? reason;
  final bool historicalMeasurementsPreserved;
  final Esp32Node updatedReplacementNode;
  final Esp32Node retiredNode;

  const NodeReplacementResult({
    required this.oldNodeId,
    required this.replacementNodeId,
    required this.fieldId,
    required this.zoneId,
    this.monitoringPointId,
    required this.replacedAt,
    this.reason,
    this.historicalMeasurementsPreserved = true,
    required this.updatedReplacementNode,
    required this.retiredNode,
  });

  /// Alias for the active replacement node.
  Esp32Node get activeNode => updatedReplacementNode;

  /// Alias for the retired replaced node.
  Esp32Node get replacedNode => retiredNode;

  /// Alias for oldNodeId.
  String get replacedNodeId => oldNodeId;

  Map<String, dynamic> toJson() => {
        'oldNodeId': oldNodeId,
        'replacementNodeId': replacementNodeId,
        'fieldId': fieldId,
        'zoneId': zoneId,
        if (monitoringPointId != null) 'monitoringPointId': monitoringPointId,
        'replacedAt': replacedAt.toIso8601String(),
        if (reason != null) 'reason': reason,
        'historicalMeasurementsPreserved': historicalMeasurementsPreserved,
        'updatedReplacementNode': updatedReplacementNode.toJson(),
        'retiredNode': retiredNode.toJson(),
      };

  factory NodeReplacementResult.fromJson(Map<String, dynamic> json) {
    return NodeReplacementResult(
      oldNodeId: json['oldNodeId'] as String,
      replacementNodeId: json['replacementNodeId'] as String,
      fieldId: json['fieldId'] as String,
      zoneId: json['zoneId'] as String,
      monitoringPointId: json['monitoringPointId'] as String?,
      replacedAt: json['replacedAt'] != null
          ? DateTime.parse(json['replacedAt'] as String)
          : DateTime.now(),
      reason: json['reason'] as String?,
      historicalMeasurementsPreserved:
          json['historicalMeasurementsPreserved'] as bool? ?? true,
      updatedReplacementNode: Esp32Node.fromJson(
        json['updatedReplacementNode'] as Map<String, dynamic>,
      ),
      retiredNode: Esp32Node.fromJson(
        json['retiredNode'] as Map<String, dynamic>,
      ),
    );
  }
}
