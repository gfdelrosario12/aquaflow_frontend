enum ZoneStatus { optimal, warning, critical, offline }
enum TrendDirection { wetter, drier, stable }

class ZoneTrendAnalysis {
  final TrendDirection direction;
  final double rateCmPerHour;
  final String label;

  const ZoneTrendAnalysis({
    required this.direction,
    required this.rateCmPerHour,
    required this.label,
  });

  factory ZoneTrendAnalysis.fromHistory(List<double> history) {
    if (history.length < 2) {
      return const ZoneTrendAnalysis(
        direction: TrendDirection.stable,
        rateCmPerHour: 0.0,
        label: 'Stable (0.0 cm/h)',
      );
    }
    final first = history.first;
    final last = history.last;
    final delta = last - first;
    final hours = (history.length - 1).toDouble();
    final rate = delta / (hours > 0 ? hours : 1.0);

    if (delta > 0.2) {
      return ZoneTrendAnalysis(
        direction: TrendDirection.wetter,
        rateCmPerHour: rate,
        label: 'Wetter (+${rate.toStringAsFixed(1)} cm/h)',
      );
    } else if (delta < -0.2) {
      return ZoneTrendAnalysis(
        direction: TrendDirection.drier,
        rateCmPerHour: rate,
        label: 'Drier (${rate.toStringAsFixed(1)} cm/h)',
      );
    } else {
      final sign = rate >= 0 ? '+' : '';
      return ZoneTrendAnalysis(
        direction: TrendDirection.stable,
        rateCmPerHour: rate,
        label: 'Stable ($sign${rate.toStringAsFixed(1)} cm/h)',
      );
    }
  }
}

class MonitoringZone {
  final String id;
  final String code; // Q1, Q2, Q3, Q4
  final String name;
  final double soilMoisturePercent;
  final double waterLevelCm;
  final double temperatureCelsius;
  final double humidityPercent;
  final int batteryPercent;
  final ZoneStatus status;
  final DateTime lastUpdated;
  final bool isOnline;
  final int rssiDbm;
  final double snrDb;
  final String hardwareModel;
  final String firmwareVersion;
  final List<double> waterLevelHistory;
  final List<double> waterLevelHistory24h;
  final List<double> waterLevelHistory7d;

  const MonitoringZone({
    required this.id,
    required this.code,
    required this.name,
    required this.soilMoisturePercent,
    required this.waterLevelCm,
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.batteryPercent,
    required this.status,
    required this.lastUpdated,
    this.isOnline = true,
    this.rssiDbm = -85,
    this.snrDb = 9.2,
    this.hardwareModel = 'AquaSense LoRa Node v2',
    this.firmwareVersion = 'v1.4.2',
    this.waterLevelHistory = const [4.5, 4.8, 5.0, 5.2, 5.1],
    this.waterLevelHistory24h = const [4.2, 4.5, 4.8, 5.0, 5.2],
    this.waterLevelHistory7d = const [3.5, 4.0, 4.5, 4.8, 5.2],
  });

  ZoneTrendAnalysis get trendAnalysis =>
      ZoneTrendAnalysis.fromHistory(waterLevelHistory);

  ZoneTrendAnalysis trendAnalysisFor(List<double> history) =>
      ZoneTrendAnalysis.fromHistory(history);

  MonitoringZone copyWith({
    String? id,
    String? code,
    String? name,
    double? soilMoisturePercent,
    double? waterLevelCm,
    double? temperatureCelsius,
    double? humidityPercent,
    int? batteryPercent,
    ZoneStatus? status,
    DateTime? lastUpdated,
    bool? isOnline,
    int? rssiDbm,
    double? snrDb,
    String? hardwareModel,
    String? firmwareVersion,
    List<double>? waterLevelHistory,
    List<double>? waterLevelHistory24h,
    List<double>? waterLevelHistory7d,
  }) {
    return MonitoringZone(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      soilMoisturePercent: soilMoisturePercent ?? this.soilMoisturePercent,
      waterLevelCm: waterLevelCm ?? this.waterLevelCm,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOnline: isOnline ?? this.isOnline,
      rssiDbm: rssiDbm ?? this.rssiDbm,
      snrDb: snrDb ?? this.snrDb,
      hardwareModel: hardwareModel ?? this.hardwareModel,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      waterLevelHistory: waterLevelHistory ?? this.waterLevelHistory,
      waterLevelHistory24h: waterLevelHistory24h ?? this.waterLevelHistory24h,
      waterLevelHistory7d: waterLevelHistory7d ?? this.waterLevelHistory7d,
    );
  }
}
