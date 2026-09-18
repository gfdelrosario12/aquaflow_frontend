typedef JsonMap = Map<String, dynamic>;

class ResourceDto {
  final String? id;
  final JsonMap data;

  const ResourceDto({this.id, required this.data});

  factory ResourceDto.fromJson(Object? json) {
    if (json is! JsonMap) {
      throw const FormatException('Expected a JSON object.');
    }
    final rawId = json['id'];
    return ResourceDto(
      id: rawId?.toString(),
      data: Map<String, dynamic>.from(json),
    );
  }
}

class ResourceListDto {
  final List<ResourceDto> items;

  const ResourceListDto(this.items);

  factory ResourceListDto.fromJson(Object? json) {
    final rawItems = json is List
        ? json
        : json is JsonMap && json['items'] is List
            ? json['items'] as List
            : const [];
    return ResourceListDto(
      rawItems.map(ResourceDto.fromJson).toList(growable: false),
    );
  }
}

class AuthResponseDto {
  final String accessToken;
  final String? refreshToken;
  final JsonMap user;

  const AuthResponseDto({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Object? json) {
    if (json is! JsonMap || json['accessToken'] is! String) {
      throw const FormatException('Authentication response is missing accessToken.');
    }
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] is JsonMap
          ? Map<String, dynamic>.from(json['user'] as JsonMap)
          : const {},
    );
  }
}

class IrrigationCommandDto {
  static const entireField = 'ENTIRE FIELD';

  final String target;
  final int? durationMinutes;

  const IrrigationCommandDto({
    this.target = entireField,
    this.durationMinutes,
  });

  JsonMap toJson() {
    if (target != entireField) {
      throw const FormatException('Irrigation commands require ENTIRE FIELD target.');
    }
    return {
      'target': target,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
    };
  }
}

class IrrigationResultDto {
  final JsonMap data;

  const IrrigationResultDto(this.data);

  factory IrrigationResultDto.fromJson(Object? json) {
    if (json is! JsonMap) {
      throw const FormatException('Irrigation response is not an object.');
    }
    return IrrigationResultDto(Map<String, dynamic>.from(json));
  }
}

class Esp32NodeDto {
  final String id;
  final String macAddress;
  final String displayName;
  final String? assignedFieldId;
  final String? assignedZoneId;
  final double? latitude;
  final double? longitude;
  final double? localX;
  final double? localY;
  final int transmissionIntervalSeconds;
  final bool isAdaptive;
  final String? adaptiveReason;
  final bool isOnline;
  final int? batteryPercent;
  final double? batteryVoltage;
  final int? rssiDbm;
  final double? snrDb;
  final String? lastSeen;
  final JsonMap? latestTelemetry;

  const Esp32NodeDto({
    required this.id,
    required this.macAddress,
    required this.displayName,
    this.assignedFieldId,
    this.assignedZoneId,
    this.latitude,
    this.longitude,
    this.localX,
    this.localY,
    required this.transmissionIntervalSeconds,
    this.isAdaptive = false,
    this.adaptiveReason,
    this.isOnline = true,
    this.batteryPercent,
    this.batteryVoltage,
    this.rssiDbm,
    this.snrDb,
    this.lastSeen,
    this.latestTelemetry,
  });

  factory Esp32NodeDto.fromJson(JsonMap json) {
    return Esp32NodeDto(
      id: json['id']?.toString() ?? '',
      macAddress: json['macAddress']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['name']?.toString() ?? 'ESP32 Node',
      assignedFieldId: json['assignedFieldId']?.toString(),
      assignedZoneId: json['assignedZoneId']?.toString(),
      latitude: json['latitude'] == null ? null : double.tryParse(json['latitude'].toString()),
      longitude: json['longitude'] == null ? null : double.tryParse(json['longitude'].toString()),
      localX: json['localX'] == null ? null : double.tryParse(json['localX'].toString()),
      localY: json['localY'] == null ? null : double.tryParse(json['localY'].toString()),
      transmissionIntervalSeconds: int.tryParse(json['transmissionIntervalSeconds']?.toString() ?? '') ?? 300,
      isAdaptive: json['isAdaptive'] as bool? ?? false,
      adaptiveReason: json['adaptiveReason']?.toString(),
      isOnline: json['isOnline'] as bool? ?? false,
      batteryPercent: json['batteryPercent'] == null ? null : int.tryParse(json['batteryPercent'].toString()),
      batteryVoltage: json['batteryVoltage'] == null ? null : double.tryParse(json['batteryVoltage'].toString()),
      rssiDbm: json['rssiDbm'] == null ? null : int.tryParse(json['rssiDbm'].toString()),
      snrDb: json['snrDb'] == null ? null : double.tryParse(json['snrDb'].toString()),
      lastSeen: json['lastSeen']?.toString(),
      latestTelemetry: json['latestTelemetry'] is JsonMap ? json['latestTelemetry'] as JsonMap : null,
    );
  }

