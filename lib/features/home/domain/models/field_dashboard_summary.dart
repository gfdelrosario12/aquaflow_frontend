import '../../../awd/domain/models/awd_automation_eligibility.dart';
import '../../../awd/domain/models/awd_confidence.dart';
import '../../../irrigation/domain/models/centralized_irrigation.dart';
import '../../../zones/domain/models/monitoring_zone.dart';
import 'field_alert.dart';
import 'field_recommendation.dart';

enum FieldConditionStatus { optimal, refluxNeeded, flooded, criticallyDry }

class FieldDashboardSummary {
  final FieldConditionStatus overallCondition;
  final String overallConditionLabel;
  final String awdStatusLabel;
  final bool requiresIrrigation;
  final bool isIrrigationRunning;
  final String recommendedActionText;
  final String? wetterZoneCode;
  final String? drierZoneCode;
  final DateTime lastUpdated;
  final CentralizedIrrigation centralIrrigation;
  final List<MonitoringZone> monitoringZones;
  final List<FieldAlert> activeAlerts;
  final List<FieldRecommendation> recommendations;
  final bool forceStale;
  final AwdConfidence? confidence;
  final AwdAutomationEligibility? autoEligibility;

  const FieldDashboardSummary({
    required this.overallCondition,
    required this.overallConditionLabel,
    required this.awdStatusLabel,
    required this.requiresIrrigation,
    required this.isIrrigationRunning,
    required this.recommendedActionText,
    this.wetterZoneCode,
    this.drierZoneCode,
    required this.lastUpdated,
    required this.centralIrrigation,
    required this.monitoringZones,
    required this.activeAlerts,
    required this.recommendations,
    this.forceStale = false,
    this.confidence,
    this.autoEligibility,
  });

  bool get isStale =>
      forceStale || DateTime.now().difference(lastUpdated).inMinutes >= 15;
}

