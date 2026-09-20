/// Quality flag indicating validity of a sensor measurement.
enum MeasurementQuality {
  /// Confirmed valid observation within expected physical bounds.
  valid,

  /// Outlier reading flagged by spatial contrast or neighboring sensor divergence.
  suspectOutlier,

  /// Rate of change exceeds possible hydraulic/physical percolation limits.
  rateOfChangeExceeded,

  /// Interpolated or forward-filled value due to temporary packet loss.
  staleInterpolated,

  /// Sensor hardware fault, open circuit, or voltage rail drop.
  hardwareFault,
}

/// A time-stamped, calibrated measurement produced by a sensor transducer.
class Measurement {
  final String id;
  final DateTime timestamp;
  final String sensorId;
  final String pointId;
  final double rawValue;
  final double calibratedValue;
  final MeasurementQuality qualityFlag;
  final Map<String, dynamic>? metadata;

  const Measurement({
    required this.id,
    required this.timestamp,
    required this.sensorId,
    required this.pointId,
    required this.rawValue,
    required this.calibratedValue,
    this.qualityFlag = MeasurementQuality.valid,
    this.metadata,
  });

  bool get isValid => qualityFlag == MeasurementQuality.valid;

  /// UTC server-normalized timestamp for synchronized time-series processing.
  DateTime get serverNormalizedTimestamp => timestamp.toUtc();

  /// Optional LoRaWAN 64-bit DevEUI identifier associated with this measurement uplink.
  String? get devEui => metadata?['devEui'] as String?;

  Measurement copyWith({
    String? id,
    DateTime? timestamp,
    String? sensorId,
    String? pointId,
    double? rawValue,
    double? calibratedValue,
    MeasurementQuality? qualityFlag,
    Map<String, dynamic>? metadata,
  }) {
    return Measurement(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      sensorId: sensorId ?? this.sensorId,
      pointId: pointId ?? this.pointId,
      rawValue: rawValue ?? this.rawValue,
      calibratedValue: calibratedValue ?? this.calibratedValue,
      qualityFlag: qualityFlag ?? this.qualityFlag,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'sensorId': sensorId,
        'pointId': pointId,
        'rawValue': rawValue,
        'calibratedValue': calibratedValue,
        'qualityFlag': qualityFlag.name,
        if (metadata != null) 'metadata': metadata,
      };

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sensorId: json['sensorId'] as String,
      pointId: json['pointId'] as String,
      rawValue: (json['rawValue'] as num).toDouble(),
      calibratedValue: (json['calibratedValue'] as num).toDouble(),
      qualityFlag: MeasurementQuality.values.firstWhere(
        (e) => e.name == json['qualityFlag'],
        orElse: () => MeasurementQuality.valid,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