  JsonMap toJson() => {
        'id': id,
        'macAddress': macAddress,
        'displayName': displayName,
        'assignedFieldId': assignedFieldId,
        'assignedZoneId': assignedZoneId,
        'latitude': latitude,
        'longitude': longitude,
        'localX': localX,
        'localY': localY,
        'transmissionIntervalSeconds': transmissionIntervalSeconds,
        'isAdaptive': isAdaptive,
        'adaptiveReason': adaptiveReason,
        'isOnline': isOnline,
        'batteryPercent': batteryPercent,
        'batteryVoltage': batteryVoltage,
        'rssiDbm': rssiDbm,
        'snrDb': snrDb,
        'lastSeen': lastSeen,
        'latestTelemetry': latestTelemetry,
      };
}

class DiscoveredNodeDto {
  final String id;
  final String macAddress;
  final String hardwareModel;
  final String firmwareVersion;
  final int rssiDbm;
  final String detectedAt;

  const DiscoveredNodeDto({
    required this.id,
    required this.macAddress,
    required this.hardwareModel,
    required this.firmwareVersion,
    required this.rssiDbm,
    required this.detectedAt,
  });

  factory DiscoveredNodeDto.fromJson(JsonMap json) => DiscoveredNodeDto(
        id: json['id']?.toString() ?? '',
        macAddress: json['macAddress']?.toString() ?? '',
        hardwareModel: json['hardwareModel']?.toString() ?? 'ESP32 LoRa Node',
        firmwareVersion: json['firmwareVersion']?.toString() ?? '1.0.0',
        rssiDbm: int.tryParse(json['rssiDbm']?.toString() ?? '') ?? -85,
        detectedAt: json['detectedAt']?.toString() ?? DateTime.now().toIso8601String(),
      );
}

class NodeRegistrationRequestDto {
  final String macAddress;
  final String displayName;
  final String fieldId;
  final String zoneId;
  final double? latitude;
  final double? longitude;
  final double? localX;
  final double? localY;
  final int transmissionIntervalSeconds;

  const NodeRegistrationRequestDto({
    required this.macAddress,
    required this.displayName,
    required this.fieldId,
    required this.zoneId,
    this.latitude,
    this.longitude,
    this.localX,
    this.localY,
    this.transmissionIntervalSeconds = 300,
  });

  JsonMap toJson() => {
        'macAddress': macAddress,
        'displayName': displayName,
        'fieldId': fieldId,
        'zoneId': zoneId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (localX != null) 'localX': localX,
        if (localY != null) 'localY': localY,
        'transmissionIntervalSeconds': transmissionIntervalSeconds,
      };
}

class NodeSpatialAssignmentDto {
  final String fieldId;
  final String zoneId;
  final double? latitude;
  final double? longitude;
  final double? localX;
  final double? localY;

  const NodeSpatialAssignmentDto({
    required this.fieldId,
    required this.zoneId,
    this.latitude,
    this.longitude,
    this.localX,
    this.localY,
  });

  JsonMap toJson() => {
        'fieldId': fieldId,
        'zoneId': zoneId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (localX != null) 'localX': localX,
        if (localY != null) 'localY': localY,
      };
}

class TransmissionConfigDto {
  final int intervalSeconds;
  final bool isAdaptive;
  final String? reason;

  const TransmissionConfigDto({
    required this.intervalSeconds,
    this.isAdaptive = false,
    this.reason,
  });

