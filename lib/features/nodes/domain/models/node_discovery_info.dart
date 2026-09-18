class NodeDiscoveryInfo {
  final String id;
  final String macAddress;
  final String hardwareModel;
  final String firmwareVersion;
  final int rssiDbm;
  final DateTime detectedAt;

  const NodeDiscoveryInfo({
    required this.id,
    required this.macAddress,
    required this.hardwareModel,
    required this.firmwareVersion,
    required this.rssiDbm,
    required this.detectedAt,
  });

  factory NodeDiscoveryInfo.fromJson(Map<String, dynamic> json) {
    return NodeDiscoveryInfo(
      id: json['id']?.toString() ?? '',
      macAddress: json['macAddress']?.toString() ?? '',
      hardwareModel: json['hardwareModel']?.toString() ?? 'ESP32 LoRa Node',
      firmwareVersion: json['firmwareVersion']?.toString() ?? '1.0.0',
      rssiDbm: int.tryParse(json['rssiDbm']?.toString() ?? '') ?? -85,
      detectedAt:
          DateTime.tryParse(json['detectedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'macAddress': macAddress,
        'hardwareModel': hardwareModel,
        'firmwareVersion': firmwareVersion,
        'rssiDbm': rssiDbm,
        'detectedAt': detectedAt.toIso8601String(),
      };
}

