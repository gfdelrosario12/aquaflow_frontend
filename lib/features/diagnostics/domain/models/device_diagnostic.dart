import 'diagnostics_enums.dart';

/// Hardware device diagnostic metrics and operational health
class DeviceDiagnostic {
  final String id;
  final String name;
  final DeviceCategory category;
  final DeviceHealthStatus healthStatus;
  final bool isOnline;
  final int? batteryPercent;
  final double? batteryVoltage;
  final int? rssiDbm;
  final double? snrDb;
  final DateTime lastSeen;
  final String? lastMeasurement;
  final String targetScope;
  final String? pumpState;
  final String? valveState;
  final String? communicationStatus;
  final String? uplinkStatus;
  final String? downlinkStatus;
  final String? backhaulStatus;
  final double? packetRetransmissionRate;
  final String? lastCommand;
  final String? lastCommandResult;
  final DateTime? lastCommunication;
  final String diagnosticMessage;

  const DeviceDiagnostic({
    required this.id,
    required this.name,
    required this.category,
    required this.healthStatus,
    required this.isOnline,
    this.batteryPercent,
    this.batteryVoltage,
    this.rssiDbm,
    this.snrDb,
    required this.lastSeen,
    this.lastMeasurement,
    required this.targetScope,
    this.pumpState,
    this.valveState,
    this.communicationStatus,
    this.uplinkStatus,
    this.downlinkStatus,
    this.backhaulStatus,
    this.packetRetransmissionRate,
    this.lastCommand,
    this.lastCommandResult,
    this.lastCommunication,
    required this.diagnosticMessage,
  });

  DeviceDiagnostic copyWith({
    String? id,
    String? name,
    DeviceCategory? category,
    DeviceHealthStatus? healthStatus,
    bool? isOnline,
    int? batteryPercent,
    double? batteryVoltage,
    int? rssiDbm,
    double? snrDb,
    DateTime? lastSeen,
    String? lastMeasurement,
    String? targetScope,
    String? pumpState,
    String? valveState,
    String? communicationStatus,
    String? uplinkStatus,
    String? downlinkStatus,
    String? backhaulStatus,
    double? packetRetransmissionRate,
    String? lastCommand,
    String? lastCommandResult,
    DateTime? lastCommunication,
    String? diagnosticMessage,
  }) {
    return DeviceDiagnostic(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      healthStatus: healthStatus ?? this.healthStatus,
      isOnline: isOnline ?? this.isOnline,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      rssiDbm: rssiDbm ?? this.rssiDbm,
      snrDb: snrDb ?? this.snrDb,
      lastSeen: lastSeen ?? this.lastSeen,
      lastMeasurement: lastMeasurement ?? this.lastMeasurement,
      targetScope: targetScope ?? this.targetScope,
      pumpState: pumpState ?? this.pumpState,
      valveState: valveState ?? this.valveState,
      communicationStatus: communicationStatus ?? this.communicationStatus,
      uplinkStatus: uplinkStatus ?? this.uplinkStatus,
      downlinkStatus: downlinkStatus ?? this.downlinkStatus,
      backhaulStatus: backhaulStatus ?? this.backhaulStatus,
      packetRetransmissionRate: packetRetransmissionRate ?? this.packetRetransmissionRate,
      lastCommand: lastCommand ?? this.lastCommand,
      lastCommandResult: lastCommandResult ?? this.lastCommandResult,
      lastCommunication: lastCommunication ?? this.lastCommunication,
      diagnosticMessage: diagnosticMessage ?? this.diagnosticMessage,
    );
  }
}
