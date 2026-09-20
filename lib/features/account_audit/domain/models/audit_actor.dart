enum AuditActorType { user, system, emergencyOverride }

class AuditActor {
  final AuditActorType type;
  final String id;
  final String displayName;

  const AuditActor({
    required this.type,
    required this.id,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'id': id,
      'displayName': displayName,
    };
  }

  factory AuditActor.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'user';
    final type = AuditActorType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => AuditActorType.user,
    );
    return AuditActor(
      type: type,
      id: json['id'] as String? ?? 'unknown',
      displayName: json['displayName'] as String? ?? 'Unknown Actor',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditActor &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          displayName == other.displayName;

  @override
  int get hashCode => Object.hash(type, id, displayName);
}