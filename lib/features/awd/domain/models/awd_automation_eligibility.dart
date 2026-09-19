/// Inhibition codes representing safety or agronomic reasons preventing automatic irrigation.
class AwdInhibitionReason {
  static const String disparityConflict = 'disparityConflict';
  static const String lowConfidence = 'lowConfidence';
  static const String staleTelemetry = 'staleTelemetry';
  static const String criticalOutliers = 'criticalOutliers';
  static const String cropStageTerminalDrainage = 'cropStageTerminalDrainage';
  static const String insufficientData = 'insufficientData';
  static const String alreadyFlooded = 'alreadyFlooded';
  static const String notInDryState = 'notInDryState';

  static String toHumanDescription(String reason) {
    switch (reason) {
      case disparityConflict:
        return 'Severe moisture disparity between zones: localized flooding hazard.';
      case lowConfidence:
        return 'Telemetry confidence score is below safe automation threshold (>= 75%).';
      case staleTelemetry:
        return 'Telemetry data is stale: fresh observations required.';
      case criticalOutliers:
        return 'Critical sensor anomalies or outliers detected in reporting nodes.';
      case cropStageTerminalDrainage:
        return 'Ripening stage terminal drainage active: field must remain dry.';
      case insufficientData:
        return 'Insufficient reporting nodes to establish field quorum.';
      case alreadyFlooded:
        return 'Field standing water is adequate: pumping unnecessary.';
      case notInDryState:
        return 'Field is within safe AWD drying boundaries: reflood not yet needed.';
      default:
        return reason;
    }
  }
}

/// Evaluates whether field conditions are eligible for automated centralized irrigation trigger.
class AwdAutomationEligibility {
  final bool isEligibleForAutoIrrigation;
  final int recommendedDurationMinutes;
  final List<String> inhibitionReasons;
  final String summaryRationale;
  final DateTime evaluatedAt;

  const AwdAutomationEligibility({
    required this.isEligibleForAutoIrrigation,
    required this.recommendedDurationMinutes,
    this.inhibitionReasons = const [],
    required this.summaryRationale,
    required this.evaluatedAt,
  });

  bool hasInhibition(String reason) => inhibitionReasons.contains(reason);

  AwdAutomationEligibility copyWith({
    bool? isEligibleForAutoIrrigation,
    int? recommendedDurationMinutes,
    List<String>? inhibitionReasons,
    String? summaryRationale,
    DateTime? evaluatedAt,
  }) {
    return AwdAutomationEligibility(
      isEligibleForAutoIrrigation:
          isEligibleForAutoIrrigation ?? this.isEligibleForAutoIrrigation,
      recommendedDurationMinutes:
          recommendedDurationMinutes ?? this.recommendedDurationMinutes,
      inhibitionReasons: inhibitionReasons ?? this.inhibitionReasons,
      summaryRationale: summaryRationale ?? this.summaryRationale,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEligibleForAutoIrrigation': isEligibleForAutoIrrigation,
      'recommendedDurationMinutes': recommendedDurationMinutes,
      'inhibitionReasons': inhibitionReasons,
      'summaryRationale': summaryRationale,
      'evaluatedAt': evaluatedAt.toIso8601String(),
    };
  }

  factory AwdAutomationEligibility.fromJson(Map<String, dynamic> json) {
    return AwdAutomationEligibility(
      isEligibleForAutoIrrigation:
          json['isEligibleForAutoIrrigation'] as bool? ?? false,
      recommendedDurationMinutes:
          (json['recommendedDurationMinutes'] as num?)?.toInt() ?? 0,
      inhibitionReasons: (json['inhibitionReasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      summaryRationale: json['summaryRationale'] as String? ?? '',
      evaluatedAt: json['evaluatedAt'] != null
          ? DateTime.tryParse(json['evaluatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AwdAutomationEligibility &&
          runtimeType == other.runtimeType &&
          isEligibleForAutoIrrigation == other.isEligibleForAutoIrrigation &&
          recommendedDurationMinutes == other.recommendedDurationMinutes &&
          summaryRationale == other.summaryRationale &&
          evaluatedAt == other.evaluatedAt;

  @override
  int get hashCode => Object.hash(
        isEligibleForAutoIrrigation,
        recommendedDurationMinutes,
        summaryRationale,
        evaluatedAt,
      );
}