  factory TransmissionConfigDto.fromJson(JsonMap json) => TransmissionConfigDto(
        intervalSeconds: int.tryParse(json['intervalSeconds']?.toString() ??
                json['transmissionIntervalSeconds']?.toString() ??
                '') ??
            300,
        isAdaptive: json['isAdaptive'] as bool? ?? false,
        reason: json['reason']?.toString() ?? json['adaptiveReason']?.toString(),
      );

  JsonMap toJson() => {
        'intervalSeconds': intervalSeconds,
        'isAdaptive': isAdaptive,
        if (reason != null) 'reason': reason,
      };
}

class MeasurementDto {
  final String id;
  final String timestamp;
  final String sensorId;
  final String pointId;
  final double rawValue;
  final double calibratedValue;
  final String qualityFlag;

  const MeasurementDto({
    required this.id,
    required this.timestamp,
    required this.sensorId,
    required this.pointId,
    required this.rawValue,
    required this.calibratedValue,
    this.qualityFlag = 'valid',
  });

  factory MeasurementDto.fromJson(JsonMap json) => MeasurementDto(
        id: json['id']?.toString() ?? '',
        timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
        sensorId: json['sensorId']?.toString() ?? '',
        pointId: json['pointId']?.toString() ?? '',
        rawValue: (json['rawValue'] as num?)?.toDouble() ?? 0.0,
        calibratedValue: (json['calibratedValue'] as num?)?.toDouble() ?? 0.0,
        qualityFlag: json['qualityFlag']?.toString() ?? 'valid',
      );

  JsonMap toJson() => {
        'id': id,
        'timestamp': timestamp,
        'sensorId': sensorId,
        'pointId': pointId,
        'rawValue': rawValue,
        'calibratedValue': calibratedValue,
        'qualityFlag': qualityFlag,
      };
}

class SensorDto {
  final String id;
  final String nodeId;
  final String type;
  final int channelIndex;
  final String unit;
  final double? depthOffsetCm;
  final Map<String, double>? calibrationCoefficients;
  final MeasurementDto? latestMeasurement;
  final bool isActive;

