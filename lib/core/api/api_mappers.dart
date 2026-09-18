import '../../features/control/domain/models/central_control_telemetry.dart';
import '../../features/control/domain/models/control_command_result.dart';
import '../../features/control/domain/models/control_enums.dart';
import '../../features/auth/domain/models/auth_token.dart';
import '../../features/auth/domain/models/user_session.dart';
import '../../features/field/domain/models/models.dart';
import '../../features/nodes/domain/models/models.dart';
import '../../features/zones/domain/models/monitoring_zone.dart';
import 'api_dtos.dart';

class ApiMappers {
  static Field field(FieldDto dto) {
    return Field(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      areaSquareMeters: dto.areaSquareMeters,
      soilType: dto.soilType,
      activeCropStage: _enumValue(
        CropStage.values,
        dto.activeCropStage,
        CropStage.vegetativeTillering,
      ),
      awdProfileId: dto.awdProfileId,
      centralControllerId: dto.centralControllerId,
      boundaryCoordinates: dto.boundaryCoordinates,
      createdAt: _date(dto.createdAt) ?? DateTime.now(),
      updatedAt: _date(dto.updatedAt) ?? DateTime.now(),
    );
  }

  static FieldDto fieldDto(Field domain) {
    return FieldDto(
      id: domain.id,
      name: domain.name,
      description: domain.description,
      areaSquareMeters: domain.areaSquareMeters,
      soilType: domain.soilType,
      activeCropStage: domain.activeCropStage.name,
      awdProfileId: domain.awdProfileId,
      centralControllerId: domain.centralControllerId,
      boundaryCoordinates: domain.boundaryCoordinates,
      createdAt: domain.createdAt.toIso8601String(),
      updatedAt: domain.updatedAt.toIso8601String(),
    );
  }

  static MonitoringPoint monitoringPoint(MonitoringPointDto dto) {
    return MonitoringPoint(
      id: dto.id,
      fieldId: dto.fieldId,
      zoneId: dto.zoneId,
      code: dto.code,
      label: dto.label,
      coordinates: (dto.latitude != null || dto.localX != null)
          ? SpatialCoordinates(
              latitude: dto.latitude,
              longitude: dto.longitude,
              localX: dto.localX,
              localY: dto.localY,
              elevationMeters: dto.elevationMeters,
            )
          : null,
      relativeElevationCm: dto.relativeElevationCm,
      tubeDatumOffsetCm: dto.tubeDatumOffsetCm,
      assignedNodeId: dto.assignedNodeId,
      isActive: dto.isActive,
    );
  }

  static MonitoringPointDto monitoringPointDto(MonitoringPoint domain) {
    return MonitoringPointDto(
      id: domain.id,
      fieldId: domain.fieldId,
      zoneId: domain.zoneId,
      code: domain.code,
      label: domain.label,
      latitude: domain.coordinates?.latitude,
      longitude: domain.coordinates?.longitude,
      localX: domain.coordinates?.localX,
      localY: domain.coordinates?.localY,
      elevationMeters: domain.coordinates?.elevationMeters,
      relativeElevationCm: domain.relativeElevationCm,
      tubeDatumOffsetCm: domain.tubeDatumOffsetCm,
      assignedNodeId: domain.assignedNodeId,
      isActive: domain.isActive,
    );
  }

  static Sensor sensor(SensorDto dto) {
    return Sensor(
      id: dto.id,
      nodeId: dto.nodeId,
      type: _enumValue(SensorType.values, dto.type, SensorType.waterLevelTube),
      channelIndex: dto.channelIndex,
      unit: dto.unit,
      depthOffsetCm: dto.depthOffsetCm,
      calibrationCoefficients: dto.calibrationCoefficients,
      latestMeasurement: dto.latestMeasurement != null
          ? measurement(dto.latestMeasurement!)
          : null,
      isActive: dto.isActive,
    );
  }

  static SensorDto sensorDto(Sensor domain) {
    return SensorDto(
      id: domain.id,
      nodeId: domain.nodeId,
      type: domain.type.name,
      channelIndex: domain.channelIndex,
      unit: domain.unit,
      depthOffsetCm: domain.depthOffsetCm,
      calibrationCoefficients: domain.calibrationCoefficients,
      latestMeasurement: domain.latestMeasurement != null
          ? measurementDto(domain.latestMeasurement!)
          : null,
      isActive: domain.isActive,
    );
  }

  static Measurement measurement(MeasurementDto dto) {
    return Measurement(
      id: dto.id,
      timestamp: _date(dto.timestamp) ?? DateTime.now(),
      sensorId: dto.sensorId,
      pointId: dto.pointId,
      rawValue: dto.rawValue,
      calibratedValue: dto.calibratedValue,
      qualityFlag: _enumValue(
        MeasurementQuality.values,
        dto.qualityFlag,
        MeasurementQuality.valid,
      ),
    );
  }

