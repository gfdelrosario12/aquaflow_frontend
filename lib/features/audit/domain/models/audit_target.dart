class AuditTarget {
  final String type;
  final String id;
  final String? displayName;

  const AuditTarget({
    required this.type,
    required this.id,
    this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      if (displayName != null) 'displayName': displayName,
    };
  }

  factory AuditTarget.fromJson(Map<String, dynamic> json) {
    return AuditTarget(
      type: json['type'] as String? ?? 'system',
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditTarget &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          displayName == other.displayName;

  @override
  int get hashCode => type.hashCode ^ id.hashCode ^ displayName.hashCode;
}