  const SensorDto({
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

  factory SensorDto.fromJson(JsonMap json) => SensorDto(
        id: json['id']?.toString() ?? '',
        nodeId: json['nodeId']?.toString() ?? '',
        type: json['type']?.toString() ?? 'waterLevelTube',
        channelIndex: int.tryParse(json['channelIndex']?.toString() ?? '') ?? 0,
        unit: json['unit']?.toString() ?? '',
        depthOffsetCm: json['depthOffsetCm'] == null
            ? null
            : double.tryParse(json['depthOffsetCm'].toString()),
        calibrationCoefficients: (json['calibrationCoefficients'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
        latestMeasurement: json['latestMeasurement'] is JsonMap
            ? MeasurementDto.fromJson(json['latestMeasurement'] as JsonMap)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );

  JsonMap toJson() => {
        'id': id,
        'nodeId': nodeId,
        'type': type,
        'channelIndex': channelIndex,
        'unit': unit,
        if (depthOffsetCm != null) 'depthOffsetCm': depthOffsetCm,
        if (calibrationCoefficients != null)
          'calibrationCoefficients': calibrationCoefficients,
        if (latestMeasurement != null)
          'latestMeasurement': latestMeasurement!.toJson(),
        'isActive': isActive,
      };
}

class MonitoringPointDto {
  final String id;
  final String fieldId;
  final String zoneId;
  final String code;
  final String label;
  final double? latitude;
  final double? longitude;
  final double? localX;
  final double? localY;
  final double? elevationMeters;
  final double relativeElevationCm;
  final double tubeDatumOffsetCm;
  final String? assignedNodeId;
  final bool isActive;

  const MonitoringPointDto({
    required this.id,
    required this.fieldId,
    required this.zoneId,
    required this.code,
    required this.label,
    this.latitude,
    this.longitude,
    this.localX,
    this.localY,
    this.elevationMeters,
    this.relativeElevationCm = 0.0,
    this.tubeDatumOffsetCm = 0.0,
    this.assignedNodeId,
    this.isActive = true,
  });

  factory MonitoringPointDto.fromJson(JsonMap json) => MonitoringPointDto(
        id: json['id']?.toString() ?? '',
        fieldId: json['fieldId']?.toString() ?? '',
        zoneId: json['zoneId']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        label: json['label']?.toString() ?? json['code']?.toString() ?? '',
        latitude: json['latitude'] == null
            ? null
            : double.tryParse(json['latitude'].toString()),
        longitude: json['longitude'] == null
            ? null
            : double.tryParse(json['longitude'].toString()),
        localX: json['localX'] == null
            ? null
            : double.tryParse(json['localX'].toString()),
        localY: json['localY'] == null
            ? null
            : double.tryParse(json['localY'].toString()),
        elevationMeters: json['elevationMeters'] == null
            ? null
            : double.tryParse(json['elevationMeters'].toString()),
        relativeElevationCm:
            double.tryParse(json['relativeElevationCm']?.toString() ?? '') ?? 0.0,
        tubeDatumOffsetCm:
            double.tryParse(json['tubeDatumOffsetCm']?.toString() ?? '') ?? 0.0,
        assignedNodeId: json['assignedNodeId']?.toString(),
        isActive: json['isActive'] as bool? ?? true,
      );

  JsonMap toJson() => {
        'id': id,
        'fieldId': fieldId,
        'zoneId': zoneId,
        'code': code,
        'label': label,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (localX != null) 'localX': localX,
        if (localY != null) 'localY': localY,
        if (elevationMeters != null) 'elevationMeters': elevationMeters,
        'relativeElevationCm': relativeElevationCm,
        'tubeDatumOffsetCm': tubeDatumOffsetCm,
        if (assignedNodeId != null) 'assignedNodeId': assignedNodeId,
        'isActive': isActive,
      };
}

class FieldDto {
  final String id;
  final String name;
  final String? description;
  final double areaSquareMeters;
  final String soilType;
  final String activeCropStage;
  final String awdProfileId;
  final String? centralControllerId;
  final List<Map<String, double>> boundaryCoordinates;
  final String createdAt;
  final String updatedAt;

  const FieldDto({
    required this.id,
    required this.name,
    this.description,
    this.areaSquareMeters = 10000.0,
    this.soilType = 'Clay Loam',
    this.activeCropStage = 'vegetativeTillering',
    this.awdProfileId = 'awd_standard_vegetative',
    this.centralControllerId,
    this.boundaryCoordinates = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory FieldDto.fromJson(JsonMap json) => FieldDto(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        areaSquareMeters: (json['areaSquareMeters'] as num?)?.toDouble() ?? 10000.0,
        soilType: json['soilType']?.toString() ?? 'Clay Loam',
        activeCropStage: json['activeCropStage']?.toString() ?? 'vegetativeTillering',
        awdProfileId: json['awdProfileId']?.toString() ?? 'awd_standard_vegetative',
        centralControllerId: json['centralControllerId']?.toString(),
        boundaryCoordinates: (json['boundaryCoordinates'] as List<dynamic>?)
                ?.map((item) => (item as Map<String, dynamic>)
                    .map((k, v) => MapEntry(k, (v as num).toDouble())))
                .toList() ??
            const [],
        createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt: json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      );

  JsonMap toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
        'areaSquareMeters': areaSquareMeters,
        'soilType': soilType,
        'activeCropStage': activeCropStage,
        'awdProfileId': awdProfileId,
        if (centralControllerId != null)
          'centralControllerId': centralControllerId,
        'boundaryCoordinates': boundaryCoordinates,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class FieldTopologyDto {
  final FieldDto field;
  final List<MonitoringPointDto> points;
  final List<Esp32NodeDto> nodes;

  const FieldTopologyDto({
    required this.field,
    this.points = const [],
    this.nodes = const [],
  });

  factory FieldTopologyDto.fromJson(JsonMap json) => FieldTopologyDto(
        field: FieldDto.fromJson(json['field'] as JsonMap? ?? {}),
        points: (json['points'] as List<dynamic>?)
                ?.map((e) => MonitoringPointDto.fromJson(e as JsonMap))
                .toList() ??
            const [],
        nodes: (json['nodes'] as List<dynamic>?)
                ?.map((e) => Esp32NodeDto.fromJson(e as JsonMap))
                .toList() ??
            const [],
      );

  JsonMap toJson() => {
        'field': field.toJson(),
        'points': points.map((p) => p.toJson()).toList(),
        'nodes': nodes.map((n) => n.toJson()).toList(),
      };
}


