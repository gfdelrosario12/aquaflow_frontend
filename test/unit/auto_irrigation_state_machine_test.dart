import 'package:flutter_test/flutter_test.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_analytics_summary.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_automation_eligibility.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_confidence.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_recommendation.dart';
import 'package:aquaflow_frontend/features/awd/domain/models/awd_threshold_config.dart';
import 'package:aquaflow_frontend/features/irrigation/data/datasources/irrigation_data_source.dart';
import 'package:aquaflow_frontend/features/irrigation/data/repositories/irrigation_repository.dart';
import 'package:aquaflow_frontend/features/irrigation/domain/models/auto_irrigation_config.dart';
import 'package:aquaflow_frontend/features/irrigation/domain/models/auto_irrigation_status.dart';
import 'package:aquaflow_frontend/features/irrigation/domain/models/irrigation_execution_audit_log.dart';
import 'package:aquaflow_frontend/features/irrigation/presentation/providers/irrigation_notifier.dart';

AwdAnalyticsSummary _eligibleSummary({
  int recommendedMinutes = 30,
  bool eligible = true,
  List<String> inhibitions = const [],
}) {
  return AwdAnalyticsSummary(
    fieldStatus: FieldAwdStatus.refloodNeeded,
    averageWaterDepthCm: -15.2,
    minWaterDepthCm: -16.0,
    maxWaterDepthCm: -14.0,
    averageSoilMoisturePercent: 40.0,
    zoneDryingRates: const [],
    activeThresholdConfig: const AwdThresholdConfig(),
    recommendation: AwdRecommendation(
      action: IrrigationAction.irrigate,
      urgency: RecommendationUrgency.high,
      title: 'Reflood Needed',
      rationale: 'Field below trigger',
      keyFactors: const ['Depth below threshold'],
      generatedAt: DateTime(2026, 9, 19, 10),
    ),
    reportingZones: const [],
    totalNodes: 4,
    activeNodes: 4,
    confidence: const AwdConfidence(
      level: AwdConfidenceLevel.high,
      score: 0.9,
      coverageRatio: 1.0,
      freshnessScore: 1.0,
      validityRatio: 1.0,
      contributingFactors: [],
      summaryMessage: 'High confidence',
    ),
    lastUpdated: DateTime(2026, 9, 19, 10),
    autoEligibility: AwdAutomationEligibility(
      isEligibleForAutoIrrigation: eligible,
      recommendedDurationMinutes: recommendedMinutes,
      inhibitionReasons: inhibitions,
      summaryRationale: eligible
          ? 'Eligible for automated reflood'
          : 'Inhibited: ${inhibitions.join(', ')}',
      evaluatedAt: DateTime(2026, 9, 19, 10),
    ),
  );
}

