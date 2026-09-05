import 'control_enums.dart';

/// Represents an irrigation control command sent down the control pipeline
class ControlCommand {
  final String id;
  final CommandType type;
  final String target;
  final int durationMinutes;
  final DateTime timestamp;
  final String requestedBy;
  final ControlUserRole userRole;

  static const String fixedTarget = 'ENTIRE FIELD';

  const ControlCommand({
    required this.id,
    required this.type,
    this.target = fixedTarget,
    required this.durationMinutes,
    required this.timestamp,
    required this.requestedBy,
    required this.userRole,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'target': target,
        'durationMinutes': durationMinutes,
        'timestamp': timestamp.toIso8601String(),
        'requestedBy': requestedBy,
        'userRole': userRole.name,
      };
}

