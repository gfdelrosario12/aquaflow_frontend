import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../features/awd/domain/models/awd_analytics_summary.dart';
import '../../data/repositories/irrigation_repository.dart';
import '../../domain/models/auto_irrigation_config.dart';
import '../../domain/models/auto_irrigation_status.dart';
import '../../domain/models/irrigation_execution_audit_log.dart';

/// State representation for field-level automatic irrigation supervisor.
class IrrigationStateData {
  final AutoIrrigationConfig config;
  final AutoIrrigationStatus status;
  final List<IrrigationExecutionAuditLog> auditLogs;
  final bool isLoading;
  final String? errorMessage;

  const IrrigationStateData({
    this.config = const AutoIrrigationConfig(),
    this.status = const AutoIrrigationStatus(),
    this.auditLogs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isOperational => status.isOperational;
  bool get isActivelyIrrigating => status.isActivelyIrrigating;
  bool get isFaultLocked => status.isFaultLocked;
  bool get isInCooldown => status.isInCooldown;

  IrrigationStateData copyWith({
    AutoIrrigationConfig? config,
    AutoIrrigationStatus? status,
    List<IrrigationExecutionAuditLog>? auditLogs,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IrrigationStateData(
      config: config ?? this.config,
      status: status ?? this.status,
      auditLogs: auditLogs ?? this.auditLogs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// State notifier managing centralized automatic irrigation supervisor state,
/// pre-flight safety interlock checks, cooldown enforcement, and fault lockout recovery.
class IrrigationNotifier extends ChangeNotifier {
  final IrrigationRepository _repository;
  IrrigationStateData _state;
  bool _isDisposed = false;

  IrrigationNotifier({
    IrrigationRepository? repository,
    AutoIrrigationConfig initialConfig = const AutoIrrigationConfig(),
    AutoIrrigationStatus initialStatus = const AutoIrrigationStatus(),
  })  : _repository = repository ?? IrrigationRepositoryImpl(),
        _state = IrrigationStateData(
          config: initialConfig,
          status: initialStatus,
        );

  IrrigationStateData get state => _state;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Initial load of configuration, supervisor status, and audit trail.
  Future<void> loadAutoIrrigationData({String systemId = 'default'}) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final config = await _repository.getAutoIrrigationConfig(systemId: systemId);
      final status = await _repository.getAutoIrrigationStatus(systemId: systemId);
      final logs = await _repository.getAuditLogs(systemId: systemId);

      _state = _state.copyWith(
        config: config,
        status: status,
        auditLogs: logs,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load automatic irrigation state: $e',
      );
    }
    notifyListeners();
  }

  /// Update automatic irrigation configuration.
  Future<bool> updateConfig(AutoIrrigationConfig newConfig) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final savedConfig = await _repository.updateAutoIrrigationConfig(newConfig);
      var currentStatus = _state.status;

      if (!savedConfig.isEnabled && currentStatus.state != AutoIrrigationState.faultLocked) {
        currentStatus = currentStatus.copyWith(
          state: AutoIrrigationState.disabled,
          inhibitionReasons: const [],
        );
      } else if (savedConfig.isEnabled && currentStatus.state == AutoIrrigationState.disabled) {
        currentStatus = currentStatus.copyWith(
          state: AutoIrrigationState.standby,
        );
      }

      _state = _state.copyWith(
        config: savedConfig,
        status: currentStatus,
        isLoading: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update configuration: $e',
      );
      notifyListeners();
      return false;
    }
  }

  /// Convenience toggle for enabling or disabling automation.
  Future<bool> toggleAutomation(bool enabled) async {
    final updated = _state.config.copyWith(isEnabled: enabled);
    return updateConfig(updated);
  }

  /// Pre-flight safety interlock check and automatic irrigation evaluation.
  /// Evaluates telemetry, weather, quiet hours, controller status, and cooldown.
  Future<bool> evaluateAndTriggerCycle({
    required AwdAnalyticsSummary awdSummary,
    required bool isControllerOnline,
    bool isRaining = false,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();

    // Invariant 1: If automation is disabled, do nothing
    if (!_state.config.isEnabled) {
      if (_state.status.state != AutoIrrigationState.disabled) {
        _state = _state.copyWith(
          status: _state.status.copyWith(state: AutoIrrigationState.disabled),
        );
        notifyListeners();
      }
      return false;
    }

    // Invariant 2: Fault lockout prohibits autonomous cycle triggers
    if (_state.status.state == AutoIrrigationState.faultLocked) {
      return false;
    }

    // Invariant 3: Cooldown enforcement
    if (_state.status.state == AutoIrrigationState.cooldown) {
      if (_state.status.cooldownUntil != null &&
          timestamp.isBefore(_state.status.cooldownUntil!)) {
        return false;
      }
      // Cooldown expired, transition back to standby
      _state = _state.copyWith(
        status: _state.status.copyWith(
          state: AutoIrrigationState.standby,
          cooldownUntil: null,
        ),
      );
    }

    // If currently irrigating or in pendingAck, do not re-evaluate
    if (_state.status.state == AutoIrrigationState.irrigating ||
        _state.status.state == AutoIrrigationState.pendingAck) {
      return false;
    }

    // Pre-flight Interlocks
    final preFlightInhibitions = <String>[];

    // Interlock: Controller connectivity
    if (!isControllerOnline) {
      preFlightInhibitions.add('controllerOffline');
    }

    // Interlock: Rain delay
    if (_state.config.rainDelayEnabled && isRaining) {
      preFlightInhibitions.add('rainDelayActive');
    }

    // Interlock: Allowed hours / quiet hours
    if (!_state.config.isInAllowedHours(timestamp)) {
      preFlightInhibitions.add('outsideAllowedHours');
    }

    // Interlock: Agronomic AWD eligibility & confidence
    final eligibility = awdSummary.autoEligibility;
    if (eligibility != null && !eligibility.isEligibleForAutoIrrigation) {
      preFlightInhibitions.addAll(eligibility.inhibitionReasons);
    }

    if (preFlightInhibitions.isNotEmpty) {
      _state = _state.copyWith(
        status: _state.status.copyWith(
          state: AutoIrrigationState.standby,
          lastEvaluationTime: timestamp,
          lastEvaluationResult: 'Inhibited: ${preFlightInhibitions.join(', ')}',
          inhibitionReasons: preFlightInhibitions,
        ),
      );
      notifyListeners();
      return false;
    }

    // All pre-flight safety checks PASSED!
    // Step 1: Transition to evaluating
    final targetDuration = (eligibility?.recommendedDurationMinutes ?? 30)
        .clamp(15, _state.config.maxDurationMinutes);
    final commandId = 'cmd-auto-${timestamp.millisecondsSinceEpoch}';

    _state = _state.copyWith(
      status: _state.status.copyWith(
        state: AutoIrrigationState.evaluating,
        activeCommandId: commandId,
        lastEvaluationTime: timestamp,
        lastEvaluationResult: 'Pre-flight checks passed. Initiating field irrigation.',
        inhibitionReasons: const [],
      ),
    );
    notifyListeners();

    // Step 2: Transition to pendingAck
    _state = _state.copyWith(
      status: _state.status.copyWith(
        state: AutoIrrigationState.pendingAck,
      ),
    );
    notifyListeners();

    // Step 3: Acknowledgement received -> transition to irrigating
    _state = _state.copyWith(
      status: _state.status.copyWith(
        state: AutoIrrigationState.irrigating,
        startedAt: timestamp,
        targetDurationMinutes: targetDuration,
      ),
    );

    final auditLog = IrrigationExecutionAuditLog(
      id: 'log-${timestamp.millisecondsSinceEpoch}',
      systemId: _state.config.systemId,
      actor: IrrigationActor.systemAutoAwd,
      action: 'start',
      triggerContext: eligibility?.summaryRationale ?? 'AWD Automated Reflood',
      triggeringDepthCm: awdSummary.averageWaterDepthCm,
      telemetryConfidenceScore: awdSummary.confidence.score,
      cropStage: awdSummary.activeThresholdConfig.cropStage.label,
      targetDurationMinutes: targetDuration,
      outcome: 'in_progress',
      timestamp: timestamp,
    );

    await _repository.logExecution(auditLog);
    final updatedLogs = [auditLog, ..._state.auditLogs];
    _state = _state.copyWith(auditLogs: updatedLogs);
    notifyListeners();
    return true;
  }

  /// Stop the active cycle and enter cooldown. Can be triggered by system timer or operator abort.
  Future<void> stopCycle({
    required IrrigationActor actor,
    String? reason,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();
    final cooldownEnd = timestamp.add(Duration(minutes: _state.config.minCooldownMinutes));

    final actualMinutes = _state.status.startedAt != null
        ? timestamp.difference(_state.status.startedAt!).inMinutes
        : null;

    final outcome = actor.type == IrrigationActorType.system ? 'completed' : 'aborted';

    _state = _state.copyWith(
      status: _state.status.copyWith(
        state: AutoIrrigationState.cooldown,
        activeCommandId: null,
        startedAt: null,
        targetDurationMinutes: null,
        cooldownUntil: cooldownEnd,
        lastEvaluationResult: 'Cycle $outcome. Entering cooldown until $cooldownEnd.',
      ),
    );

    final auditLog = IrrigationExecutionAuditLog(
      id: 'log-${timestamp.millisecondsSinceEpoch}',
      systemId: _state.config.systemId,
      actor: actor,
      action: 'stop',
      triggerContext: reason ?? (outcome == 'completed' ? 'Target duration reached' : 'Cycle stopped'),
      actualDurationMinutes: actualMinutes,
      outcome: outcome,
      timestamp: timestamp,
    );

    await _repository.logExecution(auditLog);
    final updatedLogs = [auditLog, ..._state.auditLogs];
    _state = _state.copyWith(auditLogs: updatedLogs);
    notifyListeners();
  }

  /// Checks if active cooldown has elapsed.
  void checkCooldownStatus([DateTime? now]) {
    final timestamp = now ?? DateTime.now();
    if (_state.status.state == AutoIrrigationState.cooldown &&
        _state.status.cooldownUntil != null &&
        timestamp.isAfter(_state.status.cooldownUntil!)) {
      _state = _state.copyWith(
        status: _state.status.copyWith(
          state: _state.config.isEnabled
              ? AutoIrrigationState.standby
              : AutoIrrigationState.disabled,
          cooldownUntil: null,
          lastEvaluationResult: 'Cooldown completed. Returned to standby.',
        ),
      );
      notifyListeners();
    }
  }

  /// Transitions supervisor into faultLocked state on hardware or communication error.
  Future<void> triggerFaultLockout(String reason, {DateTime? now}) async {
    final timestamp = now ?? DateTime.now();
    _state = _state.copyWith(
      status: _state.status.copyWith(
        state: AutoIrrigationState.faultLocked,
        lockoutReason: reason,
        lockoutTimestamp: timestamp,
        activeCommandId: null,
        startedAt: null,
        targetDurationMinutes: null,
      ),
    );

    final auditLog = IrrigationExecutionAuditLog(
      id: 'log-${timestamp.millisecondsSinceEpoch}',
      systemId: _state.config.systemId,
      actor: IrrigationActor.systemAutoAwd,
      action: 'fault_lockout',
      triggerContext: reason,
      outcome: 'failed',
      failureReason: reason,
      timestamp: timestamp,
    );

    await _repository.logExecution(auditLog);
    final updatedLogs = [auditLog, ..._state.auditLogs];
    _state = _state.copyWith(auditLogs: updatedLogs);
    notifyListeners();
  }

  /// Clears fault lockout after field inspection.
  Future<bool> clearFaultLockout({
    String? resolutionNote,
    String? clearedBy,
  }) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final updatedStatus = await _repository.clearFaultLockout(
        systemId: _state.config.systemId,
        resolutionNote: resolutionNote,
        clearedBy: clearedBy,
      );
      final logs = await _repository.getAuditLogs(systemId: _state.config.systemId);

      _state = _state.copyWith(
        status: updatedStatus,
        auditLogs: logs,
        isLoading: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to clear fault lockout: $e',
      );
      notifyListeners();
      return false;
    }
  }
}
