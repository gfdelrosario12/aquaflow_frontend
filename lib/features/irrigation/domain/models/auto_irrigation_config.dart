/// Configuration for field-level centralized automatic irrigation.
class AutoIrrigationConfig {
  final String systemId;
  final bool isEnabled;
  final int maxDurationMinutes;
  final int minCooldownMinutes;
  final int allowedHoursStart;
  final int allowedHoursEnd;
  final double targetFloodDepthCm;
  final bool rainDelayEnabled;
  final int rainDelayHours;
  final double minConfidenceThreshold;
  final DateTime? updatedAt;
  final String? updatedBy;

  const AutoIrrigationConfig({
    this.systemId = 'default',
    this.isEnabled = false,
    this.maxDurationMinutes = 45,
    this.minCooldownMinutes = 60,
    this.allowedHoursStart = 6,
    this.allowedHoursEnd = 18,
    this.targetFloodDepthCm = 5.0,
    this.rainDelayEnabled = true,
    this.rainDelayHours = 24,
    this.minConfidenceThreshold = 0.75,
    this.updatedAt,
    this.updatedBy,
  });

  /// Evaluates whether the provided [time] falls within allowed irrigation hours.
  bool isInAllowedHours(DateTime time) {
    final hour = time.hour;
    if (allowedHoursStart <= allowedHoursEnd) {
      return hour >= allowedHoursStart && hour < allowedHoursEnd;
    } else {
      // Handles overnight window, e.g. 20:00 to 06:00
      return hour >= allowedHoursStart || hour < allowedHoursEnd;
    }
  }

  AutoIrrigationConfig copyWith({
    String? systemId,
    bool? isEnabled,
    int? maxDurationMinutes,
    int? minCooldownMinutes,
    int? allowedHoursStart,
    int? allowedHoursEnd,
    double? targetFloodDepthCm,
    bool? rainDelayEnabled,
    int? rainDelayHours,
    double? minConfidenceThreshold,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return AutoIrrigationConfig(
      systemId: systemId ?? this.systemId,
      isEnabled: isEnabled ?? this.isEnabled,
      maxDurationMinutes: maxDurationMinutes ?? this.maxDurationMinutes,
      minCooldownMinutes: minCooldownMinutes ?? this.minCooldownMinutes,
      allowedHoursStart: allowedHoursStart ?? this.allowedHoursStart,
      allowedHoursEnd: allowedHoursEnd ?? this.allowedHoursEnd,
      targetFloodDepthCm: targetFloodDepthCm ?? this.targetFloodDepthCm,
      rainDelayEnabled: rainDelayEnabled ?? this.rainDelayEnabled,
      rainDelayHours: rainDelayHours ?? this.rainDelayHours,
      minConfidenceThreshold:
          minConfidenceThreshold ?? this.minConfidenceThreshold,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systemId': systemId,
      'isEnabled': isEnabled,
      'maxDurationMinutes': maxDurationMinutes,
      'minCooldownMinutes': minCooldownMinutes,
      'allowedHoursStart': allowedHoursStart,
      'allowedHoursEnd': allowedHoursEnd,
      'targetFloodDepthCm': targetFloodDepthCm,
      'rainDelayEnabled': rainDelayEnabled,
      'rainDelayHours': rainDelayHours,
      'minConfidenceThreshold': minConfidenceThreshold,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }

  factory AutoIrrigationConfig.fromJson(Map<String, dynamic> json) {
    return AutoIrrigationConfig(
      systemId: json['systemId'] as String? ?? 'default',
      isEnabled: json['isEnabled'] as bool? ?? false,
      maxDurationMinutes: (json['maxDurationMinutes'] as num?)?.toInt() ?? 45,
      minCooldownMinutes: (json['minCooldownMinutes'] as num?)?.toInt() ?? 60,
      allowedHoursStart: (json['allowedHoursStart'] as num?)?.toInt() ?? 6,
      allowedHoursEnd: (json['allowedHoursEnd'] as num?)?.toInt() ?? 18,
      targetFloodDepthCm:
          (json['targetFloodDepthCm'] as num?)?.toDouble() ?? 5.0,
      rainDelayEnabled: json['rainDelayEnabled'] as bool? ?? true,
      rainDelayHours: (json['rainDelayHours'] as num?)?.toInt() ?? 24,
      minConfidenceThreshold:
          (json['minConfidenceThreshold'] as num?)?.toDouble() ?? 0.75,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoIrrigationConfig &&
          runtimeType == other.runtimeType &&
          systemId == other.systemId &&
          isEnabled == other.isEnabled &&
          maxDurationMinutes == other.maxDurationMinutes &&
          minCooldownMinutes == other.minCooldownMinutes &&
          allowedHoursStart == other.allowedHoursStart &&
          allowedHoursEnd == other.allowedHoursEnd &&
          targetFloodDepthCm == other.targetFloodDepthCm &&
          rainDelayEnabled == other.rainDelayEnabled &&
          rainDelayHours == other.rainDelayHours &&
          minConfidenceThreshold == other.minConfidenceThreshold &&
          updatedAt == other.updatedAt &&
          updatedBy == other.updatedBy;

  @override
  int get hashCode => Object.hash(
        systemId,
        isEnabled,
        maxDurationMinutes,
        minCooldownMinutes,
        allowedHoursStart,
        allowedHoursEnd,
        targetFloodDepthCm,
        rainDelayEnabled,
        rainDelayHours,
        minConfidenceThreshold,
        updatedAt,
        updatedBy,
      );
}

