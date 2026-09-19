/// Centralized automatic irrigation supervisor state machine states.
enum AutoIrrigationState {
  disabled,
  standby,
  evaluating,
  pendingAck,
  irrigating,
  cooldown,
  faultLocked;

  String get label {
    switch (this) {
      case AutoIrrigationState.disabled:
        return 'Disabled';
      case AutoIrrigationState.standby:
        return 'Standby';
      case AutoIrrigationState.evaluating:
        return 'Evaluating';
      case AutoIrrigationState.pendingAck:
        return 'Pending ACK';
      case AutoIrrigationState.irrigating:
        return 'Auto-Irrigating';
      case AutoIrrigationState.cooldown:
        return 'Cooldown';
      case AutoIrrigationState.faultLocked:
        return 'Fault Locked';
    }
  }
}

/// Represents the active state of the centralized field automatic irrigation supervisor.
class AutoIrrigationStatus {
  final String systemId;
  final AutoIrrigationState state;
  final String? activeCommandId;
  final DateTime? startedAt;
  final int? targetDurationMinutes;
  final DateTime? cooldownUntil;
  final DateTime? lastEvaluationTime;
  final String? lastEvaluationResult;
  final String? lockoutReason;
  final DateTime? lockoutTimestamp;
  final List<String> inhibitionReasons;

  const AutoIrrigationStatus({
    this.systemId = 'default',
    this.state = AutoIrrigationState.disabled,
    this.activeCommandId,
    this.startedAt,
    this.targetDurationMinutes,
    this.cooldownUntil,
    this.lastEvaluationTime,
    this.lastEvaluationResult,
    this.lockoutReason,
    this.lockoutTimestamp,
    this.inhibitionReasons = const [],
  });

  bool get isOperational =>
      state != AutoIrrigationState.disabled &&
      state != AutoIrrigationState.faultLocked;

  bool get isActivelyIrrigating => state == AutoIrrigationState.irrigating;

  bool get isFaultLocked => state == AutoIrrigationState.faultLocked;

  bool get isInCooldown => state == AutoIrrigationState.cooldown;

  Duration? remainingCooldown([DateTime? now]) {
    if (cooldownUntil == null) return null;
    final current = now ?? DateTime.now();
    final diff = cooldownUntil!.difference(current);
    return diff.isNegative ? Duration.zero : diff;
  }

  Duration? remainingIrrigationDuration([DateTime? now]) {
    if (startedAt == null || targetDurationMinutes == null) return null;
    final current = now ?? DateTime.now();
    final end = startedAt!.add(Duration(minutes: targetDurationMinutes!));
    final diff = end.difference(current);
    return diff.isNegative ? Duration.zero : diff;
  }

  AutoIrrigationStatus copyWith({
    String? systemId,
    AutoIrrigationState? state,
    Object? activeCommandId = _unset,
    Object? startedAt = _unset,
    Object? targetDurationMinutes = _unset,
    Object? cooldownUntil = _unset,
    Object? lastEvaluationTime = _unset,
    Object? lastEvaluationResult = _unset,
    Object? lockoutReason = _unset,
    Object? lockoutTimestamp = _unset,
    List<String>? inhibitionReasons,
  }) {
    return AutoIrrigationStatus(
      systemId: systemId ?? this.systemId,
      state: state ?? this.state,
      activeCommandId: identical(activeCommandId, _unset)
          ? this.activeCommandId
          : activeCommandId as String?,
      startedAt: identical(startedAt, _unset)
          ? this.startedAt
          : startedAt as DateTime?,
      targetDurationMinutes: identical(targetDurationMinutes, _unset)
          ? this.targetDurationMinutes
          : targetDurationMinutes as int?,
      cooldownUntil: identical(cooldownUntil, _unset)
          ? this.cooldownUntil
          : cooldownUntil as DateTime?,
      lastEvaluationTime: identical(lastEvaluationTime, _unset)
          ? this.lastEvaluationTime
          : lastEvaluationTime as DateTime?,
      lastEvaluationResult: identical(lastEvaluationResult, _unset)
          ? this.lastEvaluationResult
          : lastEvaluationResult as String?,
      lockoutReason: identical(lockoutReason, _unset)
          ? this.lockoutReason
          : lockoutReason as String?,
      lockoutTimestamp: identical(lockoutTimestamp, _unset)
          ? this.lockoutTimestamp
          : lockoutTimestamp as DateTime?,
      inhibitionReasons: inhibitionReasons ?? this.inhibitionReasons,
    );
  }

  static const Object _unset = Object();

  Map<String, dynamic> toJson() {
    return {
      'systemId': systemId,
      'state': state.name,
      if (activeCommandId != null) 'activeCommandId': activeCommandId,
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (targetDurationMinutes != null)
        'targetDurationMinutes': targetDurationMinutes,
      if (cooldownUntil != null)
        'cooldownUntil': cooldownUntil!.toIso8601String(),
      if (lastEvaluationTime != null)
        'lastEvaluationTime': lastEvaluationTime!.toIso8601String(),
      if (lastEvaluationResult != null)
        'lastEvaluationResult': lastEvaluationResult,
      if (lockoutReason != null) 'lockoutReason': lockoutReason,
      if (lockoutTimestamp != null)
        'lockoutTimestamp': lockoutTimestamp!.toIso8601String(),
      'inhibitionReasons': inhibitionReasons,
    };
  }

  factory AutoIrrigationStatus.fromJson(Map<String, dynamic> json) {
    final stateStr = json['state'] as String? ?? 'disabled';
    final state = AutoIrrigationState.values.firstWhere(
      (e) => e.name.toLowerCase() == stateStr.toLowerCase(),
      orElse: () => AutoIrrigationState.disabled,
    );

    return AutoIrrigationStatus(
      systemId: json['systemId'] as String? ?? 'default',
      state: state,
      activeCommandId: json['activeCommandId'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      targetDurationMinutes:
          (json['targetDurationMinutes'] as num?)?.toInt(),
      cooldownUntil: json['cooldownUntil'] != null
          ? DateTime.tryParse(json['cooldownUntil'] as String)
          : null,
      lastEvaluationTime: json['lastEvaluationTime'] != null
          ? DateTime.tryParse(json['lastEvaluationTime'] as String)
          : null,
      lastEvaluationResult: json['lastEvaluationResult'] as String?,
      lockoutReason: json['lockoutReason'] as String?,
      lockoutTimestamp: json['lockoutTimestamp'] != null
          ? DateTime.tryParse(json['lockoutTimestamp'] as String)
          : null,
      inhibitionReasons: (json['inhibitionReasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoIrrigationStatus &&
          runtimeType == other.runtimeType &&
          systemId == other.systemId &&
          state == other.state &&
          activeCommandId == other.activeCommandId &&
          startedAt == other.startedAt &&
          targetDurationMinutes == other.targetDurationMinutes &&
          cooldownUntil == other.cooldownUntil &&
          lastEvaluationTime == other.lastEvaluationTime &&
          lastEvaluationResult == other.lastEvaluationResult &&
          lockoutReason == other.lockoutReason &&
          lockoutTimestamp == other.lockoutTimestamp;

  @override
  int get hashCode => Object.hash(
        systemId,
        state,
        activeCommandId,
        startedAt,
        targetDurationMinutes,
        cooldownUntil,
        lastEvaluationTime,
        lastEvaluationResult,
        lockoutReason,
        lockoutTimestamp,
      );
}

