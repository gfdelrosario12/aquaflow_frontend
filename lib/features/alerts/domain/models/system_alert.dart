import 'alert_enums.dart';
import 'alert_source.dart';

/// Represents a system alert or notification event
class SystemAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertCategory category;
  final AlertSource source;
  final DateTime timestamp;
  final bool isRead;
  final String recommendedAction;
  final Map<String, dynamic>? metadata;

  const SystemAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.source,
    required this.timestamp,
    this.isRead = false,
    required this.recommendedAction,
    this.metadata,
  });

  SystemAlert copyWith({
    String? id,
    String? title,
    String? description,
    AlertSeverity? severity,
    AlertCategory? category,
    AlertSource? source,
    DateTime? timestamp,
    bool? isRead,
    String? recommendedAction,
    Map<String, dynamic>? metadata,
  }) {
    return SystemAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      metadata: metadata ?? this.metadata,
    );
  }
}