void main() {
  group('AutoIrrigationStatus helpers', () {
    test('remainingCooldown returns null when no cooldown set', () {
      const status = AutoIrrigationStatus(state: AutoIrrigationState.standby);
      expect(status.remainingCooldown(), isNull);
    });

    test('remainingCooldown clamps to zero when expired', () {
      final status = AutoIrrigationStatus(
        state: AutoIrrigationState.cooldown,
        cooldownUntil: DateTime(2026, 9, 19, 9),
      );
      final remaining =
          status.remainingCooldown(DateTime(2026, 9, 19, 10));
      expect(remaining, equals(Duration.zero));
    });

    test('remainingIrrigationDuration computes leftover minutes', () {
      final status = AutoIrrigationStatus(
        state: AutoIrrigationState.irrigating,
        startedAt: DateTime(2026, 9, 19, 10),
        targetDurationMinutes: 30,
      );
      final remaining =
          status.remainingIrrigationDuration(DateTime(2026, 9, 19, 10, 10));
      expect(remaining, equals(const Duration(minutes: 20)));
    });

    test('isInAllowedHours handles overnight windows', () {
      const overnight = AutoIrrigationConfig(
        allowedHoursStart: 20,
        allowedHoursEnd: 6,
      );
      expect(overnight.isInAllowedHours(DateTime(2026, 9, 19, 22)), isTrue);
      expect(overnight.isInAllowedHours(DateTime(2026, 9, 19, 3)), isTrue);
      expect(overnight.isInAllowedHours(DateTime(2026, 9, 19, 12)), isFalse);
    });
  });

  group('IrrigationNotifier state machine', () {
    late IrrigationNotifier notifier;
    late MockIrrigationDataSource dataSource;

    setUp(() async {
      dataSource = MockIrrigationDataSource();
      const enabledConfig = AutoIrrigationConfig(
        systemId: 'sys-field-01',
        isEnabled: true,
        maxDurationMinutes: 45,
        minCooldownMinutes: 60,
        allowedHoursStart: 6,
        allowedHoursEnd: 18,
      );
      await dataSource.saveAutoIrrigationConfig(enabledConfig);
      notifier = IrrigationNotifier(
        repository: IrrigationRepositoryImpl(dataSource: dataSource),
        initialConfig: enabledConfig,
        initialStatus: const AutoIrrigationStatus(
          systemId: 'sys-field-01',
          state: AutoIrrigationState.standby,
        ),
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('does not trigger when automation is disabled', () async {
      await notifier.toggleAutomation(false);
      final triggered = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: true,
        now: DateTime(2026, 9, 19, 10),
      );
      expect(triggered, isFalse);
      expect(notifier.state.status.state, equals(AutoIrrigationState.disabled));
    });

    test('pre-flight fails when controller is offline', () async {
      final triggered = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: false,
        now: DateTime(2026, 9, 19, 10),
      );
      expect(triggered, isFalse);
      expect(notifier.state.status.state, equals(AutoIrrigationState.standby));
      expect(notifier.state.status.inhibitionReasons, contains('controllerOffline'));
    });

    test('pre-flight fails during rain delay', () async {
      final triggered = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: true,
        isRaining: true,
        now: DateTime(2026, 9, 19, 10),
      );
      expect(triggered, isFalse);
      expect(notifier.state.status.inhibitionReasons, contains('rainDelayActive'));
    });

    test('pre-flight fails outside allowed hours', () async {
      final triggered = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: true,
        now: DateTime(2026, 9, 19, 22),
      );
      expect(triggered, isFalse);
      expect(
        notifier.state.status.inhibitionReasons,
        contains('outsideAllowedHours'),
      );
    });

    test('pre-flight fails when AWD eligibility is inhibited', () async {
      final triggered = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(
          eligible: false,
          inhibitions: [AwdInhibitionReason.disparityConflict],
        ),
        isControllerOnline: true,
        now: DateTime(2026, 9, 19, 10),
      );
      expect(triggered, isFalse);
      expect(
        notifier.state.status.inhibitionReasons,
        contains(AwdInhibitionReason.disparityConflict),
      );
    });

    test('successful cycle transitions standby -> irrigating with system audit',
        () async {
      final now = DateTime(2026, 9, 19, 10);
      final triggered = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(recommendedMinutes: 30),
        isControllerOnline: true,
        now: now,
      );

      expect(triggered, isTrue);
      expect(notifier.state.status.state, equals(AutoIrrigationState.irrigating));
      expect(notifier.state.status.targetDurationMinutes, equals(30));
      expect(notifier.state.status.activeCommandId, isNotNull);
      expect(notifier.state.auditLogs, isNotEmpty);
      expect(notifier.state.auditLogs.first.actor, equals(IrrigationActor.systemAutoAwd));
      expect(notifier.state.auditLogs.first.action, equals('start'));
    });

    test('stopCycle enters cooldown and enforces minimum cooldown period',
        () async {
      final start = DateTime(2026, 9, 19, 10);
      await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: true,
        now: start,
      );

      final stopAt = start.add(const Duration(minutes: 25));
      await notifier.stopCycle(
        actor: IrrigationActor.systemAutoAwd,
        reason: 'Target duration reached',
        now: stopAt,
      );

      expect(notifier.state.status.state, equals(AutoIrrigationState.cooldown));
      expect(notifier.state.status.cooldownUntil, isNotNull);
      expect(
        notifier.state.status.cooldownUntil!
            .difference(stopAt)
            .inMinutes,
        equals(60),
      );

      // Still in cooldown — cannot re-trigger
      final blocked = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: true,
        now: stopAt.add(const Duration(minutes: 30)),
      );
      expect(blocked, isFalse);
      expect(notifier.state.status.state, equals(AutoIrrigationState.cooldown));
    });

    test('cooldown expiry returns supervisor to standby', () async {
      final start = DateTime(2026, 9, 19, 10);
      await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: true,
        now: start,
      );
      await notifier.stopCycle(
        actor: IrrigationActor.systemAutoAwd,
        now: start.add(const Duration(minutes: 30)),
      );

      final afterCooldown =
          start.add(const Duration(minutes: 30)).add(const Duration(minutes: 61));
      notifier.checkCooldownStatus(afterCooldown);

      expect(notifier.state.status.state, equals(AutoIrrigationState.standby));
      expect(notifier.state.status.cooldownUntil, isNull);
    });

    test('fault lockout blocks further automated cycles until cleared', () async {
      await notifier.triggerFaultLockout(
        'ACK timeout after 2 retries',
        now: DateTime(2026, 9, 19, 10),
      );

      expect(notifier.state.status.isFaultLocked, isTrue);

      final blocked = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(),
        isControllerOnline: true,
        now: DateTime(2026, 9, 19, 11),
      );
      expect(blocked, isFalse);

      final cleared = await notifier.clearFaultLockout(
        resolutionNote: 'Hardware inspected',
        clearedBy: 'op-01',
      );
      expect(cleared, isTrue);
      expect(notifier.state.status.state, equals(AutoIrrigationState.standby));
    });

    test('caps recommended duration by safety ceiling', () async {
      final triggered = await notifier.evaluateAndTriggerCycle(
        awdSummary: _eligibleSummary(recommendedMinutes: 90),
        isControllerOnline: true,
        now: DateTime(2026, 9, 19, 10),
      );
      expect(triggered, isTrue);
      expect(notifier.state.status.targetDurationMinutes, equals(45));
    });
  });
}
