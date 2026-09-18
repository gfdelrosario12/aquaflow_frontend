import 'spatial_coordinates.dart';

/// Represents a logical observation station / field tube installation in AquaSense.
///
/// Decouples the agronomic observation location from the physical electronic hardware
/// (SensorNode), ensuring historical continuity even when physical nodes are swapped or serviced.
class MonitoringPoint {
  final String id;
  final String fieldId;
  final String zoneId;
  final String code; // e.g., "P01", "P02", or "Q1"
  final String label; // Descriptive name e.g. "North Inflow Station"
  final SpatialCoordinates? coordinates;
  final double relativeElevationCm;
  final double tubeDatumOffsetCm;
  final String? assignedNodeId;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const MonitoringPoint({
    required this.id,
    required this.fieldId,
    required this.zoneId,
    required this.code,
    required this.label,
    this.coordinates,
    this.relativeElevationCm = 0.0,
    this.tubeDatumOffsetCm = 0.0,
    this.assignedNodeId,
    this.isActive = true,
    this.metadata,
  });

  bool get hasAssignedNode => assignedNodeId != null && assignedNodeId!.isNotEmpty;

  MonitoringPoint copyWith({
    String? id,
    String? fieldId,
    String? zoneId,
    String? code,
    String? label,
    SpatialCoordinates? coordinates,
    double? relativeElevationCm,
    double? tubeDatumOffsetCm,
    String? assignedNodeId,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return MonitoringPoint(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      zoneId: zoneId ?? this.zoneId,
      code: code ?? this.code,
      label: label ?? this.label,
      coordinates: coordinates ?? this.coordinates,
      relativeElevationCm: relativeElevationCm ?? this.relativeElevationCm,
      tubeDatumOffsetCm: tubeDatumOffsetCm ?? this.tubeDatumOffsetCm,
      assignedNodeId: assignedNodeId ?? this.assignedNodeId,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fieldId': fieldId,
        'zoneId': zoneId,
        'code': code,
        'label': label,
        if (coordinates != null) 'coordinates': coordinates!.toJson(),
        'relativeElevationCm': relativeElevationCm,
        'tubeDatumOffsetCm': tubeDatumOffsetCm,
        if (assignedNodeId != null) 'assignedNodeId': assignedNodeId,
        'isActive': isActive,
        if (metadata != null) 'metadata': metadata,
      };

  factory MonitoringPoint.fromJson(Map<String, dynamic> json) {
    return MonitoringPoint(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      zoneId: json['zoneId'] as String,
      code: json['code'] as String,
      label: json['label'] as String? ?? json['code'] as String,
      coordinates: json['coordinates'] != null
          ? SpatialCoordinates.fromJson(
              json['coordinates'] as Map<String, dynamic>)
          : null,
      relativeElevationCm:
          (json['relativeElevationCm'] as num?)?.toDouble() ?? 0.0,
      tubeDatumOffsetCm:
          (json['tubeDatumOffsetCm'] as num?)?.toDouble() ?? 0.0,
      assignedNodeId: json['assignedNodeId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

