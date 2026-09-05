import 'package:aquaflow_frontend/features/zones/domain/models/monitoring_zone.dart';

MonitoringZone sampleZone({
  required String code,
  double waterLevelCm = 5.0,
  double soilMoisturePercent = 55.0,
  bool isOnline = true,
  List<double>? history,
}) {
  final hist = history ?? const [5.0, 5.0, 5.0];
  return MonitoringZone(
    id: 'zone-$code',
    code: code,
    name: 'Monitoring $code',
    soilMoisturePercent: soilMoisturePercent,
    waterLevelCm: waterLevelCm,
    temperatureCelsius: 28.0,
    humidityPercent: 70.0,
    batteryPercent: 80,
    status: isOnline ? ZoneStatus.optimal : ZoneStatus.offline,
    lastUpdated: DateTime.now(),
    isOnline: isOnline,
    rssiDbm: -70,
    snrDb: 8.0,
    hardwareModel: 'AquaSense LoRa Node',
    firmwareVersion: '1.0.0',
    waterLevelHistory: hist,
    waterLevelHistory24h: hist,
    waterLevelHistory7d: hist,
  );
}

List<MonitoringZone> sampleFieldZones({
  double depth = 5.0,
  bool drying = false,
}) {
  final history = drying ? const [8.0, 6.0, 4.0, 2.0] : const [4.0, 4.5, 5.0, 5.5];
  return [
    sampleZone(code: 'Q1', waterLevelCm: depth, history: history),
    sampleZone(code: 'Q2', waterLevelCm: depth, history: history),
    sampleZone(code: 'Q3', waterLevelCm: depth, history: history),
    sampleZone(code: 'Q4', waterLevelCm: depth, history: history),
  ];
}
