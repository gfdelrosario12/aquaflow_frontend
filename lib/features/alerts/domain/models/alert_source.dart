import 'alert_enums.dart';

/// Contextual source attribution for an alert
class AlertSource {
  final String id;
  final String name;
  final AlertSourceType type;
  final String targetScope;

  static const AlertSource centralIrrigation = AlertSource(
    id: 'SRC-CTRL-01',
    name: 'Centralized Irrigation System',
    type: AlertSourceType.centralIrrigation,
    targetScope: 'ENTIRE FIELD',
  );

  static const AlertSource gateway = AlertSource(
    id: 'SRC-GW-01',
    name: 'Field LoRaWAN Gateway',
    type: AlertSourceType.gateway,
    targetScope: 'ENTIRE FIELD',
  );

  const AlertSource({
    required this.id,
    required this.name,
    required this.type,
    required this.targetScope,
  });

  factory AlertSource.monitoringZone(String zoneId) {
    return AlertSource(
      id: 'SRC-ZONE-$zoneId',
      name: 'Monitoring Quadrant $zoneId',
      type: AlertSourceType.monitoringZone,
      targetScope: zoneId,
    );
  }
}

