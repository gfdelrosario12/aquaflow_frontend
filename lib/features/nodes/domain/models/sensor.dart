import 'measurement.dart';
import 'node_enums.dart';

/// Represents a specific sensing transducer/channel attached to a physical sensor node.
class Sensor {
  final String id;
  final String nodeId;
  final SensorType type;
  final int channelIndex;
  final String unit;
  final double? depthOffsetCm;
  final Map<String, double>? calibrationCoefficients;
  final Measurement? latestMeasurement;
  final bool isActive;

  const Sensor({
    required this.id,
    required this.nodeId,
    required this.type,
    this.channelIndex = 0,
    required this.unit,
    this.depthOffsetCm,
    this.calibrationCoefficients,
    this.latestMeasurement,
    this.isActive = true,
  });

  /// Convenience getter for the latest numeric reading if available and valid.
  double? get latestValue => latestMeasurement?.calibratedValue;

  Sensor copyWith({
    String? id,
    String? nodeId,
    SensorType? type,
    int? channelIndex,
    String? unit,
    double? depthOffsetCm,
    Map<String, double>? calibrationCoefficients,
    Measurement? latestMeasurement,
    bool? isActive,
  }) {
    return Sensor(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      type: type ?? this.type,
      channelIndex: channelIndex ?? this.channelIndex,
      unit: unit ?? this.unit,
      depthOffsetCm: depthOffsetCm ?? this.depthOffsetCm,
      calibrationCoefficients:
          calibrationCoefficients ?? this.calibrationCoefficients,
      latestMeasurement: latestMeasurement ?? this.latestMeasurement,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nodeId': nodeId,
        'type': type.name,
        'channelIndex': channelIndex,
        'unit': unit,
        if (depthOffsetCm != null) 'depthOffsetCm': depthOffsetCm,
        if (calibrationCoefficients != null)
          'calibrationCoefficients': calibrationCoefficients,
        if (latestMeasurement != null)
          'latestMeasurement': latestMeasurement!.toJson(),
        'isActive': isActive,
      };

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'] as String,
      nodeId: json['nodeId'] as String,
      type: SensorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SensorType.waterLevelTube,
      ),
      channelIndex: json['channelIndex'] as int? ?? 0,
      unit: json['unit'] as String? ?? '',
      depthOffsetCm: (json['depthOffsetCm'] as num?)?.toDouble(),
      calibrationCoefficients: (json['calibrationCoefficients'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      latestMeasurement: json['latestMeasurement'] != null
          ? Measurement.fromJson(
              json['latestMeasurement'] as Map<String, dynamic>)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

