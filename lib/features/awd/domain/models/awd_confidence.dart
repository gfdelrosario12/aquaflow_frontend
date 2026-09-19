/// Confidence categories for field-level AWD evaluations.
enum AwdConfidenceLevel {
  high,
  medium,
  low,
  insufficient;

  String get label {
    switch (this) {
      case AwdConfidenceLevel.high:
        return 'High Confidence';
      case AwdConfidenceLevel.medium:
        return 'Moderate Confidence';
      case AwdConfidenceLevel.low:
        return 'Low Confidence';
      case AwdConfidenceLevel.insufficient:
        return 'Insufficient Data';
    }
  }

  bool get isUsable => this == AwdConfidenceLevel.high || this == AwdConfidenceLevel.medium;
}

/// Represents the evaluated telemetry quality, coverage, and freshness confidence
/// of a field-wide AWD water level and recommendation assessment.
class AwdConfidence {
  final AwdConfidenceLevel level;
  final double score; // 0.0 .. 1.0
  final double coverageRatio; // usableNodes / totalConfiguredNodes
  final double freshnessScore; // 0.0 .. 1.0 based on measurement age
  final double validityRatio; // non-outlier / reporting nodes
  final List<String> contributingFactors;
  final String summaryMessage;

  const AwdConfidence({
    required this.level,
    required this.score,
    required this.coverageRatio,
    required this.freshnessScore,
    required this.validityRatio,
    required this.contributingFactors,
    required this.summaryMessage,
  });

  factory AwdConfidence.insufficient({
    String reason = 'Minimum usable monitoring nodes required for field analysis.',
  }) {
    return AwdConfidence(
      level: AwdConfidenceLevel.insufficient,
      score: 0.0,
      coverageRatio: 0.0,
      freshnessScore: 0.0,
      validityRatio: 0.0,
      contributingFactors: [reason],
      summaryMessage: reason,
    );
  }

  factory AwdConfidence.calculate({
    required int totalConfiguredNodes,
    required int usableReportingNodes,
    required int outlierCount,
    required double freshnessScore,
    required int minUsableNodes,
  }) {
    final total = totalConfiguredNodes > 0 ? totalConfiguredNodes : 1;
    final coverage = (usableReportingNodes / total).clamp(0.0, 1.0);
    final totalReporting = usableReportingNodes + outlierCount;
    final validity = totalReporting > 0
        ? (usableReportingNodes / totalReporting).clamp(0.0, 1.0)
        : 0.0;

    final factors = <String>[];

    if (usableReportingNodes < minUsableNodes || usableReportingNodes == 0) {
      return AwdConfidence.insufficient(
        reason: 'Reporting nodes ($usableReportingNodes) below required quorum ($minUsableNodes).',
      );
    }

    // Weighted formula: 50% Coverage, 35% Freshness, 15% Validity
    final computedScore = (coverage * 0.50) + (freshnessScore * 0.35) + (validity * 0.15);

    AwdConfidenceLevel level;
    String summary;

    if (computedScore >= 0.80 && coverage >= 0.75 && freshnessScore >= 0.60) {
      level = AwdConfidenceLevel.high;
      summary = 'High confidence telemetry across configured field zones.';
      factors.add('Field coverage: ${(coverage * 100).toInt()}% ($usableReportingNodes/$total nodes reporting).');
      factors.add('Telemetry freshness is optimal.');
    } else if (computedScore >= 0.50 && freshnessScore >= 0.35) {
      level = AwdConfidenceLevel.medium;
      summary = 'Moderate confidence: partial coverage or slight telemetry age.';
      factors.add('Reporting coverage: ${(coverage * 100).toInt()}% ($usableReportingNodes/$total nodes active).');
      if (freshnessScore < 0.7) {
        factors.add('Some measurements are aging or approaching stale thresholds.');
      }
      if (outlierCount > 0) {
        factors.add('$outlierCount anomalous sensor readings excluded from average.');
      }
    } else {
      level = AwdConfidenceLevel.low;
      summary = 'Low confidence: degraded coverage or aging sensor readings.';
      factors.add('Active node ratio is degraded ($usableReportingNodes/$total nodes).');
      if (freshnessScore < 0.5) {
        factors.add('Significant telemetry age detected.');
      }
      if (outlierCount > 0) {
        factors.add('Multiple sensor readings flagged as outliers.');
      }
    }

    return AwdConfidence(
      level: level,
      score: computedScore,
      coverageRatio: coverage,
      freshnessScore: freshnessScore,
      validityRatio: validity,
      contributingFactors: factors,
      summaryMessage: summary,
    );
  }
}
