import 'node_enums.dart';
import 'sensor.dart';
import 'spatial_coordinates.dart';
import 'transmission_config.dart';

/// Represents an operational or discovered physical ESP32 IoT node in AquaSense.
class Esp32Node {
  final String id;
  final String macAddress;
  final String displayName;
  final String? assignedFieldId;
  final String? assignedZoneId;
  final String? assignedPointId;
  final SpatialCoordinates? coordinates;
  final TransmissionConfig transmissionConfig;
  final bool isOnline;
  final NodeLifecycleState lifecycleState;
  final String hardwareRevision;
  final String firmwareVersion;
  final int? batteryPercent;
  final double? batteryVoltage;
  final int? rssiDbm;
  final double? snrDb;
  final DateTime lastSeen;
  final List<Sensor> sensors;

  // Direct cached readings for performance and backward compatibility
  final double? _soilMoisturePercent;
  final double? _waterLevelCm;
  final double? _temperatureCelsius;
  final double? _humidityPercent;

  const Esp32Node({
    required this.id,
    required this.macAddress,
    required this.displayName,
    this.assignedFieldId,
    this.assignedZoneId,
    this.assignedPointId,
    this.coordinates,
    required this.transmissionConfig,
    required this.isOnline,
    this.lifecycleState = NodeLifecycleState.active,
    this.hardwareRevision = 'v2.1',
    this.firmwareVersion = '1.0.0',
    this.batteryPercent,
    this.batteryVoltage,
    this.rssiDbm,
    this.snrDb,
    required this.lastSeen,
    this.sensors = const [],
    double? soilMoisturePercent,
    double? waterLevelCm,
    double? temperatureCelsius,
    double? humidityPercent,
  })  : _soilMoisturePercent = soilMoisturePercent,
        _waterLevelCm = waterLevelCm,
        _temperatureCelsius = temperatureCelsius,
        _humidityPercent = humidityPercent;

  double? get soilMoisturePercent {
    if (_soilMoisturePercent != null) return _soilMoisturePercent;
    for (final s in sensors) {
      if (s.type == SensorType.soilMoistureCapacitive && s.latestValue != null) {
        return s.latestValue;
      }
    }
    return null;
  }

  double? get waterLevelCm {
    if (_waterLevelCm != null) return _waterLevelCm;
    for (final s in sensors) {
      if (s.type == SensorType.waterLevelTube && s.latestValue != null) {
        return s.latestValue;
      }
    }
    return null;
  }

  double? get temperatureCelsius {
    if (_temperatureCelsius != null) return _temperatureCelsius;
    for (final s in sensors) {
      if (s.type == SensorType.soilTemperature && s.latestValue != null) {
        return s.latestValue;
      }
    }
    return null;
  }

  double? get humidityPercent {
    if (_humidityPercent != null) return _humidityPercent;
    for (final s in sensors) {
      if (s.type == SensorType.ambientHumidity && s.latestValue != null) {
        return s.latestValue;
      }
    }
    return null;
  }

  Esp32Node copyWith({
    String? id,
    String? macAddress,
    String? displayName,
    String? assignedFieldId,
    String? assignedZoneId,
    String? assignedPointId,
    SpatialCoordinates? coordinates,
    TransmissionConfig? transmissionConfig,
    bool? isOnline,
    NodeLifecycleState? lifecycleState,
    String? hardwareRevision,
    String? firmwareVersion,
    int? batteryPercent,
    double? batteryVoltage,
    int? rssiDbm,
    double? snrDb,
    DateTime? lastSeen,
    List<Sensor>? sensors,
    double? soilMoisturePercent,
    double? waterLevelCm,
    double? temperatureCelsius,
    double? humidityPercent,
  }) {
    return Esp32Node(
      id: id ?? this.id,
      macAddress: macAddress ?? this.macAddress,
      displayName: displayName ?? this.displayName,
      assignedFieldId: assignedFieldId ?? this.assignedFieldId,
      assignedZoneId: assignedZoneId ?? this.assignedZoneId,
      assignedPointId: assignedPointId ?? this.assignedPointId,
      coordinates: coordinates ?? this.coordinates,
      transmissionConfig: transmissionConfig ?? this.transmissionConfig,
      isOnline: isOnline ?? this.isOnline,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      hardwareRevision: hardwareRevision ?? this.hardwareRevision,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      rssiDbm: rssiDbm ?? this.rssiDbm,
      snrDb: snrDb ?? this.snrDb,
      lastSeen: lastSeen ?? this.lastSeen,
      sensors: sensors ?? this.sensors,
      soilMoisturePercent: soilMoisturePercent ?? this.soilMoisturePercent,
      waterLevelCm: waterLevelCm ?? this.waterLevelCm,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      humidityPercent: humidityPercent ?? this.humidityPercent,
    );
  }
}

