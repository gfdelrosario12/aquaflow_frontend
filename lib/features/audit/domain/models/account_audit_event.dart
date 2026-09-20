import 'audit_actor.dart';
import 'audit_category.dart';
import 'audit_metadata.dart';
import 'audit_result.dart';
import 'audit_target.dart';

class AccountAuditEvent {
  final String eventId;
  final DateTime timestamp;
  final AuditActor actor;
  final AuditCategory category;
  final String action;
  final AuditTarget target;
  final AuditResult result;
  final AuditMetadata metadata;

  const AccountAuditEvent({
    required this.eventId,
    required this.timestamp,
    required this.actor,
    required this.category,
    required this.action,
    required this.target,
    required this.result,
    this.metadata = const AuditMetadata(),
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'timestamp': timestamp.toIso8601String(),
      'actor': actor.toJson(),
      'category': category.toJson(),
      'action': action,
      'target': target.toJson(),
      'result': result.toJson(),
      'metadata': metadata.toJson(),
    };
  }

  factory AccountAuditEvent.fromJson(Map<String, dynamic> json) {
    return AccountAuditEvent(
      eventId: json['eventId'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      actor: AuditActor.fromJson(json['actor'] as Map<String, dynamic>? ?? {}),
      category: AuditCategory.fromJson(json['category'] as String? ?? 'system'),
      action: json['action'] as String? ?? '',
      target: AuditTarget.fromJson(json['target'] as Map<String, dynamic>? ?? {}),
      result: AuditResult.fromJson(json['result'] as String? ?? 'failed'),
      metadata: AuditMetadata.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAuditEvent &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          timestamp == other.timestamp &&
          actor == other.actor &&
          category == other.category &&
          action == other.action &&
          target == other.target &&
          result == other.result &&
          metadata == other.metadata;

  @override
  int get hashCode =>
      eventId.hashCode ^
      timestamp.hashCode ^
      actor.hashCode ^
      category.hashCode ^
      action.hashCode ^
      target.hashCode ^
      result.hashCode ^
      metadata.hashCode;
}

