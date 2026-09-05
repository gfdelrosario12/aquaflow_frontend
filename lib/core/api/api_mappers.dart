import '../../features/control/domain/models/central_control_telemetry.dart';
import '../../features/control/domain/models/control_command_result.dart';
import '../../features/control/domain/models/control_enums.dart';
import '../../features/auth/domain/models/auth_token.dart';
import '../../features/auth/domain/models/user_session.dart';
import '../../features/zones/domain/models/monitoring_zone.dart';
import 'api_dtos.dart';

class ApiMappers {
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

  static List<double> _doubles(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => _double(item)).toList(growable: false);
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
