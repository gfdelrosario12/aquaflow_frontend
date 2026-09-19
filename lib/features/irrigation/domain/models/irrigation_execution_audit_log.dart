/// Type of actor triggering an irrigation lifecycle event.
enum IrrigationActorType {
  system,
  user,
  emergencyStop;

  String get label {
    switch (this) {
      case IrrigationActorType.system:
        return 'System';
      case IrrigationActorType.user:
        return 'Operator';
      case IrrigationActorType.emergencyStop:
        return 'Emergency Stop';
    }
  }
}

/// Identifies the entity initiating or controlling an irrigation action.
class IrrigationActor {
  final IrrigationActorType type;
  final String id;
  final String displayName;

  const IrrigationActor({
    required this.type,
    required this.id,
    required this.displayName,
  });

  static const systemAutoAwd = IrrigationActor(
    type: IrrigationActorType.system,
    id: 'auto-awd',
    displayName: 'System (Auto-AWD)',
  );

  factory IrrigationActor.operator({
    required String id,
    String? name,
  }) {
    return IrrigationActor(
      type: IrrigationActorType.user,
      id: id,
      displayName: name ?? 'Operator $id',
    );
  }

  factory IrrigationActor.emergencyStop({
    required String id,
    String? name,
  }) {
    return IrrigationActor(
      type: IrrigationActorType.emergencyStop,
      id: id,
      displayName: name ?? 'Emergency Stop ($id)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'id': id,
      'displayName': displayName,
    };
  }

  factory IrrigationActor.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'system';
    final type = IrrigationActorType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
      orElse: () => IrrigationActorType.system,
    );

    return IrrigationActor(
      type: type,
      id: json['id'] as String? ?? 'unknown',
      displayName: json['displayName'] as String? ?? 'Unknown Actor',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IrrigationActor &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          displayName == other.displayName;

  @override
  int get hashCode => Object.hash(type, id, displayName);
}

/// Audit log record documenting an irrigation action or state transition.
class IrrigationExecutionAuditLog {
  final String id;
  final String systemId;
  final IrrigationActor actor;
  final String action;
  final String triggerContext;
  final double? triggeringDepthCm;
  final double? telemetryConfidenceScore;
  final String? cropStage;
  final int? targetDurationMinutes;
  final int? actualDurationMinutes;
  final String outcome;
  final DateTime timestamp;
  final String? failureReason;

  const IrrigationExecutionAuditLog({
    required this.id,
    this.systemId = 'default',
    required this.actor,
    required this.action,
    required this.triggerContext,
    this.triggeringDepthCm,
    this.telemetryConfidenceScore,
    this.cropStage,
    this.targetDurationMinutes,
    this.actualDurationMinutes,
    required this.outcome,
    required this.timestamp,
    this.failureReason,
  });

  bool get isSystemTriggered => actor.type == IrrigationActorType.system;
  bool get isManualOperator => actor.type == IrrigationActorType.user;
  bool get isEmergencyStop => actor.type == IrrigationActorType.emergencyStop;

  IrrigationExecutionAuditLog copyWith({
    String? id,
    String? systemId,
    IrrigationActor? actor,
    String? action,
    String? triggerContext,
    double? triggeringDepthCm,
    double? telemetryConfidenceScore,
    String? cropStage,
    int? targetDurationMinutes,
    int? actualDurationMinutes,
    String? outcome,
    DateTime? timestamp,
    String? failureReason,
  }) {
    return IrrigationExecutionAuditLog(
      id: id ?? this.id,
      systemId: systemId ?? this.systemId,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      triggerContext: triggerContext ?? this.triggerContext,
      triggeringDepthCm: triggeringDepthCm ?? this.triggeringDepthCm,
      telemetryConfidenceScore:
          telemetryConfidenceScore ?? this.telemetryConfidenceScore,
      cropStage: cropStage ?? this.cropStage,
      targetDurationMinutes:
          targetDurationMinutes ?? this.targetDurationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      outcome: outcome ?? this.outcome,
      timestamp: timestamp ?? this.timestamp,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systemId': systemId,
      'actor': actor.toJson(),
      'action': action,
      'triggerContext': triggerContext,
      if (triggeringDepthCm != null) 'triggeringDepthCm': triggeringDepthCm,
      if (telemetryConfidenceScore != null)
        'telemetryConfidenceScore': telemetryConfidenceScore,
      if (cropStage != null) 'cropStage': cropStage,
      if (targetDurationMinutes != null)
        'targetDurationMinutes': targetDurationMinutes,
      if (actualDurationMinutes != null)
        'actualDurationMinutes': actualDurationMinutes,
      'outcome': outcome,
      'timestamp': timestamp.toIso8601String(),
      if (failureReason != null) 'failureReason': failureReason,
    };
  }

  factory IrrigationExecutionAuditLog.fromJson(Map<String, dynamic> json) {
    return IrrigationExecutionAuditLog(
      id: json['id'] as String? ?? '',
      systemId: json['systemId'] as String? ?? 'default',
      actor: IrrigationActor.fromJson(
        json['actor'] as Map<String, dynamic>? ?? {},
      ),
      action: json['action'] as String? ?? '',
      triggerContext: json['triggerContext'] as String? ?? '',
      triggeringDepthCm: (json['triggeringDepthCm'] as num?)?.toDouble(),
      telemetryConfidenceScore:
          (json['telemetryConfidenceScore'] as num?)?.toDouble(),
      cropStage: json['cropStage'] as String?,
      targetDurationMinutes:
          (json['targetDurationMinutes'] as num?)?.toInt(),
      actualDurationMinutes:
          (json['actualDurationMinutes'] as num?)?.toInt(),
      outcome: json['outcome'] as String? ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      failureReason: json['failureReason'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IrrigationExecutionAuditLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          systemId == other.systemId &&
          actor == other.actor &&
          action == other.action &&
          triggerContext == other.triggerContext &&
          triggeringDepthCm == other.triggeringDepthCm &&
          telemetryConfidenceScore == other.telemetryConfidenceScore &&
          cropStage == other.cropStage &&
          targetDurationMinutes == other.targetDurationMinutes &&
          actualDurationMinutes == other.actualDurationMinutes &&
          outcome == other.outcome &&
          timestamp == other.timestamp &&
          failureReason == other.failureReason;

  @override
  int get hashCode => Object.hash(
        id,
        systemId,
        actor,
        action,
        triggerContext,
        triggeringDepthCm,
        telemetryConfidenceScore,
        cropStage,
        targetDurationMinutes,
        actualDurationMinutes,
        outcome,
        timestamp,
        failureReason,
      );
}

