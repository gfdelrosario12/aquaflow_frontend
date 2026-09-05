enum PumpState { active, idle, warning, offline }
enum ValveState { open, closed, partial }
enum SystemMode { scheduled, manual, simulatedAuto }

class CentralizedIrrigation {
  final String id;
  final String systemName;
  final PumpState mainPumpState;
  final ValveState distributionValveState;
  final double flowRateLitersPerMin;
  final double pressureBar;
  final SystemMode mode;
  final int activeDurationMinutes;
  final DateTime lastStateChange;

  const CentralizedIrrigation({
    required this.id,
    required this.systemName,
    required this.mainPumpState,
    required this.distributionValveState,
    required this.flowRateLitersPerMin,
    required this.pressureBar,
    required this.mode,
    required this.activeDurationMinutes,
    required this.lastStateChange,
  });

  CentralizedIrrigation copyWith({
    String? id,
    String? systemName,
    PumpState? mainPumpState,
    ValveState? distributionValveState,
    double? flowRateLitersPerMin,
    double? pressureBar,
    SystemMode? mode,
    int? activeDurationMinutes,
    DateTime? lastStateChange,
  }) {
    return CentralizedIrrigation(
      id: id ?? this.id,
      systemName: systemName ?? this.systemName,
      mainPumpState: mainPumpState ?? this.mainPumpState,
      distributionValveState: distributionValveState ?? this.distributionValveState,
      flowRateLitersPerMin: flowRateLitersPerMin ?? this.flowRateLitersPerMin,
      pressureBar: pressureBar ?? this.pressureBar,
      mode: mode ?? this.mode,
      activeDurationMinutes: activeDurationMinutes ?? this.activeDurationMinutes,
      lastStateChange: lastStateChange ?? this.lastStateChange,
    );
  }
}