  static MeasurementDto measurementDto(Measurement domain) {
    return MeasurementDto(
      id: domain.id,
      timestamp: domain.timestamp.toIso8601String(),
      sensorId: domain.sensorId,
      pointId: domain.pointId,
      rawValue: domain.rawValue,
      calibratedValue: domain.calibratedValue,
      qualityFlag: domain.qualityFlag.name,
    );
  }

  static Esp32Node esp32Node(ResourceDto dto) {
    final data = dto.data;
    return Esp32Node(
      id: dto.id ?? _string(data['id'], fallback: 'unknown-node'),
      macAddress: _string(data['macAddress'], fallback: '00:00:00:00:00:00'),
      displayName: _string(data['displayName'] ?? data['name'], fallback: 'ESP32 Node'),
      assignedFieldId: data['assignedFieldId']?.toString(),
      assignedZoneId: data['assignedZoneId']?.toString(),
      coordinates: spatialCoordinates(data['coordinates'] ?? data),
      transmissionConfig: transmissionConfig(data['transmissionConfig'] ?? data),
      isOnline: data['isOnline'] as bool? ?? false,
      batteryPercent: _intNullable(data['batteryPercent']),
      batteryVoltage: _doubleNullable(data['batteryVoltage']),
      rssiDbm: _intNullable(data['rssiDbm']),
      snrDb: _doubleNullable(data['snrDb']),
      lastSeen: _date(data['lastSeen']) ?? DateTime.now(),
      soilMoisturePercent: _doubleNullable(data['soilMoisturePercent'] ?? data['soilMoisture']),
      waterLevelCm: _doubleNullable(data['waterLevelCm'] ?? data['waterLevel']),
      temperatureCelsius: _doubleNullable(data['temperatureCelsius'] ?? data['temperature']),
      humidityPercent: _doubleNullable(data['humidityPercent'] ?? data['humidity']),
    );
  }

  static SpatialCoordinates spatialCoordinates(Object? raw) {
    if (raw is! Map) return const SpatialCoordinates();
    final map = Map<String, dynamic>.from(raw);
    return SpatialCoordinates(
      latitude: _doubleNullable(map['latitude']),
      longitude: _doubleNullable(map['longitude']),
      localX: _doubleNullable(map['localX']),
      localY: _doubleNullable(map['localY']),
      elevationMeters: _doubleNullable(map['elevationMeters']),
    );
  }

  static TransmissionConfig transmissionConfig(Object? raw) {
    if (raw is! Map) {
      return TransmissionConfig(
        intervalSeconds: 300,
        isAdaptive: false,
        lastConfiguredAt: DateTime.now(),
      );
    }
    final map = Map<String, dynamic>.from(raw);
    return TransmissionConfig(
      intervalSeconds: _int(map['intervalSeconds'] ?? map['transmissionIntervalSeconds'], fallback: 300),
      isAdaptive: map['isAdaptive'] as bool? ?? false,
      adaptiveReason: map['adaptiveReason']?.toString() ?? map['reason']?.toString(),
      lastConfiguredAt: _date(map['lastConfiguredAt']) ?? DateTime.now(),
    );
  }

