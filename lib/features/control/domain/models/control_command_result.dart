import 'control_enums.dart';

/// Result of executing a control command through the LoRaWAN/messaging pipeline
class ControlCommandResult {
  final String commandId;
  final CommandType type;
  final CommandOutcome outcome;
  final String message;
  final DateTime timestamp;

  const ControlCommandResult({
    required this.commandId,
    required this.type,
    required this.outcome,
    required this.message,
    required this.timestamp,
  });

  bool get isSuccess => outcome == CommandOutcome.acknowledged || outcome == CommandOutcome.completed;
}

