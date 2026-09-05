enum RecommendationUrgency { high, medium, low }
enum ActionableType { startCentralIrrigation, stopCentralIrrigation, inspectZoneSensors, noActionNeeded }

class FieldRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationUrgency urgency;
  final ActionableType actionType;
  final int? recommendedDurationMinutes;

  const FieldRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.urgency,
    required this.actionType,
    this.recommendedDurationMinutes,
  });
}