  static NodeDiscoveryInfo nodeDiscoveryInfo(ResourceDto dto) {
    final data = dto.data;
    return NodeDiscoveryInfo(
      id: dto.id ?? _string(data['id'], fallback: 'disc-node'),
      macAddress: _string(data['macAddress'], fallback: '00:00:00:00:00:00'),
      hardwareModel: _string(data['hardwareModel'], fallback: 'ESP32 LoRa Node'),
      firmwareVersion: _string(data['firmwareVersion'], fallback: '1.0.0'),
      rssiDbm: _int(data['rssiDbm'], fallback: -85),
      detectedAt: _date(data['detectedAt']) ?? DateTime.now(),
    );
  }
  static UserSession userSession(AuthResponseDto dto) {
    final user = dto.user;
    return UserSession(
      userId: _string(user['id'] ?? user['userId'], fallback: 'unknown'),
      username: _string(user['username'], fallback: 'Operator'),
      email: _string(user['email'], fallback: ''),
      role: _string(user['role'], fallback: 'Field Operator'),
      token: AuthToken(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken ?? '',
        expiresAt: _date(user['expiresAt']) ??
            DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  static AuthToken token(AuthResponseDto dto) {
    return AuthToken(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken ?? '',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  static MonitoringZone monitoringZone(ResourceDto dto) {
    final data = dto.data;
    final history = _doubles(data['waterLevelHistory']);
    return MonitoringZone(
      id: dto.id ?? _string(data['id'], fallback: 'unknown'),
      code: _string(data['code'] ?? data['quarter'], fallback: 'Q1'),
      name: _string(data['name'], fallback: 'Monitoring Quarter'),
      soilMoisturePercent: _double(data['soilMoisturePercent'] ?? data['soilMoisture']),
      waterLevelCm: _double(data['waterLevelCm'] ?? data['waterLevel']),
      temperatureCelsius: _double(data['temperatureCelsius'] ?? data['temperature']),
      humidityPercent: _double(data['humidityPercent'] ?? data['humidity']),
      batteryPercent: _int(data['batteryPercent'] ?? data['battery']),
      status: _zoneStatus(data['status']),
      lastUpdated: _date(data['lastUpdated'] ?? data['updatedAt']) ?? DateTime.now(),
      isOnline: data['isOnline'] as bool? ?? true,
      rssiDbm: _int(data['rssiDbm'] ?? data['rssi'], fallback: -85),
      snrDb: _double(data['snrDb'] ?? data['snr'], fallback: 0),
      hardwareModel: _string(data['hardwareModel'], fallback: 'AquaSense LoRa Node'),
      firmwareVersion: _string(data['firmwareVersion'], fallback: 'Unknown'),
      waterLevelHistory: history.isEmpty ? const [0] : history,
      waterLevelHistory24h: _doubles(data['waterLevelHistory24h']),
      waterLevelHistory7d: _doubles(data['waterLevelHistory7d']),
      assignedNodeIds: _strings(data['assignedNodeIds'] ?? data['nodeIds']),
      coordinates: spatialCoordinates(data['coordinates'] ?? data),
      transmissionConfig: data['transmissionConfig'] != null ||
              data['transmissionIntervalSeconds'] != null
          ? transmissionConfig(data['transmissionConfig'] ?? data)
          : null,
    );
  }

  static CentralControlTelemetry centralTelemetry(ResourceDto dto) {
    final data = dto.data;
    return CentralControlTelemetry(
      controllerId: dto.id ?? _string(data['controllerId'], fallback: 'CTRL-FIELD'),
      controllerState: _enumValue(
        CentralControllerState.values,
        data['controllerState'],
        CentralControllerState.offline,
      ),
      pumpStatus: _enumValue(PumpStatus.values, data['pumpStatus'], PumpStatus.off),
      valveStatus: _enumValue(
        MainValveStatus.values,
        data['valveStatus'],
        MainValveStatus.closed,
      ),
      irrigationState: _enumValue(
        IrrigationState.values,
        data['irrigationState'],
        IrrigationState.idle,
      ),
      startTime: _date(data['startTime']),
      durationMinutes: _intNullable(data['durationMinutes']),
      flowRateLitersPerMin: _double(data['flowRateLitersPerMin']),
      linePressureBar: _double(data['linePressureBar']),
      lastUpdated: _date(data['lastUpdated'] ?? data['updatedAt']) ?? DateTime.now(),
      target: _string(data['target'], fallback: CentralControlTelemetry.fixedTarget),
      isStale: data['isStale'] as bool? ?? false,
    );
  }

  static ControlCommandResult commandResult(
    ResourceDto dto,
    CommandType type,
  ) {
    final data = dto.data;
    return ControlCommandResult(
      commandId: dto.id ?? _string(data['commandId'], fallback: 'API-COMMAND'),
      type: type,
      outcome: _enumValue(CommandOutcome.values, data['outcome'], CommandOutcome.failed),
      message: _string(data['message'], fallback: 'Command response received.'),
      timestamp: _date(data['timestamp']) ?? DateTime.now(),
    );
  }

  static String _string(Object? value, {required String fallback}) =>
      value?.toString() ?? fallback;

  static int _int(Object? value, {int fallback = 0}) =>
      int.tryParse(value?.toString() ?? '') ?? fallback;

  static int? _intNullable(Object? value) =>
      value == null ? null : int.tryParse(value.toString());

  static double _double(Object? value, {double fallback = 0}) =>
      double.tryParse(value?.toString() ?? '') ?? fallback;

  static double? _doubleNullable(Object? value) =>
      value == null ? null : double.tryParse(value.toString());

  static List<double> _doubles(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => _double(item)).toList(growable: false);
  }

  static List<String> _strings(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  static ZoneStatus _zoneStatus(Object? value) => _enumValue(
        ZoneStatus.values,
        value,
        ZoneStatus.offline,
      );

  static T _enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) {
    final name = raw?.toString().split('.').last;
    return values.firstWhere(
      (value) => value.name == name,
      orElse: () => fallback,
    );
  }
}
