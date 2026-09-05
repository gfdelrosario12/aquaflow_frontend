import '../../domain/models/field_alert.dart';
import '../../domain/models/field_dashboard_summary.dart';
import '../../domain/models/field_recommendation.dart';
import '../../../irrigation/data/repositories/irrigation_repository.dart';
import '../../../irrigation/domain/models/centralized_irrigation.dart';
import '../../../zones/data/repositories/zone_repository.dart';
import '../../../zones/domain/models/monitoring_zone.dart';

enum MockState { normal, empty, stale, error }

abstract class FieldDashboardRepository {
  Future<FieldDashboardSummary> fetchDashboardSummary({
    MockState mockState = MockState.normal,
  });
}

class FieldDashboardRepositoryImpl implements FieldDashboardRepository {
  final ZoneRepository _zoneRepository;
  final IrrigationRepository _irrigationRepository;

  FieldDashboardRepositoryImpl({
    ZoneRepository? zoneRepository,
    IrrigationRepository? irrigationRepository,
  })  : _zoneRepository = zoneRepository ?? ZoneRepositoryImpl(),
        _irrigationRepository =
            irrigationRepository ?? IrrigationRepositoryImpl();

  @override
  Future<FieldDashboardSummary> fetchDashboardSummary({
    MockState mockState = MockState.normal,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (mockState == MockState.error) {
      throw Exception(
        'Field Gateway Connection Error: Unable to fetch live field telemetry.',
      );
    }

    if (mockState == MockState.empty) {
      final now = DateTime.now();
      return FieldDashboardSummary(
        overallCondition: FieldConditionStatus.optimal,
        overallConditionLabel: 'No Field Data Received',
        awdStatusLabel: 'Unmonitored Field State',
        requiresIrrigation: false,
        isIrrigationRunning: false,
        recommendedActionText: 'Deploy telemetry sensor nodes to begin field monitoring.',
        lastUpdated: now,
        centralIrrigation: CentralizedIrrigation(
          id: 'sys-empty',
          systemName: 'Central Field Pump System',
          mainPumpState: PumpState.offline,
          distributionValveState: ValveState.closed,
          flowRateLitersPerMin: 0.0,
          pressureBar: 0.0,
          mode: SystemMode.manual,
          activeDurationMinutes: 0,
          lastStateChange: now,
        ),
        monitoringZones: const [],
        activeAlerts: const [],
        recommendations: const [],
      );
    }

    final zones = await _zoneRepository.fetchMonitoringZones();
    final system = await _irrigationRepository.fetchSystemStatus();

    final now = DateTime.now();
    final lastUpdated = mockState == MockState.stale
        ? now.subtract(const Duration(hours: 3))
        : now.subtract(const Duration(minutes: 4));

    // Find wetter vs drier zones
    MonitoringZone? wetterZone;
    MonitoringZone? drierZone;
    if (zones.isNotEmpty) {
      wetterZone = zones.reduce(
        (a, b) => a.soilMoisturePercent > b.soilMoisturePercent ? a : b,
      );
      drierZone = zones.reduce(
        (a, b) => a.soilMoisturePercent < b.soilMoisturePercent ? a : b,
      );
    }

    final isPumpRunning = system.mainPumpState == PumpState.active;
    final needsWater = drierZone != null && drierZone.soilMoisturePercent < 45;

    final condition = needsWater
        ? FieldConditionStatus.refluxNeeded
        : FieldConditionStatus.optimal;

    final conditionLabel = needsWater
        ? 'Reflux Irrigation Recommended'
        : 'Optimal Moisture Balance';

    final awdLabel = needsWater
        ? 'AWD Reflux Required'
        : 'Safe AWD Drying';

    final actionText = needsWater
        ? 'Activate centralized irrigation to supply drier quadrant ${drierZone.code}.'
        : 'No immediate irrigation required. Maintain current AWD monitoring.';

    final alerts = [
      if (needsWater)
        FieldAlert(
          id: 'alert-1',
          title: 'Low Moisture Level in ${drierZone.code}',
          message:
              '${drierZone.code} moisture is ${drierZone.soilMoisturePercent.toStringAsFixed(1)}%, reaching the AWD threshold.',
          severity: AlertSeverity.warning,
          timestamp: now.subtract(const Duration(minutes: 18)),
          zoneCode: drierZone.code,
        ),
      FieldAlert(
        id: 'alert-2',
        title: 'Central Pump Operational',
        message:
            'Centralized irrigation system is ${isPumpRunning ? "active" : "idle"}.',
        severity: AlertSeverity.info,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
    ];

    final recommendations = [
      if (needsWater)
        FieldRecommendation(
          id: 'rec-1',
          title: 'Run Centralized Irrigation Pulse',
          description:
              'Quadrants ${drierZone.code} and others require moisture replenishment. Run the central pump for 45–60 mins.',
          urgency: RecommendationUrgency.high,
          actionType: ActionableType.startCentralIrrigation,
          recommendedDurationMinutes: 60,
        )
      else
        const FieldRecommendation(
          id: 'rec-2',
          title: 'Maintain AWD Soil Aeration',
          description:
              'Overall moisture balance across Q1–Q4 is within optimal range. Continue observation.',
          urgency: RecommendationUrgency.low,
          actionType: ActionableType.noActionNeeded,
        ),
    ];

    return FieldDashboardSummary(
      overallCondition: condition,
      overallConditionLabel: conditionLabel,
      awdStatusLabel: awdLabel,
      requiresIrrigation: needsWater,
      isIrrigationRunning: isPumpRunning,
      recommendedActionText: actionText,
      wetterZoneCode: wetterZone?.code,
      drierZoneCode: drierZone?.code,
      lastUpdated: lastUpdated,
      centralIrrigation: system,
      monitoringZones: zones,
      activeAlerts: alerts,
      recommendations: recommendations,
      forceStale: mockState == MockState.stale,
    );
  }
}
