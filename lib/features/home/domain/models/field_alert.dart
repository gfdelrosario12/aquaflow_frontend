enum AlertSeverity { info, warning, critical }

class FieldAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String? zoneCode;

  const FieldAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.zoneCode,
  });
}

