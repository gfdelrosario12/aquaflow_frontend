enum IrrigationAction { irrigate, doNotIrrigate, monitor }
enum RecommendationUrgency { low, medium, high, critical }

class AwdRecommendation {
  final IrrigationAction action;
  final RecommendationUrgency urgency;
  final String title;
  final String rationale;
  final List<String> keyFactors;
  final DateTime generatedAt;

  const AwdRecommendation({
    required this.action,
    required this.urgency,
    required this.title,
    required this.rationale,
    required this.keyFactors,
    required this.generatedAt,
  });
}

